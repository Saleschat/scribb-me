#!/usr/bin/env python3
"""scribb.me checker for places without Vale, such as claude.ai chat.

Applies the same rules as the Vale checker (compiled into rules.json next to
this file by tools/build-chat.py) using only the Python standard library.
It covers the Vale features scribb's packs use: existence, substitution,
occurrence and capitalization ($sentence) rules, with the text, raw,
sentence, paragraph and heading scopes.

Usage:
  python3 check.py --content-type ID [--freedom LEVEL] [--style ID]
                   [--vocab "Term, Other term"] [--format md|jsx]
                   [--rules-dir PACK_DIR]... FILE|-

Output, one finding per line (same as scribb-check):
  file:line:col:action:severity:rule:message
Exit codes: 0 nothing blocking, 1 blocking findings, 3 usage error.
"""

import argparse
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

SEVERITY = {"error": "hard", "warning": "convention", "suggestion": "preference"}
ACTIONS = {
    "strict": {"hard": "block", "convention": "block", "preference": "block"},
    "balanced": {"hard": "block", "convention": "block", "preference": "warn"},
    "expressive": {"hard": "block", "convention": "warn", "preference": "suggest"},
}


# --- Text preparation ---------------------------------------------------------
# Everything that isn't prose is replaced with spaces (newlines kept), so the
# line and column of every finding still point into the original text.

def blank(text, start, end):
    return text[:start] + re.sub(r"[^\n]", " ", text[start:end]) + text[end:]


def mask_markdown(raw):
    text = raw
    m = re.match(r"---\n.*?\n---\n", text, re.S)
    if m:
        text = blank(text, 0, m.end())
    for pat in (
        r"^```.*?^```[^\n]*$",          # fenced code
        r"^~~~.*?^~~~[^\n]*$",
        r"<!--.*?-->",                    # HTML comments
        r"`[^`\n]+`",                     # inline code
        r"\]\([^)\n]*\)",                 # link targets: keep the link text
        r"<https?://[^>\s]+>",            # autolinks
        r"https?://\S+",                  # bare URLs
    ):
        for m in reversed(list(re.finditer(pat, text, re.S | re.M))):
            start, end = m.start(), m.end()
            if pat.startswith(r"\]\("):
                start += 1  # keep the closing bracket of the link text
            text = blank(text, start, end)
    # Markdown markers that aren't words
    text = re.sub(r"^(\s*)([-*+]|\d+\.)(\s)", lambda m: m.group(1) + " " * len(m.group(2)) + m.group(3), text, flags=re.M)
    return text


def mask_jsx(raw):
    """Keep only string literals and JSX text, like scribb's Vale views."""
    keep = [False] * len(raw)
    for m in re.finditer(r"(\"(?:[^\"\\\n]|\\.)*\"|'(?:[^'\\\n]|\\.)*'|`(?:[^`\\]|\\.)*`)", raw):
        for i in range(m.start() + 1, m.end() - 1):
            keep[i] = True
    for m in re.finditer(r">([^<>{}]+)<", raw):
        for i in range(m.start(1), m.end(1)):
            keep[i] = True
    # Line comments and import paths aren't copy.
    for m in re.finditer(r"^\s*import\b.*$|//[^\n]*", raw, re.M):
        for i in range(m.start(), m.end()):
            keep[i] = False
    return "".join(c if keep[i] or c == "\n" else " " for i, c in enumerate(raw))


def line_col(text, pos):
    line = text.count("\n", 0, pos) + 1
    col = pos - (text.rfind("\n", 0, pos) + 1) + 1
    return line, col


# --- A small YAML subset: the forms scribb's pack.yaml and rule files use ---
# Also used by tools/build-chat.py.

def scalar(v):
    v = v.strip()
    if v.startswith("'") and v.endswith("'") and len(v) >= 2:
        return v[1:-1].replace("''", "'")
    if v.startswith('"') and v.endswith('"') and len(v) >= 2:
        return json.loads(v)
    if v in ("true", "false"):
        return v == "true"
    if v in ("null", "~", ""):
        return None
    if re.fullmatch(r"-?\d+", v):
        return int(v)
    if re.fullmatch(r"-?\d+\.\d+", v):
        return float(v)
    if v.startswith("[") and v.endswith("]"):
        inner = v[1:-1].strip()
        return [scalar(x) for x in re.findall(r"""'(?:[^']|'')*'|"(?:[^"\\]|\\.)*"|[^,]+""", inner)] if inner else []
    return v


def strip_comment(line):
    out, q = [], None
    for i, c in enumerate(line):
        if q:
            out.append(c)
            if c == q:
                q = None
        elif c in "'\"":
            q = c
            out.append(c)
        elif c == "#" and (i == 0 or line[i - 1] in " \t"):
            break
        else:
            out.append(c)
    return "".join(out).rstrip()


def parse_yaml(text):
    data, key, container = {}, None, None
    for raw in text.splitlines():
        line = strip_comment(raw)
        if not line.strip():
            continue
        if not line.startswith((" ", "\t", "-")):
            m = re.match(r"([A-Za-z_][\w-]*):\s*(.*)$", line)
            if not m:
                raise ValueError(f"can't parse line: {raw!r}")
            key, rest = m.group(1), m.group(2)
            if rest == "":
                data[key], container = None, key
            else:
                data[key], container = scalar(rest), None
            continue
        item = line.strip()
        if container is None:
            continue  # nested structure we don't need (for example sources:)
        if item.startswith("- "):
            if data[container] is None:
                data[container] = []
            if isinstance(data[container], list):
                data[container].append(scalar(item[2:]))
        else:
            # A key ends at the first colon followed by a space; a regex key
            # such as "utiliz(?:e|es)" has colons with no space after them.
            m = re.match(r"""((?:'(?:[^']|'')*')|(?:"(?:[^"\\]|\\.)*")|.+?):\s+(.*)$""", item)
            if m:
                if data[container] is None:
                    data[container] = {}
                if isinstance(data[container], dict):
                    data[container][str(scalar(m.group(1)))] = scalar(m.group(2))
    return data



def load_rules_dir(d):
    """Vale rules in <d>/checks/vale/<Style>/*.yml, such as rules promoted from memories."""
    rules = []
    vale = os.path.join(d, "checks", "vale")
    if not os.path.isdir(vale):
        return rules
    for style in sorted(os.listdir(vale)):
        sdir = os.path.join(vale, style)
        if style in ("tests", "config") or not os.path.isdir(sdir):
            continue
        for f in sorted(os.listdir(sdir)):
            if f.endswith(".yml"):
                with open(os.path.join(sdir, f), encoding="utf-8") as fh:
                    r = parse_yaml(fh.read())
                r["id"] = f"{style}.{f[:-4]}"
                if r.get("extends") in ("existence", "substitution", "occurrence", "capitalization"):
                    rules.append(r)
    return rules


# --- Rules ---------------------------------------------------------------------

def compile_tokens(rule, tokens):
    body = "|".join(tokens)
    if not rule.get("nonword"):
        body = r"\b(?:" + body + r")\b"
    else:
        body = "(?:" + body + ")"
    flags = re.I if rule.get("ignorecase") else 0
    return re.compile(body, flags)


def scopes(rule, prose, raw):
    """Yield (offset, text) chunks the rule applies to."""
    scope = rule.get("scope") or "text"
    if scope == "raw":
        yield 0, raw
    elif scope == "sentence":
        # Closing quotes and brackets stay with their sentence, as in Vale.
        for m in re.finditer(r"[^.!?\n]+(?:[.!?]+[\"'\u201d\u2019)\]]*|$)", prose, re.M):
            yield m.start(), m.group(0)
    elif scope == "paragraph":
        for m in re.finditer(r"(?:[^\n]*\S[^\n]*(?:\n|$))+", prose):
            yield m.start(), m.group(0)
    elif scope == "heading":
        for m in re.finditer(r"^#{1,6}[ \t]+(.+?)[ \t#]*$", prose, re.M):
            yield m.start(1), m.group(1)
    else:
        yield 0, prose


def fmt(message, *args):
    out = message
    for a in args:
        out = out.replace("%s", a, 1)
    return out


def sentence_case_ok(heading, rule, vocab):
    words = re.findall(r"[^\s]+", heading)
    words = [w.strip("()[]{}\"'*_,.!?") for w in words]
    words = [w for w in words if w and re.search(r"[A-Za-z]", w)]
    if not words:
        return True
    exceptions = set(rule.get("exceptions") or []) | set(vocab)
    indicators = rule.get("indicators") or []
    phrase_ex = [e for e in exceptions if " " in e]
    ok = 0
    prev = ""
    for i, w in enumerate(words):
        if w in exceptions or any(w in e.split() and e in heading for e in phrase_ex):
            ok += 1
        elif i == 0:
            # Like Vale: the first word must be title-cased ("Rotate"), unless
            # it's an exception. All-caps words count as wrong here.
            if not (w[0].isupper() and w[1:] == w[1:].lower()) and w[0].isalpha():
                return False
            ok += 1
        elif any(prev.endswith(ind) for ind in indicators):
            ok += 1
        elif w.isupper() and len(w) > 1:
            ok += 1  # acronyms
        elif not w[0].isupper():
            ok += 1
        prev = w
    threshold = float(rule.get("threshold", 0.8))
    return ok / len(words) >= threshold


def run_rule(rule, prose, raw, vocab):
    kind = rule["extends"]
    found = []
    if kind == "existence":
        rx = compile_tokens(rule, rule["tokens"])
        for off, chunk in scopes(rule, prose, raw):
            for m in rx.finditer(chunk):
                if m.group(0).strip() == "":
                    continue
                if any(m.group(0).lower() == v.lower() for v in vocab):
                    continue
                found.append((off + m.start(), fmt(rule["message"], m.group(0))))
    elif kind == "substitution":
        swap = rule["swap"]
        # Longest first, so "click on" wins over "click".
        keys = sorted(swap.keys(), key=len, reverse=True)
        rx = compile_tokens(rule, ["(" + k + ")" for k in keys])
        for off, chunk in scopes(rule, prose, raw):
            for m in rx.finditer(chunk):
                observed = m.group(0)
                expected = next((swap[k] for k in keys if re.fullmatch(k, observed, re.I if rule.get("ignorecase") else 0)), "")
                found.append((off + m.start(), fmt(rule["message"], expected, observed)))
    elif kind == "occurrence":
        rx = re.compile(rule["token"], re.I if rule.get("ignorecase") else 0)
        limit = int(rule.get("max", 0))
        for off, chunk in scopes(rule, prose, raw):
            hits = list(rx.finditer(chunk))
            if len(hits) > limit:
                found.append((off + hits[limit].start(), fmt(rule["message"], hits[limit].group(0))))
    elif kind == "capitalization":
        for off, chunk in scopes(rule, prose, raw):
            if rule.get("match") == "$sentence" and not sentence_case_ok(chunk, rule, vocab):
                found.append((off, fmt(rule["message"], chunk.strip())))
    return found


# --- Main -----------------------------------------------------------------------

def main(argv):
    ap = argparse.ArgumentParser(description="scribb.me checker without Vale")
    ap.add_argument("--content-type", required=True)
    ap.add_argument("--freedom")
    ap.add_argument("--style", default="none")
    ap.add_argument("--vocab", default="", help="comma-separated accepted terms")
    ap.add_argument("--format", choices=["md", "jsx"])
    ap.add_argument("--rules", default=os.path.join(HERE, "rules.json"))
    ap.add_argument("--rules-dir", action="append", default=[], help="also apply the Vale rules in this pack folder (repeatable)")
    ap.add_argument("--list", action="store_true", help="list content types and styles, then exit")
    ap.add_argument("file", nargs="?", default="-")
    args = ap.parse_args(argv)

    with open(args.rules, encoding="utf-8") as f:
        packs = json.load(f)
    if args.list:
        for pid, p in sorted(packs.items()):
            print(f"{pid}\t{p['kind']}\t{p.get('label') or ''}\t{p.get('tagline') or ''}")
        return 0
    ct = packs.get(args.content_type)
    if not ct or ct["kind"] != "content-type":
        names = ", ".join(sorted(k for k, p in packs.items() if p["kind"] == "content-type"))
        print(f"check.py: unknown content type '{args.content_type}'. Content types: {names}", file=sys.stderr)
        return 3
    freedom = args.freedom or ct.get("freedom") or "balanced"
    if freedom not in ACTIONS:
        print(f"check.py: freedom must be strict, balanced or expressive", file=sys.stderr)
        return 3

    active = [packs["base"], ct]
    if args.style and args.style != "none":
        st = packs.get(args.style)
        if not st or st["kind"] != "style":
            print(f"check.py: unknown style '{args.style}'; checking without it.", file=sys.stderr)
        else:
            active.append(st)

    for d in args.rules_dir:
        extra = load_rules_dir(d)
        if extra:
            active.append({"kind": "rules", "rules": extra})

    if args.file == "-":
        raw, name = sys.stdin.read(), "text"
    else:
        with open(args.file, encoding="utf-8") as f:
            raw = f.read()
        name = args.file
    form = args.format or ("jsx" if name.endswith((".jsx", ".tsx")) or (name == "text" and args.content_type == "ux-microcopy" and "<" in raw) else "md")
    prose = mask_jsx(raw) if form == "jsx" else mask_markdown(raw)
    vocab = [v.strip() for v in args.vocab.split(",") if v.strip()]

    findings = []
    for pack in active:
        for rule in pack["rules"]:
            sev = SEVERITY.get(rule.get("level", "suggestion"), "preference")
            for pos, msg in run_rule(rule, prose, raw, vocab):
                line, col = line_col(raw, pos)
                findings.append((line, col, ACTIONS[freedom][sev], sev, rule["id"], msg))

    blocked = False
    for line, col, act, sev, rid, msg in sorted(findings):
        blocked = blocked or act == "block"
        print(f"{name}:{line}:{col}:{act}:{sev}:{rid}:{msg}")
    return 1 if blocked else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

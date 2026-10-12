#!/usr/bin/env python3
"""Split a file into blocks by their nature, so each is checked as its own
content type.

Block kinds:
  prose     the Markdown or plain-text body (checked as the file's document type)
  ui-text   text a user reads in a JSX interface (checked as UI copy)
  comments  code comments and docstrings, in source files and in Markdown
            code fences (checked as code comments)

The file's extension, shebang or fence language only picks the comment syntax.
It never picks the content type.

Usage:
  blocks.py --list FILE       print the kinds FILE contains, one per line
  blocks.py FILE OUTDIR       write one file per kind to OUTDIR and print
                              "kind<TAB>path<TAB>cols" lines. A comments file has
                              the same lines as FILE, with everything that isn't
                              comment text blank; cols holds, per line, the
                              column offset to add to a finding.
Standard library only, so the built-in checker and Vale use the same blocks.
"""

import os
import re
import sys

C_LIKE = set("c h cc cpp cxx hpp hh m mm cs java kt kts go rs swift scala sc groovy gradle dart php "
             "js jsx mjs cjs ts tsx mts cts css scss less proto zig v sol".split())
HASH = set("py pyi pyw rb sh bash zsh fish ksh pl pm r yaml yml toml ex exs nim cr tf hcl "
           "ps1 jl coffee mk cmake".split())
DASH = set("sql lua hs elm ada".split())
JS = set("js jsx mjs cjs ts tsx mts cts".split())
# Languages where ' starts a string rather than a character literal.
QUOTE_STRINGS = JS | set("php dart css scss less py pyi pyw rb sh bash zsh fish ksh pl pm r yaml yml toml "
                         "ex exs nim cr tf hcl ps1 jl coffee groovy gradle sql lua".split())
SHELLISH = set("sh bash zsh fish ksh yaml yml toml mk cmake".split())  # '#' starts a comment only after space
MARKDOWN = set("md mdx markdown mdown mkd".split())
NAMES = {"dockerfile": "sh", "makefile": "mk", "rakefile": "rb", "gemfile": "rb", "justfile": "mk",
         "cmakelists.txt": "cmake", "vagrantfile": "rb", "brewfile": "rb"}
FENCE_LANGS = {"python": "py", "python3": "py", "py": "py", "shell": "sh", "console": "", "bash": "sh",
               "sh": "sh", "zsh": "sh", "ruby": "rb", "javascript": "js", "typescript": "ts", "golang": "go",
               "rust": "rs", "kotlin": "kt", "csharp": "cs", "c#": "cs", "c++": "cpp", "objective-c": "m",
               "yml": "yaml", "postgresql": "sql", "haskell": "hs", "docker": "sh", "dockerfile": "sh",
               "make": "mk", "makefile": "mk", "terraform": "tf", "elixir": "ex", "perl": "pl", "julia": "jl",
               "powershell": "ps1"}

DIRECTIVE = re.compile(
    r"^\s*(!|eslint|@ts-|prettier-|noqa|type:|pylint:|pyright:|mypy:|shellcheck |go:|nolint|istanbul |c8 |"
    r"jshint|tslint|biome-|region\b|endregion\b|#region|-\*-|vim?:|SPDX-|Copyright|@flow|@jsx|@refresh|"
    r"fmt:|isort:|rubocop:|frozen_string_literal|swiftlint:|NOSONAR|nosec|@generated|@license|#endregion)",
    re.I)
DECORATION = re.compile(r"^\s*[-=*#/_~+.<>|\\]{3,}\s*$")
JSX_TAG = re.compile(r"</[A-Za-z][\w.:-]*\s*>|<[A-Za-z][\w.:-]*(\s[^<>]*)?/>|<>|</>")


def lang_of(path, head):
    base = os.path.basename(path).lower()
    if base in NAMES:
        return NAMES[base]
    if "." in base:
        ext = base.rsplit(".", 1)[1]
        if ext in C_LIKE or ext in HASH or ext in DASH or ext in MARKDOWN:
            return ext
    if head.startswith("#!"):
        first = head.split("\n", 1)[0]
        if re.search(r"python", first):
            return "py"
        if re.search(r"\b(node|deno|bun|tsx|ts-node)\b", first):
            return "js"
        if re.search(r"\b(ruby)\b", first):
            return "rb"
        if re.search(r"\b(perl)\b", first):
            return "pl"
        if re.search(r"\b(bash|sh|zsh|ksh|dash|fish)\b", first):
            return "sh"
    return ""


def family(lang):
    if lang in C_LIKE:
        return "c"
    if lang in HASH:
        return "hash"
    if lang in DASH:
        return "dash"
    return ""


def raw_comments(lines, lang):
    """Yield (line_index, column, text, block) for each piece of comment text.

    block is True for lines inside /* */, docstrings and similar, so leading
    "*" decorations can be stripped.
    """
    fam = family(lang)
    quote_str = lang in QUOTE_STRINGS
    out = []
    state = None  # None, "block", "doc", "tick", "triple"
    end = ""
    heredoc = None
    for i, line in enumerate(lines):
        if heredoc is not None:
            if line.strip() == heredoc:
                heredoc = None
            continue
        if i == 0 and line.startswith("#!"):
            continue
        j = 0
        n = len(line)
        if state in ("block", "doc"):
            k = line.find(end)
            kind = state == "doc"
            if k < 0:
                out.append((i, 0, line, "doc" if kind else True))
                continue
            out.append((i, 0, line[:k], "doc" if kind else True))
            j = k + len(end)
            state = None
        elif state == "triple":
            k = line.find(end)
            if k < 0:
                continue
            j = k + 3
            state = None
        elif state == "tick":
            k = line.find("`")
            if k < 0:
                continue
            j = k + 1
            state = None
        # Python docstrings: a triple-quoted string that starts a line.
        if lang in ("py", "pyi", "pyw") and j == 0:
            m = re.match(r'^(\s*)([rRuUbB]{0,2})("""|\'\'\')', line)
            if m:
                q = m.group(3)
                start = m.end()
                k = line.find(q, start)
                if k >= 0:
                    out.append((i, start, line[start:k], "doc"))
                    j = k + 3
                else:
                    out.append((i, start, line[start:], "doc"))
                    state, end = "doc", q
                    continue
        while j < n:
            ch = line[j]
            two = line[j:j + 2]
            if fam == "c" and two == "/*":
                k = line.find("*/", j + 2)
                if k < 0:
                    out.append((i, j, line[j:], True))
                    state, end = "block", "*/"
                    j = n
                    break
                out.append((i, j, line[j:k], True))
                j = k + 2
                continue
            if fam == "c" and two == "//" and (j == 0 or line[j - 1] != ":"):
                out.append((i, j, line[j:], False))
                break
            if fam == "hash" and ch == "#":
                if lang in SHELLISH and j > 0 and not line[j - 1].isspace():
                    j += 1
                    continue
                if lang in ("sh", "bash", "zsh", "ksh") and j > 0 and line[j - 1] in "${":
                    j += 1
                    continue
                out.append((i, j, line[j:], False))
                break
            if fam == "dash" and two == "--":
                rest = line[j + 2:]
                if lang == "lua" and rest.startswith("[["):
                    k = line.find("]]", j + 4)
                    if k < 0:
                        out.append((i, j, line[j:], True))
                        state, end = "block", "]]"
                        j = n
                        break
                    out.append((i, j, line[j:k], True))
                    j = k + 2
                    continue
                out.append((i, j, line[j:], False))
                break
            if fam == "dash" and lang == "hs" and two == "{-":
                k = line.find("-}", j + 2)
                if k < 0:
                    out.append((i, j, line[j:], True))
                    state, end = "block", "-}"
                    j = n
                    break
                out.append((i, j, line[j:k], True))
                j = k + 2
                continue
            if fam == "hash" and lang in ("sh", "bash", "zsh", "ksh"):
                m = re.match(r"<<-?\s*['\"]?([A-Za-z_]\w*)['\"]?", line[j:])
                if m:
                    heredoc = m.group(1)
                    j += m.end()
                    continue
            if line.startswith('"""', j) or line.startswith("'''", j):
                q = line[j:j + 3]
                if lang in ("py", "pyi", "pyw", "kt", "kts", "swift", "scala", "groovy", "java", "jl", "dart"):
                    k = line.find(q, j + 3)
                    if k < 0:
                        state, end = "triple", q
                        j = n
                        break
                    j = k + 3
                    continue
            if ch == "`" and (lang in JS or lang == "go"):
                k = line.find("`", j + 1)
                if k < 0:
                    state = "tick"
                    j = n
                    break
                j = k + 1
                continue
            if ch == '"' or (ch == "'" and quote_str):
                k = j + 1
                while k < n and line[k] != ch:
                    k += 2 if line[k] == "\\" else 1
                j = k + 1
                continue
            if ch == "'":  # a character literal, or a Rust lifetime
                m = re.match(r"'(\\.[^']{0,8}|[^\\'])'", line[j:])
                j += m.end() if m else 1
                continue
            j += 1
    return out


def strip_marker(text, block):
    """Remove comment markers. Returns (text, columns removed)."""
    if block == "doc":
        return text.rstrip(), 0
    m = None
    if block:
        m = re.match(r"^(\s*(/\*\*?!?|\{-\|?|--\[\[)?\s*\*?(?!\*)\s?)", text)
    else:
        m = re.match(r"^(\s*(///?!?|#+!?|--) ?)", text)  # a tab after // is Go's code marker
    cut = len(m.group(1)) if m else 0
    body = text[cut:]
    if block:
        body = re.sub(r"\s+\*+$", "", body.rstrip())
    return body.rstrip(), cut


def comment_lines(lines, lang):
    """Map line index -> (column offset, text) of the comment text on it."""
    found = {}
    seen = set()
    for i, col, text, block in raw_comments(lines, lang):
        seen.add(i)
        body, cut = strip_marker(text, block)
        body = body.expandtabs(4)
        if not body.strip() or DECORATION.match(body) or DIRECTIVE.match(body):
            continue
        if re.match(r"^\s*(>>>|\.\.\.)\s", body):  # doctest
            continue
        if i in found:  # a second comment on the same line
            found[i] = (found[i][0], found[i][1] + " " + body.strip())
        else:
            found[i] = (col + cut, body)
    # Keep code examples inside comments out of the prose: lines indented 4+
    # columns deeper than their neighbours stay indented (Markdown code), the
    # rest lose their indentation.
    keys = sorted(found)
    groups, cur = [], []
    for k in keys:
        if cur and any(x not in seen for x in range(cur[-1] + 1, k)):
            groups.append(cur)
            cur = []
        cur.append(k)
    if cur:
        groups.append(cur)
    for g in groups:
        indents = [len(found[k][1]) - len(found[k][1].lstrip()) for k in g]
        base = min(indents)
        for k, ind in zip(g, indents):
            col, body = found[k]
            if lang in ("py", "pyi", "pyw") or ind - base < 4:
                found[k] = (col + ind, body.lstrip())
            else:
                found[k] = (col + base, "    " + body.lstrip())
    return found


def markdown_fences(lines):
    """Yield (lang, start, end) for each fenced code block (body lines start..end-1)."""
    i, n = 0, len(lines)
    while i < n:
        m = re.match(r"^\s{0,3}(`{3,}|~{3,})\s*([\w#+.-]*)", lines[i])
        if not m:
            i += 1
            continue
        fence, info = m.group(1), m.group(2).lower()
        j = i + 1
        while j < n and not re.match(r"^\s{0,3}" + re.escape(fence[0]) + "{" + str(len(fence)) + r",}\s*$", lines[j]):
            j += 1
        lang = FENCE_LANGS.get(info, info)
        yield lang, i + 1, j
        i = j + 1


def analyse(path):
    try:
        data = open(path, "rb").read()
    except OSError:
        return None
    if b"\0" in data[:8192]:
        return None
    raw = data.decode("utf-8", "replace")
    lines = raw.split("\n")
    lang = lang_of(path, raw[:200])
    result = {"lang": lang, "lines": lines, "kinds": [], "comments": {}}
    if family(lang):
        result["comments"] = comment_lines(lines, lang)
        if lang in JS:
            code = list(lines)
            for i, col, _text, _block in raw_comments(lines, lang):
                code[i] = code[i][:col] if len(code[i]) >= col else code[i]
            if JSX_TAG.search("\n".join(code)):
                result["kinds"].append("ui-text")
    else:
        result["kinds"].append("prose")
        if lang in MARKDOWN or not lang:
            for flang, a, b in markdown_fences(lines):
                if not family(flang):
                    continue
                for k, v in comment_lines(lines[a:b], flang).items():
                    result["comments"][a + k] = v
    if result["comments"]:
        result["kinds"].append("comments")
    return result


def main(argv):
    if len(argv) == 3 and argv[1] == "--list":
        r = analyse(argv[2])
        for k in (r or {}).get("kinds", []):
            print(k)
        return 0
    if len(argv) != 3:
        sys.stderr.write(__doc__)
        return 3
    path, outdir = argv[1], argv[2]
    r = analyse(path)
    if not r:
        return 0
    os.makedirs(outdir, exist_ok=True)
    stem = os.path.join(outdir, "%08x" % (hash(os.path.abspath(path)) & 0xffffffff))
    for kind in r["kinds"]:
        if kind == "prose":
            print("prose\t%s\t" % path)
        elif kind == "ui-text":
            copy = stem + "-ui.jsx"  # Vale's JSX grammar sees JSX text; TypeScript's doesn't
            with open(copy, "w", encoding="utf-8") as fh:
                fh.write("\n".join(r["lines"]))
            print("ui-text\t%s\t" % copy)
        elif kind == "comments":
            shadow, cols = stem + "-comments.md", stem + "-comments.cols"
            with open(shadow, "w", encoding="utf-8") as fh, open(cols, "w") as fc:
                for i in range(len(r["lines"])):
                    col, text = r["comments"].get(i, (0, ""))
                    fh.write(text + "\n")
                    fc.write("%d\n" % col)
            print("comments\t%s\t%s" % (shadow, cols))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

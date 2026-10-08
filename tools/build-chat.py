#!/usr/bin/env python3
"""Build plugin-chat/, the scribb-chat plugin for claude.ai chat.

scribb ships two plugins from one source. plugin/ is for Claude Code (hooks,
agents, helper scripts). plugin-chat/ is for claude.ai chat, which loads only
skills, and gives each skill only its own folder. So every chat skill carries
what it needs:
  references/   the packs' guides, summaries, samples, formats and role maps
  scripts/      check.py (the checker without Vale) and rules.json

Sources: plugin/packs/ (the packs), tools/chat/skills/*/SKILL.md (the chat
skills, with {{REFERENCES}}, {{CHECK}}, {{SELF_REVIEW}} and {{CAPTURE}} filled
in from tools/chat/partials/) and tools/chat/check.py. Don't edit plugin-chat/.
  python3 tools/build-chat.py           # regenerate plugin-chat/
  python3 tools/build-chat.py --check   # fail if plugin-chat/ is out of date (CI)
"""

import filecmp
import json
import os
import re
import shutil
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PACKS = os.path.join(ROOT, "plugin", "packs")
OUT = os.path.join(ROOT, "plugin-chat")
SOURCES = os.path.join(ROOT, "tools", "chat", "skills")
PARTIALS = os.path.join(ROOT, "tools", "chat", "partials")
CHECKER = os.path.join(ROOT, "tools", "chat", "check.py")


# --- A small YAML subset: the forms scribb's pack.yaml and rule files use ---

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


# --- Build ---------------------------------------------------------------------

def pack_dirs():
    yield os.path.join(PACKS, "base")
    for kind in ("content-types", "styles"):
        d = os.path.join(PACKS, kind)
        for name in sorted(os.listdir(d)):
            if os.path.isfile(os.path.join(d, name, "pack.yaml")):
                yield os.path.join(d, name)


def compile_rules():
    out = {}
    for d in pack_dirs():
        meta = parse_yaml(open(os.path.join(d, "pack.yaml"), encoding="utf-8").read())
        rules = []
        vale = os.path.join(d, "checks", "vale")
        if os.path.isdir(vale):
            for style in sorted(os.listdir(vale)):
                sdir = os.path.join(vale, style)
                if style in ("tests", "config") or not os.path.isdir(sdir):
                    continue
                for f in sorted(os.listdir(sdir)):
                    if f.endswith(".yml"):
                        r = parse_yaml(open(os.path.join(sdir, f), encoding="utf-8").read())
                        r["id"] = f"{style}.{f[:-4]}"
                        rules.append(r)
        out[meta["id"]] = {
            "kind": meta.get("kind"),
            "label": meta.get("label"),
            "tagline": meta.get("tagline"),
            "freedom": meta.get("freedom"),
            "version": meta.get("version"),
            "rules": rules,
        }
    return out


def copy_references(dest):
    for d in pack_dirs():
        rel = os.path.relpath(d, PACKS)
        target = os.path.join(dest, rel)
        os.makedirs(target, exist_ok=True)
        for name in ("pack.yaml", "summary.md", "guide.md", "sample.md"):
            src = os.path.join(d, name)
            if os.path.isfile(src):
                shutil.copy2(src, os.path.join(target, name))
        for sub in ("formats", "roles"):
            src = os.path.join(d, sub)
            if os.path.isdir(src):
                shutil.copytree(src, os.path.join(target, sub))


def manifest():
    main = json.load(open(os.path.join(ROOT, "plugin", ".claude-plugin", "plugin.json"), encoding="utf-8"))
    return {
        "name": "scribb-chat",
        "displayName": "scribb.me for chat",
        "version": main["version"],
        "description": "scribb.me for claude.ai chat: write and review docs, UI copy and newsletters without AI writing habits, with a built-in checker. For Claude Code, use the scribb plugin.",
        "author": main.get("author"),
        "homepage": main.get("homepage"),
        "repository": main.get("repository"),
        "license": main.get("license"),
        "keywords": main.get("keywords"),
        # Plugins added on claude.ai also sync into Claude Code; there the
        # full scribb plugin does this job, so the synced copy starts off.
        "defaultEnabled": False,
    }


README = """# scribb.me for chat

This is the claude.ai chat version of scribb.me, a writing-style plugin for docs, UI copy and newsletters. It helps Claude write and review without AI writing habits, following the conventions of each kind of writing, and checks drafts with a built-in checker.

## Use it
Ask for a piece of writing and scribb's guidance applies on its own, or pick a skill from the `/` menu:
- **scribb-write**: draft, check, review and revise a piece.
- **scribb-review**: review pasted or uploaded text.
- **scribb-learn**: learn a style from your samples.
- **scribb-remember**: save a preference for future chats.
- **scribb-styles**: compare the built-in styles.
- **scribb-report**: report a problem.

The checker runs when code execution is available. For checks after every edit, team settings and memories, use the scribb plugin in Claude Code.

## Data
scribb sends nothing anywhere. Its rules and guides are files in this plugin.

This folder is generated from https://github.com/Saleschat/scribb-me by tools/build-chat.py; don't edit it by hand.
"""


def fill(text):
    parts = {name: open(os.path.join(PARTIALS, f"{name.lower().replace('_', '-')}.md"), encoding="utf-8").read().strip()
             for name in ("REFERENCES", "CHECK", "SELF_REVIEW", "CAPTURE")}
    for name, body in parts.items():
        text = text.replace("{{" + name + "}}", body)
    left = re.findall(r"\{\{[A-Z_]+\}\}", text)
    if left:
        raise SystemExit(f"build-chat: unknown placeholder {left[0]}")
    return text


def build_into(out):
    shutil.rmtree(out, ignore_errors=True)
    os.makedirs(os.path.join(out, ".claude-plugin"))
    with open(os.path.join(out, ".claude-plugin", "plugin.json"), "w", encoding="utf-8") as f:
        f.write(json.dumps(manifest(), indent=2, ensure_ascii=False) + "\n")
    with open(os.path.join(out, "README.md"), "w", encoding="utf-8") as f:
        f.write(README)
    shutil.copy2(os.path.join(ROOT, "LICENSE"), os.path.join(out, "LICENSE"))
    shutil.copy2(os.path.join(ROOT, "plugin", "NOTICE.md"), os.path.join(out, "NOTICE.md"))
    rules = json.dumps(compile_rules(), indent=1, ensure_ascii=False, sort_keys=True) + "\n"
    for name in sorted(os.listdir(SOURCES)):
        src = os.path.join(SOURCES, name, "SKILL.md")
        if not os.path.isfile(src):
            continue
        raw = open(src, encoding="utf-8").read()
        sdir = os.path.join(out, "skills", name)
        os.makedirs(sdir)
        with open(os.path.join(sdir, "SKILL.md"), "w", encoding="utf-8") as f:
            f.write(fill(raw))
        if "{{REFERENCES}}" in raw:
            copy_references(os.path.join(sdir, "references"))
        if "{{CHECK}}" in raw:
            os.makedirs(os.path.join(sdir, "scripts"))
            shutil.copy2(CHECKER, os.path.join(sdir, "scripts", "check.py"))
            with open(os.path.join(sdir, "scripts", "rules.json"), "w", encoding="utf-8") as f:
                f.write(rules)


def same_tree(a, b):
    cmp = filecmp.dircmp(a, b, ignore=["__pycache__", ".DS_Store"])
    if cmp.left_only or cmp.right_only or cmp.funny_files:
        return False
    for f in cmp.common_files:
        if not filecmp.cmp(os.path.join(a, f), os.path.join(b, f), shallow=False):
            return False
    return all(same_tree(os.path.join(a, d), os.path.join(b, d)) for d in cmp.common_dirs)


def main():
    if "--check" in sys.argv:
        tmp = tempfile.mkdtemp()
        try:
            build_into(os.path.join(tmp, "plugin-chat"))
            ok = os.path.isdir(OUT) and same_tree(os.path.join(tmp, "plugin-chat"), OUT)
        finally:
            shutil.rmtree(tmp)
        if not ok:
            print("build-chat: plugin-chat/ is out of date. Run: python3 tools/build-chat.py")
            return 1
        print("build-chat: plugin-chat/ is up to date.")
        return 0
    build_into(OUT)
    skills = sorted(os.listdir(os.path.join(OUT, "skills")))
    print(f"build-chat: built plugin-chat/ with {len(compile_rules())} packs and skills {', '.join(skills)}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Parity tests for the chat checker (tools/chat/check.py).

1. Every Vale rule test pair: the bad file must trigger the rule and the good
   file must not, exactly as evals/rules/run.sh requires of Vale.
2. With Vale installed: over every rule test and every pack's text, the chat
   checker must report the same (file, line, rule) findings as Vale.
Usage: python3 tests/chat/parity.py   (run python3 tools/build-chat.py first)
"""

import glob
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "tools", "chat"))
import check  # noqa: E402

PACKS = os.path.join(ROOT, "plugin", "packs")
RULES = json.load(open(os.path.join(ROOT, "plugin", "skills", "write", "scripts", "rules.json"), encoding="utf-8"))
fails = []
passed = 0


def findings_for(rule, path):
    raw = open(path, encoding="utf-8").read()
    form = "jsx" if path.endswith((".jsx", ".tsx")) else "md"
    prose = check.mask_jsx(raw) if form == "jsx" else check.mask_markdown(raw)
    return [check.line_col(raw, pos)[0] for pos, _ in check.run_rule(rule, prose, raw, [])]


def pack_dir_of(style):
    for d in glob.glob(os.path.join(PACKS, "**", "checks", "vale", style), recursive=True):
        return os.path.dirname(os.path.dirname(os.path.dirname(d)))


# 1. Rule test pairs
for pid, pack in RULES.items():
    for rule in pack["rules"]:
        style, name = rule["id"].split(".")
        tests = os.path.join(pack_dir_of(style), "checks", "vale", "tests")
        for kind in ("bad", "good"):
            for f in glob.glob(os.path.join(tests, f"{name}.{kind}.*")):
                hits = findings_for(rule, f)
                ok = bool(hits) if kind == "bad" else not hits
                if ok:
                    passed += 1
                else:
                    fails.append(f"{rule['id']}: {os.path.relpath(f, ROOT)} ({kind}) {'missed' if kind == 'bad' else 'fired on lines ' + str(hits)}")

# 2. Parity with Vale on all pack text
TEMPLATE = os.path.join(ROOT, "plugin", "lib", "vale-line.tmpl")
if shutil.which("vale"):
    corpus = sorted(set(
        glob.glob(os.path.join(PACKS, "**", "checks", "vale", "tests", "*.*"), recursive=True)
        + [f for f in glob.glob(os.path.join(PACKS, "**", "*.md"), recursive=True) if "/checks/" not in f]
    ))
    tmp = tempfile.mkdtemp()
    try:
        styles = os.path.join(tmp, "styles")
        os.makedirs(os.path.join(styles, "config", "views"))
        names = []
        for d in glob.glob(os.path.join(PACKS, "**", "checks", "vale", "*"), recursive=True):
            b = os.path.basename(d)
            if b in ("tests", "config") or not os.path.isdir(d):
                if b == "config":
                    for v in glob.glob(os.path.join(d, "views", "*.yml")):
                        shutil.copy(v, os.path.join(styles, "config", "views"))
                continue
            os.symlink(d, os.path.join(styles, b))
            names.append(b)
        all_rules = [r for p in RULES.values() for r in p["rules"]]
        for f in corpus:
            ext = f.rsplit(".", 1)[-1]
            lint = f
            if ext == "tsx":  # scribb-check lints a .jsx copy of .tsx files
                lint = os.path.join(tmp, "copy.jsx")
                shutil.copy(f, lint)
                ext = "jsx"
            ini = os.path.join(tmp, "vale.ini")
            view = {"jsx": "JSXCopy"}.get(ext, "")
            with open(ini, "w") as fh:
                fh.write(f"StylesPath = {styles}\nMinAlertLevel = suggestion\n[*.{ext}]\nBasedOnStyles = {', '.join(sorted(names))}\n")
                if view:
                    fh.write(f"View = {view}\n")
            out = subprocess.run(["vale", f"--config={ini}", f"--output={TEMPLATE}", lint], capture_output=True, text=True).stdout
            vale_hits = set()
            for line in out.splitlines():
                parts = line.split("\t")
                if len(parts) >= 5:
                    vale_hits.add((int(parts[1]), parts[4]))
            ours = set()
            for r in all_rules:
                for ln in findings_for(r, f):
                    ours.add((ln, r["id"]))
            rel = os.path.relpath(f, ROOT)
            if vale_hits == ours:
                passed += 1
            else:
                only_v = sorted(vale_hits - ours)
                only_c = sorted(ours - vale_hits)
                fails.append(f"parity {rel}: only Vale {only_v[:4]} only chat {only_c[:4]}")
    finally:
        shutil.rmtree(tmp)
else:
    print("(Vale not installed: skipping the Vale parity pass)")

# 3. Mixed files: scribb-check splits each file into blocks (prose, UI text,
# comments) and checks each as its own content type. Both engines must agree.
FIXTURES = os.path.join(ROOT, "tests", "chat", "fixtures")
CHECK = os.path.join(ROOT, "plugin", "scripts", "scribb-check")


def scribb_check(engine, path, home):
    env = dict(os.environ, HOME=home, SCRIBB_STATE_DIR=os.path.join(home, "state"), CLAUDE_PROJECT_DIR=FIXTURES)
    env.pop("CLAUDE_PLUGIN_ROOT", None)
    os.makedirs(os.path.join(home, ".config", "scribb"), exist_ok=True)
    with open(os.path.join(home, ".config", "scribb", "config.yaml"), "w") as fh:
        fh.write(f"checker: {engine}\n")
    out = subprocess.run([CHECK, path], capture_output=True, text=True, cwd=FIXTURES, env=env).stdout
    return {(int(l.split(":")[1]), l.split(":")[5]) for l in out.splitlines() if l.count(":") >= 6}


if shutil.which("vale"):
    home = tempfile.mkdtemp()
    try:
        for f in sorted(glob.glob(os.path.join(FIXTURES, "*"))):
            v, b = scribb_check("vale", f, home), scribb_check("builtin", f, home)
            rel = os.path.relpath(f, ROOT)
            if not any(rule.startswith("ScribbCodeComments.") for _, rule in v):
                fails.append(f"blocks {rel}: no code-comment findings (each fixture has one)")
            elif v == b:
                passed += 1
            else:
                fails.append(f"blocks {rel}: only Vale {sorted(v - b)[:4]} only built-in {sorted(b - v)[:4]}")
    finally:
        shutil.rmtree(home)

for f in fails:
    print("FAIL", f)
print(f"chat checker parity: {passed} passed, {len(fails)} failed")
sys.exit(1 if fails else 0)

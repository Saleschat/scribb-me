#!/usr/bin/env bash
# Tests for the Claude Code hook adapter and the helper scripts.
# Each test runs in a throwaway project, home and state dir.
# Usage: tests/hooks/run.sh   (needs Vale for the checker tests; jq optional)
set -u

REPO=$(cd "$(dirname "$0")/../.." && pwd)
PLUGIN="$REPO/plugin"
HOOK="$PLUGIN/hooks/scribb-hook"
pass=0 fail=0

ok() { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n' "$1"; [ -n "${2:-}" ] && printf '       %s\n' "$2"; }

# assert NAME COMMAND...: passes when the command succeeds.
assert() {
  local name="$1"
  shift
  if "$@"; then ok "$name"; else bad "$name"; fi
}

# refute NAME COMMAND...: passes when the command fails.
refute() {
  local name="$1"
  shift
  if "$@"; then bad "$name"; else ok "$name"; fi
}

yaml_val() { sed -n "s/^$2:[[:space:]]*//p" "$1" 2>/dev/null | tail -n 1; }

contains() { case "$1" in *"$2"*) return 0 ;; esac; return 1; }
valid_json() {
  [ -z "$1" ] && return 0
  if command -v jq >/dev/null 2>&1; then printf '%s' "$1" | jq -e . >/dev/null 2>&1; else return 0; fi
}

setup() {
  T=$(mktemp -d)
  mkdir -p "$T/proj/docs" "$T/home"
  git -C "$T/proj" init -q
  export HOME="$T/home" SCRIBB_STATE_DIR="$T/state" CLAUDE_PROJECT_DIR="$T/proj" CLAUDE_PLUGIN_ROOT="$PLUGIN"
  unset SCRIBB_DISABLE SCRIBB_HOME XDG_CONFIG_HOME
  cd "$T/proj" || exit 1
}

teardown() {
  cd "$REPO" || exit 1
  rm -rf "$T"
}

edit_input() { # session file [content]
  printf '{"session_id":"%s","cwd":"%s","hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s","content":"%s"}}' "$1" "$T/proj" "$2" "${3:-x}"
}

run_hook() { # event input
  printf '%s' "$2" | "$HOOK" "$1"
}

BAD_DOC='# Getting Started With The API

Let us dive in. Great question! This guide will delve into it.'

GOOD_DOC='# Rotate an API key

Create a new key, update your services to use it, then delete the old key.'

have_vale() { command -v vale >/dev/null 2>&1; }

for jqmode in jq nojq; do
  if [ "$jqmode" = nojq ]; then
    export SCRIBB_NO_JQ=1
  else
    unset SCRIBB_NO_JQ
    command -v jq >/dev/null 2>&1 || continue
  fi
  echo "== JSON via $jqmode"

  # --- session-start ---
  setup
  out=$(run_hook session-start '{"session_id":"s1","cwd":"'"$T/proj"'","source":"startup"}')
  assert "session-start: valid JSON" valid_json "$out"
  assert "session-start: injects base rules" contains "$out" "Base rules (always on)"
  assert "session-start: says how to turn scribb off" contains "$out" "/scribb:style off"
  mkdir -p .scribb/memories
  printf -- '---\nid: t\nkind: term\nscope: project\nstatement: Say "workspace", never "account".\nconfidence: 0.8\n---\n' > .scribb/memories/t.md
  out=$(run_hook session-start '{"session_id":"s2","cwd":"'"$T/proj"'","source":"startup"}')
  assert "session-start: injects memories" contains "$out" 'never \"account\"'
  mkdir -p .scribb/local/inbox
  for i in 1 2 3; do echo x > ".scribb/local/inbox/$i.md"; done
  out=$(run_hook session-start '{"session_id":"s3","cwd":"'"$T/proj"'","source":"startup"}')
  assert "session-start: inbox-ready nudge at 3 signals" contains "$out" "/scribb:learn inbox"
  teardown

  # --- content types from packs ---
  setup
  ct() { bash -c '. "$1/lib/scribb.sh"; SCRIBB_PROJECT=$(scribb_project_dir); content_type_for "$2"' _ "$PLUGIN" "$1"; }
  mkdir -p newsletter/2026 docs src
  assert "content type: docs/*.md is Product docs" [ "$(ct docs/a.md)" = product-docs ]
  assert "content type: README.md is Product docs" [ "$(ct README.md)" = product-docs ]
  assert "content type: developer docs have no default folder" [ "$(ct docs/api/keys.md)" = product-docs ]
  printf -- '---\ndescription: Revoke a key\nscribb-content-type: developer-docs\n---\n# Revoke a key\n' > docs/revoke.md
  assert "content type: frontmatter picks Developer docs" [ "$(ct docs/revoke.md)" = developer-docs ]
  printf -- '---\nscribb-content-type: poetry\n---\n# Hi\n' > docs/odd.md
  assert "content type: unknown frontmatter value is ignored" [ "$(ct docs/odd.md)" = product-docs ]
  printf -- '# Not frontmatter\n\nscribb-content-type: developer-docs\n' > docs/body.md
  assert "content type: the key only counts in frontmatter" [ "$(ct docs/body.md)" = product-docs ]
  assert "content type: *.tsx is UI copy" [ "$(ct src/A.tsx)" = ux-microcopy ]
  assert "content type: newsletter/ beats *.md" [ "$(ct newsletter/2026/issue-12.md)" = newsletter ]
  assert "content type: other files have none" [ -z "$(ct src/a.py)" ]
  mkdir -p .scribb && echo "paths_newsletter: emails/*" > .scribb/config.yaml && mkdir -p emails
  assert "content type: paths_<id> overrides pack paths" [ "$(ct emails/welcome.md)" = newsletter ]
  assert "content type: and replaces the defaults" [ "$(ct newsletter/2026/issue-12.md)" = product-docs ]
  echo "paths_developer_docs: reference/*" >> .scribb/config.yaml && mkdir -p reference
  assert "content type: setup can map developer docs folders" [ "$(ct reference/cli.md)" = developer-docs ]
  out=$(run_hook session-start '{"session_id":"s1","cwd":"'"$T/proj"'","source":"startup"}')
  assert "session-start: lists the newsletter content type" contains "$out" "Newsletter (emails/*"
  teardown

  # --- post-edit: nudges and the reviewer trigger ---
  setup
  # A root-level Markdown file must not turn the "*.md" pattern into a file name.
  echo "# Readme" > README.md
  out=$(run_hook post-edit "$(edit_input s1 "$T/proj/docs/a.md")")
  assert "post-edit: valid JSON" valid_json "$out"
  assert "post-edit: on-by-default nudge to the user" contains "$out" '"systemMessage":"scribb.me is checking'
  out=$(run_hook post-edit "$(edit_input s1 "$T/proj/docs/a.md")")
  assert "post-edit: one nudge per session" [ -z "$out" ]
  out=$(run_hook post-edit "$(edit_input s2 "$T/proj/docs/a.md")")
  refute "post-edit: on-by-default shown once ever" contains "$out" "on by default"
  assert "post-edit: next session gets pick-style" contains "$out" "/scribb:learn"
  out=$(run_hook post-edit "$(edit_input s3 "$T/proj/src.py")")
  assert "post-edit: ignores non-prose files" [ -z "$out" ]
  out=$(run_hook post-edit "$(edit_input s3 "$T/proj/node_modules/x/README.md")")
  assert "post-edit: ignores node_modules" [ -z "$out" ]
  long=$(awk 'BEGIN { for (i = 0; i < 160; i++) printf "word "; }')
  out=$(run_hook post-edit "$(edit_input s4 "$T/proj/docs/b.md" "$long")")
  assert "post-edit: big edit asks for a review" contains "$out" "scribb-reviewer"
  out=$(run_hook post-edit "$(edit_input s4 "$T/proj/docs/b.md" "$long")")
  refute "post-edit: review asked once per file per session" contains "$out" "scribb-reviewer"
  teardown

  # --- nudges: opt-out keeps the on-by-default nudge ---
  setup
  mkdir -p "$HOME/.config/scribb"
  echo "nudges: off" > "$HOME/.config/scribb/config.yaml"
  out=$(run_hook post-edit "$(edit_input s1 "$T/proj/docs/a.md")")
  assert "nudges off: on-by-default still shown" contains "$out" "on by default"
  out=$(run_hook post-edit "$(edit_input s2 "$T/proj/docs/a.md")")
  refute "nudges off: no other nudges" contains "$out" "/scribb:learn"
  teardown

  # --- prompt capture ---
  setup
  out=$(run_hook prompt '{"session_id":"s1","cwd":"'"$T/proj"'","prompt":"Don'"'"'t say \"account\", we call it a workspace"}')
  assert "prompt: valid JSON" valid_json "$out"
  assert "prompt: offers to remember" contains "$out" "/scribb:remember"
  assert "prompt: writes an inbox signal" [ "$(find .scribb/local/inbox -name '*.md' | wc -l | tr -d ' ')" = 1 ]
  assert "prompt: local dir ignores itself" [ -z "$(git status --porcelain)" ]
  out=$(run_hook prompt '{"session_id":"s1","cwd":"'"$T/proj"'","prompt":"Add a retry to the upload function"}')
  assert "prompt: ignores ordinary prompts" [ -z "$out" ]
  mkdir -p .scribb && echo "capture: off" > .scribb/config.yaml
  out=$(run_hook prompt '{"session_id":"s1","cwd":"'"$T/proj"'","prompt":"too formal, rewrite it"}')
  assert "prompt: capture off" [ -z "$out" ]
  teardown

  # --- kill switches ---
  setup
  out=$(SCRIBB_DISABLE=1 run_hook post-edit "$(edit_input s1 "$T/proj/docs/a.md")")
  assert "SCRIBB_DISABLE=1 silences hooks" [ -z "$out" ]
  out=$(SCRIBB_DISABLE=1 run_hook session-start '{"session_id":"s1","cwd":"'"$T/proj"'"}')
  assert "SCRIBB_DISABLE=1 silences session start" [ -z "$out" ]
  "$PLUGIN/bin/scribb-config" off --session s5 >/dev/null
  out=$(run_hook post-edit "$(edit_input s5 "$T/proj/docs/a.md")")
  assert "off for a session" [ -z "$out" ]
  out=$(run_hook post-edit "$(edit_input s6 "$T/proj/docs/a.md")")
  assert "other sessions still on" [ -n "$out" ]
  "$PLUGIN/bin/scribb-config" off --repo >/dev/null
  out=$(run_hook session-start '{"session_id":"s7","cwd":"'"$T/proj"'"}')
  assert "off for this repo (local scope)" [ -z "$out" ]
  assert "status says off" contains "$("$PLUGIN/bin/scribb-config" status)" "is OFF"
  "$PLUGIN/bin/scribb-config" off --session s10 --everywhere >/dev/null
  assert "off: --everywhere wins over --session, in any order" [ "$(yaml_val "$HOME/.config/scribb/config.yaml" enabled)" = false ]
  "$PLUGIN/bin/scribb-config" on --everywhere --session s10 >/dev/null
  assert "on: --everywhere wins over --session" [ "$(yaml_val "$HOME/.config/scribb/config.yaml" enabled)" = true ]
  refute "off: --session with a scope flag doesn't write the session" [ -f "$SCRIBB_STATE_DIR/sessions/s10.yaml" ]
  "$PLUGIN/bin/scribb-config" on --repo >/dev/null
  out=$(run_hook session-start '{"session_id":"s8","cwd":"'"$T/proj"'"}')
  assert "on again" [ -n "$out" ]
  teardown

  # --- config ---
  setup
  "$PLUGIN/bin/scribb-config" set freedom balanced --scope user >/dev/null
  "$PLUGIN/bin/scribb-config" set freedom expressive --scope local >/dev/null
  assert "config: local beats user" [ "$("$PLUGIN/bin/scribb-config" get freedom)" = expressive ]
  refute "config: rejects bad values" "$PLUGIN/bin/scribb-config" set freedom wild --scope user 2>/dev/null
  refute "config: rejects unknown styles" "$PLUGIN/bin/scribb-config" set style nope --scope user 2>/dev/null
  assert "config: accepts built-in styles" "$PLUGIN/bin/scribb-config" set style crisp-product-ui --scope project >/dev/null
  assert "config: accepts content types from packs" "$PLUGIN/bin/scribb-config" set content_type newsletter --scope user >/dev/null
  refute "config: rejects unknown content types" "$PLUGIN/bin/scribb-config" set content_type poetry --scope user 2>/dev/null
  mkdir -p "$HOME/.config/scribb/packs/styles/my-voice"
  printf 'id: my-voice\nkind: style\nversion: 0.1.0\ntagline: Mine.\nlicense: MIT\n' > "$HOME/.config/scribb/packs/styles/my-voice/pack.yaml"
  assert "packs: a user style in packs/styles/ is found" "$PLUGIN/bin/scribb-config" set style my-voice --scope user >/dev/null
  ( cd "$T/proj" && "$PLUGIN/bin/scribb-config" record-approval project "Say board." ) >/dev/null
  mkdir -p "$T/other" && git -C "$T/other" init -q
  out=$(cd "$T/other" && CLAUDE_PROJECT_DIR="$T/other" "$PLUGIN/bin/scribb-config" record-approval project "Say board.")
  assert "approvals: counts repos that approved a statement" contains "$out" "Approved in 2 repo(s)"
  out=$("$PLUGIN/bin/scribb-guide" --content-type product-docs --format how-to)
  assert "scribb-guide: prints base, content type and format" contains "$out" "===== Format: how-to"
  assert "scribb-guide: includes memories" contains "$out" "Approved memories"
  refute "scribb-guide: rejects unknown content types" "$PLUGIN/bin/scribb-guide" --content-type poetry 2>/dev/null
  assert "scribb-config versions: lists packs" contains "$("$PLUGIN/bin/scribb-config" versions)" "pack product-docs"
  assert "scribb-config inbox: empty inbox" contains "$("$PLUGIN/bin/scribb-config" inbox)" "The inbox is empty"
  assert "config: lists styles" contains "$("$PLUGIN/bin/scribb-config" packs --kind style)" "direct-developer-docs"
  teardown

  # --- checker loop ---
  if have_vale; then
    setup
    printf '%s\n' "$BAD_DOC" > docs/bad.md
    printf '%s\n' "$GOOD_DOC" > docs/good.md
    "$PLUGIN/bin/scribb-check" docs/good.md >/dev/null
    assert "scribb-check: good doc passes" [ $? -eq 0 ]
    out=$("$PLUGIN/bin/scribb-check" docs/bad.md)
    assert "scribb-check: bad doc blocks" [ $? -eq 1 ]
    assert "scribb-check: finds base rules" contains "$out" ":block:hard:ScribbBase.AIVocabulary:"
    out=$("$PLUGIN/bin/scribb-check" --freedom expressive docs/bad.md)
    assert "scribb-check: expressive turns conventions into warnings" contains "$out" ":warn:convention:ScribbDocs.HeadingCase:"
    printf 'export const A = () => <p>{"Oops! Please try again."}</p>;\n' > A.tsx
    out=$("$PLUGIN/bin/scribb-check" A.tsx)
    assert "scribb-check: lints strings in .tsx" contains "$out" "ScribbUI.Oops"
    printf 'type P = { n: number };\nexport function E({ n }: P): JSX.Element {\n  return <h2>Oops! No projects yet</h2>;\n}\n' > B.tsx
    out=$("$PLUGIN/bin/scribb-check" B.tsx)
    assert "scribb-check: lints JSX text in .tsx" contains "$out" "B.tsx:3:"
    assert "scribb-check: reports the .tsx path, not the copy" contains "$out" "B.tsx:3:14:block:convention:ScribbUI.Oops"
    run_hook check "$(edit_input s1 "$T/proj/docs/good.md")" >/dev/null 2>&1
    assert "check hook: clean file exits 0" [ $? -eq 0 ]
    for i in 1 2; do
      err=$(run_hook check "$(edit_input s1 "$T/proj/docs/bad.md")" 2>&1 >/dev/null)
      rc=$?
      assert "check hook: blocking findings exit 2 (try $i)" [ $rc -eq 2 ]
    done
    assert "check hook: findings use repo-relative paths" contains "$err" "docs/bad.md:"
    err=$(run_hook check "$(edit_input s1 "$T/proj/docs/bad.md")" 2>&1 >/dev/null)
    assert "check hook: after 2 retries, tells Claude to stop revising" contains "$err" "Don't revise again"
    run_hook check "$(edit_input s1 "$T/proj/docs/bad.md")" >/dev/null 2>&1
    assert "check hook: then goes quiet" [ $? -eq 0 ]
    printf '# Use Foo With The Bar Service\n\nText.\n' > docs/name.md
    out=$("$PLUGIN/bin/scribb-check" docs/name.md)
    assert "vocab: title case is flagged" contains "$out" "HeadingCase"
    mkdir -p .scribb && printf 'Foo\nBar Service\nThe Bar Service\n' > .scribb/vocab.txt
    printf '# Use Foo with the Bar Service\n\nText.\n' > docs/name.md
    out=$("$PLUGIN/bin/scribb-check" docs/name.md)
    refute "vocab: accepted names pass HeadingCase" contains "$out" "HeadingCase"
    mkdir -p newsletter
    printf '# Issue 12\n\nI hope this email finds you well. We are thrilled to announce reports!!\n' > newsletter/i12.md
    out=$("$PLUGIN/bin/scribb-check" newsletter/i12.md)
    assert "newsletter: its rules run on newsletter/ files" contains "$out" "ScribbNewsletter.EmailCliches"
    refute "newsletter: Docs rules don't" contains "$out" "ScribbDocs."
    "$PLUGIN/bin/scribb-check" --export .scribb/checker >/dev/null
    assert "export: writes vale.ini" [ -f .scribb/checker/vale.ini ]
    out=$(vale --config=.scribb/checker/vale.ini --output=line newsletter/i12.md 2>&1)
    assert "export: newsletter section wins over *.md" contains "$out" "ScribbNewsletter."
    refute "export: and Docs rules stay out of it" contains "$out" "ScribbDocs."
    vale --config=.scribb/checker/vale.ini docs/good.md >/dev/null 2>&1
    assert "export: config runs in plain Vale" [ $? -eq 0 ]

    # --- stop hook ---
    stop_input() { printf '{"session_id":"s9","cwd":"%s","hook_event_name":"Stop","stop_hook_active":%s,"last_assistant_message":"%s"}' "$T/proj" "$1" "$2"; }
    out=$(run_hook stop "$(stop_input false "Great question! Let us delve in.")")
    assert "stop: inactive outside a write session" [ -z "$out" ]
    "$PLUGIN/bin/scribb-config" set write_session on --scope session --session s9 >/dev/null
    out=$(run_hook stop "$(stop_input false "Great question! Let us delve in.")")
    assert "stop: blocks with findings in a write session" contains "$out" '"decision":"block"'
    assert "stop: valid JSON" valid_json "$out"
    out=$(run_hook stop "$(stop_input true "Great question! Let us delve in.")")
    assert "stop: respects stop_hook_active" [ -z "$out" ]
    out=$(run_hook stop "$(stop_input false "Rotate the key, then delete the old one.")")
    assert "stop: clean reply passes" [ -z "$out" ]
    assert "stop: a clean reply ends the write session" [ -z "$(yaml_val "$SCRIBB_STATE_DIR/sessions/s9.yaml" write_session)" ]
    out=$(run_hook stop "$(stop_input false "Great question! Let us delve in.")")
    assert "stop: after the session ends, replies aren't checked" [ -z "$out" ]
    out=$("$PLUGIN/bin/scribb-check" --content-type newsletter --text "We are thrilled to announce it.")
    assert "scribb-check --text: checks text without a file" contains "$out" "text:1:"
    teardown
  else
    echo "  skip checker tests (Vale not installed)"
  fi
done

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

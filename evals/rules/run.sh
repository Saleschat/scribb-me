#!/usr/bin/env bash
# Layer 1 evals: every checker rule fires on its bad example and stays quiet
# on its good one. Also runs the base rules over every good example and every
# pack's guide, summary and sample as a small false-positive suite.
# Usage: evals/rules/run.sh [packs-dir]   (default: plugin/packs)
set -u

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PACKS=${1:-$ROOT/plugin/packs}

if ! command -v vale >/dev/null 2>&1; then
  echo "vale is not installed; see https://vale.sh/docs/install" >&2
  exit 2
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/scribb-rules.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

TEMPLATE=$WORK/line.tmpl
cat >"$TEMPLATE" <<'TMPL'
{{- range .Files}}{{- $p := .Path -}}{{- range .Alerts -}}
{{ $p }}:{{ .Line }}:{{ index .Span 0 }}:{{ .Severity }}:{{ .Check }}:{{ .Message }}
{{end -}}{{end -}}
TMPL

pass=0
fail=0

ok() { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $*"; }

# Prints the Vale style folders of a pack (every dir under checks/vale except
# tests and config).
pack_styles() {
  local d name
  for d in "$1"/checks/vale/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    case $name in tests | config) continue ;; esac
    echo "$name"
  done
}

# setup_env <dir> <style-name> <pack-dir>...: writes a StylesPath and .vale.ini
# in <dir> that enable <style-name> (or a comma-separated list) for all files.
setup_env() {
  local dir=$1 styles=$2 p s
  shift 2
  mkdir -p "$dir/styles/config/views"
  for p in "$@"; do
    for s in $(pack_styles "$p"); do
      [ -e "$dir/styles/$s" ] || ln -s "$p/checks/vale/$s" "$dir/styles/$s"
    done
  done
  # Views (for example the JSX ones from ux-microcopy) apply to every pack, so
  # copy them from all packs.
  for p in "$PACKS"/*/checks/vale/config/views; do
    [ -d "$p" ] && cp "$p"/*.yml "$dir/styles/config/views/" 2>/dev/null
  done
  {
    echo "StylesPath = styles"
    echo "MinAlertLevel = suggestion"
    echo
    if [ -f "$dir/styles/config/views/JSXCopy.yml" ]; then
      echo "[*.jsx]"
      echo "BasedOnStyles = $styles"
      echo "View = JSXCopy"
      echo
    fi
    if [ -f "$dir/styles/config/views/TSXCopy.yml" ]; then
      echo "[*.tsx]"
      echo "BasedOnStyles = $styles"
      echo "View = TSXCopy"
      echo
    fi
    echo "[*]"
    echo "BasedOnStyles = $styles"
  } >"$dir/.vale.ini"
}

run_vale() {
  # run_vale <env-dir> <file>...
  local dir=$1
  shift
  vale --config="$dir/.vale.ini" --output="$TEMPLATE" --no-exit "$@" 2>&1
}

# 1. Rule tests, per pack.
for pack in "$PACKS"/*/; do
  pack=${pack%/}
  [ -d "$pack/checks/vale" ] || continue
  id=$(basename "$pack")
  for style in $(pack_styles "$pack"); do
    env=$WORK/env-$id-$style
    setup_env "$env" "$style" "$pack"
    for rule_file in "$pack/checks/vale/$style"/*.yml; do
      rule=$(basename "$rule_file" .yml)
      check="$style.$rule"
      bads=$(ls "$pack/checks/vale/tests/$rule".bad.* 2>/dev/null)
      goods=$(ls "$pack/checks/vale/tests/$rule".good.* 2>/dev/null)
      if [ -z "$bads" ] || [ -z "$goods" ]; then
        bad "$check: missing test pair in $id/checks/vale/tests/"
        continue
      fi
      for f in $bads; do
        out=$(run_vale "$env" "$f")
        if printf '%s\n' "$out" | grep -q "^E[0-9]"; then
          bad "$check: vale error on $(basename "$f"): $(printf "%s\n" "$out" | head -3 | tr "\n" " ")"
        elif printf '%s\n' "$out" | grep -q ":$check:"; then
          ok
        else
          bad "$check did not fire on $(basename "$f")"
        fi
      done
      for f in $goods; do
        out=$(run_vale "$env" "$f")
        if printf '%s\n' "$out" | grep -q "^E[0-9]"; then
          bad "$check: vale error on $(basename "$f"): $(printf "%s\n" "$out" | head -3 | tr "\n" " ")"
        elif printf '%s\n' "$out" | grep -q ":$check:"; then
          bad "$check fired on $(basename "$f"):"
          printf '%s\n' "$out" | grep ":$check:" | sed 's/^/    /'
        else
          ok
        fi
      done
    done
  done
done

# 2. False-positive suite: hard base rules over human-reviewed text.
if [ -d "$PACKS/base/checks/vale/ScribbBase" ]; then
  env=$WORK/env-fp
  setup_env "$env" ScribbBase "$PACKS/base"
  files=$(find "$PACKS" \( -path '*/checks/vale/tests/*.good.*' -o -name guide.md -o -name summary.md -o -name sample.md -o -path '*/formats/*.md' \) -type f | sort)
  for f in $files; do
    # The base guide names the phrases it bans, so it is exempt.
    case $f in "$PACKS/base/"*) continue ;; esac
    out=$(run_vale "$env" "$f" | grep ':ScribbBase\.' || true)
    if [ -n "$out" ]; then
      bad "base rules fired on ${f#"$PACKS"/}:"
      printf '%s\n' "$out" | sed 's/^/    /'
    else
      ok
    fi
  done
fi

echo "rule evals: $pass passed, $fail failed"
[ "$fail" -eq 0 ]

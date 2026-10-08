# shellcheck shell=bash
# Shared helpers for scribb.me hooks and scripts. Source it; don't run it.
# Bash 3.2 compatible (macOS default): no associative arrays, no mapfile, no ${var,,}.
# No hard dependency on jq: JSON is read with jq when present, with awk otherwise.

SCRIBB_VERSION="0.1.0"

# --- Paths -------------------------------------------------------------------

scribb_plugin_root() {
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '%s\n' "$CLAUDE_PLUGIN_ROOT"
  else
    (cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
  fi
}

scribb_user_dir() {
  if [ -n "${SCRIBB_HOME:-}" ]; then
    printf '%s\n' "$SCRIBB_HOME"
  else
    printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/scribb"
  fi
}

# Machine-local state (per-session flags, retry counts, generated checker config).
# Never inside the user's repo, so a zero-config install leaves no files behind.
# Not CLAUDE_PLUGIN_DATA: hooks get that variable, but commands Claude runs
# through Bash (the skills' helper calls) don't, so the two would disagree on
# where session settings and the hook log live.
scribb_state_dir() {
  if [ -n "${SCRIBB_STATE_DIR:-}" ]; then
    printf '%s\n' "$SCRIBB_STATE_DIR"
  else
    printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}/scribb"
  fi
}

# Project root: CLAUDE_PROJECT_DIR, else the git root of $1 (or cwd), else $1.
# Physical paths (pwd -P), so /var vs /private/var symlinks compare equal.
scribb_project_dir() {
  local root
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    root="$CLAUDE_PROJECT_DIR"
  else
    local start="${1:-$PWD}"
    root=$(git -C "$start" rev-parse --show-toplevel 2>/dev/null) || root="$start"
  fi
  if [ -d "$root" ]; then (cd "$root" && pwd -P); else printf '%s\n' "$root"; fi
}

# abs_path FILE: absolute physical path of a file (the file need not exist,
# its directory must).
abs_path() {
  local dir rest=""
  case "$1" in /*) dir=$(dirname "$1") ;; *) dir="$PWD/$(dirname "$1")" ;; esac
  rest=$(basename "$1")
  # Resolve the nearest folder that exists; keep the missing part as written.
  while [ ! -d "$dir" ] && [ "$dir" != / ]; do
    rest="$(basename "$dir")/$rest"
    dir=$(dirname "$dir")
  done
  dir=$(cd "$dir" && pwd -P)
  printf '%s/%s\n' "${dir%/}" "$rest"
}

# Creates .scribb/local/ with a self-ignoring .gitignore, so local state never
# shows up in git status even before /scribb:setup adds the .gitignore entry.
scribb_ensure_local_dir() {
  local dir="$1/.scribb/local"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" || return 1
  fi
  [ -f "$dir/.gitignore" ] || printf '*\n' > "$dir/.gitignore"
  printf '%s\n' "$dir"
}

# --- JSON (hook input) ---------------------------------------------------------

# json_get KEY [FILE]: the first string value for KEY, unescaped. Reads stdin if
# no file. Only string values; good enough for hook input fields.
json_get() {
  local key="$1" file="${2:-/dev/stdin}"
  if [ -z "${SCRIBB_NO_JQ:-}" ] && command -v jq >/dev/null 2>&1; then
    jq -r --arg k "$key" 'first(.. | objects | select(has($k)) | .[$k] | select(type == "string")) // empty' "$file" 2>/dev/null
    return
  fi
  awk -v key="$key" '
    BEGIN { RS = "\001" }
    {
      pat = "\"" key "\"[ \t\r\n]*:[ \t\r\n]*\""
      if (!match($0, pat)) exit
      s = substr($0, RSTART + RLENGTH)
      out = ""
      n = length(s)
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (c == "\\") {
          i++; e = substr(s, i, 1)
          if (e == "n") out = out "\n"
          else if (e == "t") out = out "\t"
          else if (e == "r") out = out "\r"
          else if (e == "b" || e == "f") out = out " "
          else if (e == "u") { out = out "\\u"; }
          else out = out e
        } else if (c == "\"") {
          break
        } else {
          out = out c
        }
      }
      printf "%s", out
    }' "$file"
}

# json_get_bool KEY [FILE]: prints true or false.
json_get_bool() {
  local key="$1" file="${2:-/dev/stdin}"
  if grep -Eq "\"$key\"[[:space:]]*:[[:space:]]*true" "$file" 2>/dev/null; then
    printf 'true\n'
  else
    printf 'false\n'
  fi
}

# json_escape: escapes stdin as the inside of a JSON string.
json_escape() {
  awk '
    BEGIN { RS = "\001"; ORS = "" }
    {
      gsub(/\\/, "\\\\")
      gsub(/"/, "\\\"")
      gsub(/\t/, "\\t")
      gsub(/\r/, "")
      gsub(/\n/, "\\n")
      print
    }'
}

# emit_json SYSTEM_MESSAGE EVENT CONTEXT: prints one hook output object.
# Empty arguments are left out; prints nothing if both are empty.
emit_json() {
  local sys="$1" event="$2" ctx="$3" out="" sep=""
  if [ -n "$sys" ]; then
    out="\"systemMessage\":\"$(printf '%s' "$sys" | json_escape)\""
    sep=","
  fi
  if [ -n "$ctx" ]; then
    out="$out$sep\"hookSpecificOutput\":{\"hookEventName\":\"$event\",\"additionalContext\":\"$(printf '%s' "$ctx" | json_escape)\"}"
  fi
  [ -n "$out" ] && printf '{%s}\n' "$out"
  return 0
}

# --- Config --------------------------------------------------------------------

# yaml_get FILE KEY: value of a flat "key: value" line, quotes stripped.
yaml_get() {
  [ -f "$1" ] || return 1
  local line
  line=$(grep -E "^$2:[[:space:]]*" "$1" 2>/dev/null | tail -n 1) || return 1
  [ -n "$line" ] || return 1
  printf '%s\n' "$line" | sed -E "s/^$2:[[:space:]]*//; s/[[:space:]]+#.*$//; s/[[:space:]]*$//; s/^[\"'](.*)[\"']$/\\1/"
}

# yaml_set FILE KEY VALUE: replaces or appends a flat key.
yaml_set() {
  local file="$1" key="$2" value="$3" tmp
  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$file.tmp.$$"
  grep -vE "^$key:" "$file" > "$tmp" 2>/dev/null || true
  printf '%s: %s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$file"
}

# yaml_unset FILE KEY
yaml_unset() {
  local file="$1" key="$2" tmp
  [ -f "$file" ] || return 0
  tmp="$file.tmp.$$"
  grep -vE "^$key:" "$file" > "$tmp" 2>/dev/null || true
  mv "$tmp" "$file"
}

# Config files in precedence order, highest first. Needs SCRIBB_PROJECT and,
# for the session scope, SCRIBB_SESSION.
scribb_config_files() {
  if [ -n "${SCRIBB_SESSION:-}" ]; then
    printf '%s\n' "$(scribb_state_dir)/sessions/$SCRIBB_SESSION.yaml"
  fi
  printf '%s\n' "$SCRIBB_PROJECT/.scribb/local/config.yaml"
  printf '%s\n' "$SCRIBB_PROJECT/.scribb/config.yaml"
  printf '%s\n' "$(scribb_user_dir)/config.yaml"
}

scribb_config_file_for_scope() {
  case "$1" in
    session) printf '%s\n' "$(scribb_state_dir)/sessions/${SCRIBB_SESSION:?session id needed}.yaml" ;;
    local) printf '%s\n' "$SCRIBB_PROJECT/.scribb/local/config.yaml" ;;
    project) printf '%s\n' "$SCRIBB_PROJECT/.scribb/config.yaml" ;;
    user) printf '%s\n' "$(scribb_user_dir)/config.yaml" ;;
    *) return 1 ;;
  esac
}

scribb_default() {
  case "$1" in
    enabled) echo true ;;
    style) echo none ;;
    checker) echo vale ;;
    reviewer) echo auto ;;
    capture | inject | nudges) echo on ;;
    paths_ignore) echo "node_modules/*, vendor/*, dist/*, build/*, .git/*, .scribb/*, .claude/*, CHANGELOG.md, LICENSE*, NOTICE*, CLAUDE.md, CLAUDE.local.md, AGENTS.md, SKILL.md" ;;
    *) echo "" ;;
  esac
}

# cfg KEY: effective value across scopes.
cfg() {
  local f v
  while IFS= read -r f; do
    if v=$(yaml_get "$f" "$1"); then
      printf '%s\n' "$v"
      return
    fi
  done <<EOF
$(scribb_config_files)
EOF
  scribb_default "$1"
}

# cfg_scope KEY: which scope set the effective value (session/local/project/user/default).
cfg_scope() {
  local s
  for s in session local project user; do
    [ "$s" = session ] && [ -z "${SCRIBB_SESSION:-}" ] && continue
    if yaml_get "$(scribb_config_file_for_scope "$s")" "$1" >/dev/null; then
      echo "$s"
      return
    fi
  done
  echo default
}

is_off() {
  case "$1" in
    off | false | no | 0 | none) return 0 ;;
    *) return 1 ;;
  esac
}

# The kill switch. Every hook calls this first.
scribb_disabled() {
  case "${SCRIBB_DISABLE:-}" in
    1 | true | yes) return 0 ;;
  esac
  is_off "$(cfg enabled)"
}

# --- Packs ---------------------------------------------------------------------

# pack_dir ID: first match in local > project > user > built-in.
# Packs are grouped by kind in every scope:
#   packs/base/               the base layer (built-in only)
#   packs/content-types/<id>/ exactly one per piece
#   packs/styles/<id>/        zero or one per piece
#   packs/rules/              memories promoted to checker rules (user, project, local)

# The packs/ folder of each scope, highest precedence first ("scope<TAB>dir").
pack_roots() {
  printf 'local\t%s\n' "$SCRIBB_PROJECT/.scribb/local/packs"
  printf 'project\t%s\n' "$SCRIBB_PROJECT/.scribb/packs"
  printf 'user\t%s\n' "$(scribb_user_dir)/packs"
  printf 'built-in\t%s\n' "$(scribb_plugin_root)/packs"
}

# pack_dir ID: first match in local > project > user > built-in.
pack_dir() {
  local id="$1" scope root d
  while IFS="$(printf '\t')" read -r scope root; do
    for d in "$root/content-types/$id" "$root/styles/$id" "$root/$id"; do
      [ "$d" = "$root/$id" ] && [ "$id" != base ] && continue
      if [ -f "$d/pack.yaml" ]; then
        printf '%s\n' "$d"
        return 0
      fi
    done
  done <<EOF
$(pack_roots)
EOF
  return 1
}

pack_field() {
  yaml_get "$1/pack.yaml" "$2"
}

# All pack directories, every scope, one per line ("scope<TAB>dir").
list_pack_dirs() {
  local scope root d
  while IFS="$(printf '\t')" read -r scope root; do
    [ -d "$root" ] || continue
    for d in "$root/base/" "$root"/content-types/*/ "$root"/styles/*/; do
      [ -f "$d/pack.yaml" ] && printf '%s\t%s\n' "$scope" "${d%/}"
    done
  done <<EOF
$(pack_roots)
EOF
}

# --- Files → content type --------------------------------------------------------

# match_globs REL "a, b, c": does the repo-relative path match any glob?
# In case patterns * also matches /, so "docs/*.md" covers nested files and a
# bare "*.md" matches anywhere.
match_globs() {
  local rel="$1" list="$2" g noglob=no
  # Split on commas without expanding the globs against the current directory.
  case $- in *f*) noglob=yes ;; esac
  set -f
  local IFS=','
  for g in $list; do
    g=$(printf '%s' "$g" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/\*\*/*/g')
    [ -n "$g" ] || continue
    # shellcheck disable=SC2254
    case "$rel" in
      $g | */$g)
        [ "$noglob" = yes ] || set +f
        return 0 ;;
    esac
  done
  [ "$noglob" = yes ] || set +f
  return 1
}

# Content types are data: any pack with "kind: content-type", in any scope.
# Each pack.yaml sets label, paths and match_order (lower is matched first, so
# "newsletter/*" wins over the Docs pattern "*.md").

# content_type_ids: one id per line, in match order.
content_type_ids() {
  local s d id order seen=" " tab
  tab=$(printf '\t')
  while IFS="$tab" read -r s d; do
    [ -n "$d" ] || continue
    [ "$(pack_field "$d" kind)" = content-type ] || continue
    id=$(pack_field "$d" id)
    case "$seen" in *" $id "*) continue ;; esac
    seen="$seen$id "
    order=$(pack_field "$d" match_order) || order=100
    printf '%s\t%s\n' "$order" "$id"
  done <<EOF | sort -n -k1,1 | cut -f2
$(list_pack_dirs)
EOF
}

# The config key that overrides a content type's paths. Docs and UI copy keep
# the short keys; others use paths_<id> with dashes as underscores.
ct_paths_key() {
  case "$1" in
    product-docs) echo paths_docs ;;
    ux-microcopy) echo paths_ui ;;
    *) printf 'paths_%s\n' "$1" | tr '-' '_' ;;
  esac
}

# ct_paths ID: comma-separated globs (config override, else pack.yaml paths).
ct_paths() {
  local v d
  v=$(cfg "$(ct_paths_key "$1")")
  if [ -z "$v" ] && d=$(pack_dir "$1"); then
    v=$(pack_field "$d" paths | sed -E 's/^\[//; s/\]$//; s/"//g')
  fi
  printf '%s\n' "$v"
}

# frontmatter_content_type FILE: the "scribb-content-type:" key from a
# Markdown file's frontmatter, if any. Docs tools such as GitBook ignore keys
# they don't know, so a page can say what it is wherever it lives.
frontmatter_content_type() {
  [ -f "$1" ] || return 0
  awk '
    NR == 1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
    /^---[[:space:]]*$/ || NR > 60 { exit }
    /^scribb-content-type:/ {
      sub(/^scribb-content-type:[[:space:]]*/, ""); gsub(/["'\''[:space:]]/, ""); print; exit
    }' "$1"
}

# content_type_for FILE: the content type a file belongs to, or nothing.
# Order: the ignore list, then the file's frontmatter, then the first content
# type (in match_order) whose paths match.
content_type_for() {
  local file rel ct
  file=$(abs_path "$1")
  case "$file" in
    "$SCRIBB_PROJECT"/*) rel="${file#"$SCRIBB_PROJECT"/}" ;;
    /*) return 0 ;; # outside the project: leave it alone
    *) rel="$file" ;;
  esac
  match_globs "$rel" "$(cfg paths_ignore)" && return 0
  ct=$(frontmatter_content_type "$file")
  if [ -n "$ct" ] && pack_dir "$ct" >/dev/null && [ "$(pack_field "$(pack_dir "$ct")" kind)" = content-type ]; then
    echo "$ct"
    return 0
  fi
  while IFS= read -r ct; do
    [ -n "$ct" ] || continue
    if match_globs "$rel" "$(ct_paths "$ct")"; then
      echo "$ct"
      return 0
    fi
  done <<EOF
$(content_type_ids)
EOF
}

content_type_label() {
  local d l
  if d=$(pack_dir "$1") && l=$(pack_field "$d" label); then
    echo "$l"
  else
    echo "$1"
  fi
}

# ct_review_threshold ID: when the auto reviewer kicks in, as "words N" or
# "strings N" (UI copy counts strings, not words).
ct_review_threshold() {
  local d t
  if d=$(pack_dir "$1") && t=$(pack_field "$d" review_threshold); then
    echo "$t"
  else
    echo "words 150"
  fi
}

# freedom_for CONTENT_TYPE: the effective freedom.
freedom_for() {
  local f d
  f=$(cfg freedom)
  if [ -z "$f" ] && d=$(pack_dir "$1"); then
    f=$(pack_field "$d" freedom)
  fi
  echo "${f:-balanced}"
}

# --- Session state -----------------------------------------------------------------

session_dir() {
  local d
  d="$(scribb_state_dir)/sessions/${SCRIBB_SESSION:-nosession}.d"
  mkdir -p "$d"
  printf '%s\n' "$d"
}

# A short stable key for a path, for state file names.
path_key() {
  printf '%s' "$1" | cksum | awk '{print $1}'
}

counter_get() {
  local f
  f="$(session_dir)/$1"
  if [ -f "$f" ]; then cat "$f"; else echo 0; fi
}

counter_incr() {
  local f n
  f="$(session_dir)/$1"
  n=$(counter_get "$1")
  echo $((n + 1)) > "$f"
}

# Removes session files older than 7 days. Cheap; runs at session start.
prune_sessions() {
  local d
  d="$(scribb_state_dir)/sessions"
  [ -d "$d" ] || return 0
  find "$d" -mindepth 1 -maxdepth 1 -mtime +7 -exec rm -rf {} + 2>/dev/null || true
}

# --- Checker engine ----------------------------------------------------------------------

# The Python checker bundled with the skills (generated by tools/build-chat.py).
builtin_checker() {
  printf '%s\n' "$(scribb_plugin_root)/skills/write/scripts/check.py"
}

# scribb_engine: vale, builtin, or nothing. "checker: vale" (the default) uses
# Vale when it's installed and falls back to the built-in checker otherwise;
# "checker: builtin" always uses the built-in one; "checker: none" turns it off.
scribb_engine() {
  local c builtin=""
  c=$(cfg checker)
  is_off "$c" && return 0
  if command -v python3 >/dev/null 2>&1 && [ -f "$(builtin_checker)" ]; then
    builtin=builtin
  fi
  if [ "$c" = builtin ]; then
    [ -n "$builtin" ] && echo builtin
    return 0
  fi
  if command -v vale >/dev/null 2>&1; then
    echo vale
  elif [ -n "$builtin" ]; then
    echo builtin
  fi
  return 0
}

# --- Misc ------------------------------------------------------------------------------

# The approver for anything a human approves: git user, else $USER.
scribb_approver() {
  local name email
  name=$(git config user.name 2>/dev/null)
  email=$(git config user.email 2>/dev/null)
  if [ -n "$name" ] && [ -n "$email" ]; then
    printf '%s <%s>\n' "$name" "$email"
  elif [ -n "$name" ]; then
    printf '%s\n' "$name"
  else
    printf '%s\n' "${USER:-unknown}"
  fi
}

word_count() {
  wc -w | awk '{print $1}'
}

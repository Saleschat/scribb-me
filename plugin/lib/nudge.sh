# shellcheck shell=bash
# Nudges: one-time tips and offers, picked with file lookups and grep only.
# See docs/open-items/017-nudges.md. Source after lib/scribb.sh.
#
# Rules: each nudge is shown once ever (user scope), unless it repeats;
# at most one nudge per session; the first matching row in NUDGES wins.

# id|event|channel|repeat|exempt_from_opt_out
# Adding a nudge: one row here, a cond_<id> function and a text_<id> function
# (dashes in the id become underscores).
NUDGES='on-by-default|PostToolUse|user|once|yes
inbox-ready|SessionStart|claude|repeat|no
pick-style|PostToolUse|claude|once|no
install-checker|PostToolUse|user|once|no'

nudge_state_file() {
  printf '%s\n' "$(scribb_user_dir)/nudges.state"
}

nudge_shown() {
  grep -q "^$1	" "$(nudge_state_file)" 2>/dev/null
}

nudge_mark() {
  local f
  f=$(nudge_state_file)
  mkdir -p "$(dirname "$f")"
  printf '%s\t%s\n' "$1" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$f"
  : > "$(session_dir)/nudged"
}

session_nudged() {
  [ -f "$(session_dir)/nudged" ]
}

# --- Conditions. They see NUDGE_FILE and NUDGE_CT for PostToolUse. ---

cond_on_by_default() {
  [ -n "${NUDGE_CT:-}" ]
}

inbox_count() {
  local d="$SCRIBB_PROJECT/.scribb/local/inbox"
  [ -d "$d" ] || { echo 0; return; }
  find "$d" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | awk '{print $1}'
}

cond_inbox_ready() {
  [ "$(inbox_count)" -ge 3 ]
}

cond_pick_style() {
  [ -n "${NUDGE_CT:-}" ] && is_off "$(cfg style)"
}

cond_install_checker() {
  [ -n "${NUDGE_CT:-}" ] && ! is_off "$(cfg checker)" && [ -z "$(scribb_engine)" ]
}

# --- Texts ---

text_on_by_default() {
  printf '%s' "scribb.me is checking the writing in this file ($(content_type_label "$NUDGE_CT")). It's on by default. To turn it off: /scribb:style off (this session), /scribb:style off --repo or --everywhere, or set SCRIBB_DISABLE=1. Type /scribb to see everything it can do."
}

text_inbox_ready() {
  printf '%s' "scribb.me: $(inbox_count) writing-style corrections from this user are waiting in the inbox (.scribb/local/inbox/). At a natural pause, not mid-task, offer once in one line to review them with /scribb:learn inbox. Skip this if the user is busy or has asked for no suggestions."
}

text_pick_style() {
  printf '%s' "scribb.me: no writing style is set, so scribb applies its neutral house style. When this task is done, mention once, in one short line, that the user can pick a style with /scribb:style or teach scribb one with /scribb:learn. Skip it if the user is mid-task or has asked for no suggestions."
}

text_install_checker() {
  printf '%s' "scribb.me: neither Vale nor python3 is available, so the automatic writing checks after each edit are skipped. Install Vale with 'brew install vale' (other systems: https://vale.sh/docs/install)."
}

# nudge_pick EVENT: sets NUDGE_ID, NUDGE_CHANNEL (user|claude) and NUDGE_TEXT,
# marks the nudge as shown, and returns 0; returns 1 if nothing applies.
nudge_pick() {
  local event="$1" id ev channel repeat exempt fn opted_out=no
  NUDGE_ID="" NUDGE_CHANNEL="" NUDGE_TEXT=""
  session_nudged && return 1
  is_off "$(cfg nudges)" && opted_out=yes
  while IFS='|' read -r id ev channel repeat exempt; do
    [ "$ev" = "$event" ] || continue
    [ "$opted_out" = yes ] && [ "$exempt" != yes ] && continue
    [ "$repeat" = once ] && nudge_shown "$id" && continue
    fn=$(printf '%s' "$id" | tr '-' '_')
    "cond_$fn" || continue
    NUDGE_ID="$id"
    NUDGE_CHANNEL="$channel"
    NUDGE_TEXT=$("text_$fn")
    nudge_mark "$id"
    return 0
  done <<EOF
$NUDGES
EOF
  return 1
}

# nudge_should_rate: the rate-rewrite nudge, sampled at feedbackRate (default
# 0.1) and still at most one nudge per session. Called by skills.
nudge_should_rate() {
  local rate roll
  is_off "$(cfg nudges)" && return 1
  session_nudged && return 1
  rate=$(cfg feedbackRate)
  [ -n "$rate" ] || rate=0.1
  roll=$(awk -v r="$rate" -v s="$$$(date +%s)" 'BEGIN { srand(s); print (rand() < r) ? 1 : 0 }')
  [ "$roll" = 1 ] || return 1
  nudge_mark rate-rewrite
  return 0
}

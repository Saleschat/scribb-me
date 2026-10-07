# 017 — Nudges and ratings

Status: decided, needs implementation

## Mechanism
- `bin/scribb-nudge <event>` (bash), registered in the plugin's `hooks/hooks.json` for SessionStart and PostToolUse (`Write|Edit`). Claude Code passes the event JSON on stdin and waits for the script to finish.
- Checks are file lookups and grep only, with no LLM call:
  - opt-outs (`SCRIBB_DISABLE`, `DO_NOT_TRACK`, `DISABLE_TELEMETRY`, `nudges: off`),
  - the nudge's condition,
  - `~/.config/scribb/nudges.state` (shown ever),
  - `.scribb/local/nudged-<session_id>` (one per session).
- Nudge table inside the script: `id | event | condition | channel | message`. Adding a nudge is one line.
- Two channels:
  - `emit_user` → top-level `{"systemMessage": …}`. Shown to the user only; exact wording; no tokens. For factual tips.
  - `emit_claude` → `{"hookSpecificOutput": {"hookEventName": …, "additionalContext": …}}`. Claude decides when and how to say it, and may use AskUserQuestion. For contextual offers and ratings. The text always says to skip if the user is mid-task or asked for no nudges.
- A nudge is marked as shown when it's sent. A Claude-channel nudge that Claude doesn't mention is lost; that's accepted.
- Codex and other tools: skills run the same checks when `/scribb:*` is invoked.

## Rules
- Each nudge is shown once, ever (user scope). At most one per session.
- Priority: inbox memory suggestion > pick a style > install Vale > rating > telemetry opt-in.

## Initial nudges
| id | event | condition | channel |
|---|---|---|---|
| inbox-ready | SessionStart | inbox signal above threshold | claude (every session it applies, not once) |
| pick-style | PostToolUse | file matches content type, no style set | claude |
| install-checker | PostToolUse | a check would have run, `command -v vale` fails | user |
| rate-rewrite | after `/scribb:write` or an auto review | sampled at `feedbackRate` (default 0.1) | claude + AskUserQuestion; repeatable, still one per session |
| telemetry-optin | SessionStart | N sessions of real use | claude + AskUserQuestion |

## Ratings
- Bad / Fine / Good / Dismiss → `.scribb/local/ratings.jsonl` → a learner signal (e.g. "Bad" on strict Docs suggests a rule is over-firing).
- Sent only as a count, and only if the user opted into telemetry (016).

## Open questions
- N for the telemetry offer; whether the `feedbackRate` default should drop after the first ratings.

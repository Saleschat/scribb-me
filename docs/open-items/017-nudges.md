# 017 — Nudges and ratings

Status: decided, needs implementation

## Mechanism
- `scripts/scribb-nudge <event>` (bash), registered in the plugin's `hooks/hooks.json` for SessionStart and PostToolUse (`Write|Edit`). Claude Code passes the event JSON on stdin and waits for the script to finish.
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
- Priority: on by default > inbox memory suggestion > pick a style > install Vale > rating > telemetry opt-in.

## Initial nudges
| id | event | condition | channel |
|---|---|---|---|
| on-by-default | PostToolUse | first time scribb acts automatically (checker ran, or the reviewer was asked to run) | user |
| inbox-ready | SessionStart | inbox signal above threshold | claude (every session it applies, not once) |
| pick-style | PostToolUse | file matches content type, no style set | claude |
| install-checker | PostToolUse | a check would have run, `command -v vale` fails | user |
| rate-rewrite | after `/scribb:write` or an auto review | sampled at `feedbackRate` (default 0.1) | claude + AskUserQuestion; repeatable, still one per session |
| telemetry-optin | SessionStart | N sessions of real use | claude + AskUserQuestion |

## On by default
scribb starts working as soon as it's installed, so the first time it acts on its own, the user should learn that and how to stop it.
- Message (exact wording, `emit_user`):
  > scribb.me is checking the writing in this file (Docs). It's on by default. To turn it off: `/scribb:style off` (this session), `/scribb:style off --repo` or `--everywhere`, or set `SCRIBB_DISABLE=1`.
- It's shown even when `nudges: off` is set, because it's how users find the off switch. `SCRIBB_DISABLE`, `DO_NOT_TRACK` and `DISABLE_TELEMETRY` don't silence it: with `SCRIBB_DISABLE` scribb never acts, so the condition can't be met.
- When the user asks how to turn scribb off (or says it's in the way), Claude answers with the levels from 011's "switched off at every level" table and offers to run the command. The SessionStart injection carries one line for this, so it works even after the nudge was shown.

## Ratings
- Bad / Fine / Good / Dismiss → `.scribb/local/ratings.jsonl` → a learner signal (for example, "Bad" on strict Docs suggests a rule is over-firing).
- Sent only as a count, and only if the user opted into telemetry (016).

## Open questions
- Whether `on-by-default` should repeat once per new repo, since project scope settings differ.
- N for the telemetry offer; whether the `feedbackRate` default should drop after the first ratings.

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- `on-by-default`, `inbox-ready`, `pick-style`, `install-checker` and `rate-rewrite` are in `plugin/lib/nudge.sh`; `telemetry-optin` waits for telemetry (016).
- The shipped wording is "scribb.me is checking the writing in this file (Docs). It's on by default. To turn it off: … Type /scribb to see everything it can do.", because the nudge fires on the synchronous hook, before the background checker has run.
- The per-session marker lives in the plugin data dir, not `.scribb/local/`.
- `inbox-ready` fires at 3 or more pending inbox files; the learner does the grouping.

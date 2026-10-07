# 016 — Usage information and telemetry

Status: decided, needs implementation

## Decision
- **From day one:**
  - Passive signals: GitHub stars, traffic, issues, discussions, contributed styles.
  - `/scribb:report`: drafts a GitHub issue (e.g. "false positive: rule X flagged this sentence") for the user to review, edit and submit. Shows exactly what will be sent.
- **Opt-in anonymous telemetry** (counts only):
  - Off by default. Offered once through the nudge system after some real use, never at install.
  - Each user decides for themselves: only a user-scope setting enables it. A project setting can't turn it on for everyone, but can point the endpoint at a self-hosted collector for internal analytics.
  - Events are written to `.scribb/local/telemetry.jsonl` first, readable by the user, and sent in batches by the session hook. The event schema is documented in the repo; the sending code is a few lines of bash.
  - Allowed: content type and format used, checker hits per rule ID, reviewer suggestions accepted vs rejected, freedom level, scribb version, a random install ID the user can reset.
  - Never: text, prompts, file paths, repo names, usernames.
  - One setting turns it off; `SCRIBB_DISABLE=1` stops everything.
- **Never content telemetry.**

## Open questions
- Which analytics backend (any tool with an HTTP capture API; self-hostable preferred).
- How many sessions before the opt-in offer appears.

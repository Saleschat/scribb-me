# 012 — v1 component set

Status: implemented in v0.1 (Claude Code); Codex and generic adapters not started

## Skills (Agent Skills standard; in Claude Code they also show up as `/scribb:*` commands)
| Skill | Started by | Does |
|---|---|---|
| `setup` | user | Onboarding: pick content type and style (or zero-config defaults). Writes `.scribb/` (including the generated checker config), adds `.scribb/local/` to `.gitignore` |
| `write` | user | Outer loop: brief → draft → checker → reviewer → revise, at most 2 rounds |
| `review` | user | Reviews existing text, a file or a diff. Reports findings, and only rewrites if asked |
| `style` | user | Shows the active style (which layers, from which scope). Switches style, content type or freedom for this piece or repo. `off` / `on` turns scribb off or back on for the session, `--repo` or `--everywhere` |
| `learn` | user | (a) from sources: create or update a style pack; (b) from the inbox: group, score, suggest. Hands off to the learner agent |
| `remember` | user, or Claude after a hook prompt | Saves one memory, asks for its scope, records the approver |
| `scribb-style` | model (from its description) | Background guidance: when writing any prose, apply the active style. A best-effort safety net |

## Agents (Claude Code only; other tools run the same steps inline as skills)
- `scribb-reviewer`: fresh context. Rubric is base patterns + style + memories. Returns specific passages to fix. Rejects a finding when unsure (ECC verifier pattern).
- `scribb-learner`: reads sources or the inbox without filling the main context. Proposes packs and memories; never writes without approval.
- No writer agent: the main conversation writes.

## Hooks (bash only)
| Event | Does |
|---|---|
| SessionStart | Injects the active style summary + top memories + pending inbox count + one line on how to turn scribb off if the user asks |
| UserPromptSubmit | Captures correction phrasing → inbox + an "offer to save" line |
| PostToolUse (Write\|Edit) | Runs `scribb-check` on files that match a content-type pattern; exit code 2 sends findings back; at most 2 retries |
| Stop | Lints the last reply, only while a write session is active |

## Built-in packs
- `base` (anti-AI habits)
- `product-docs`, `developer-docs`, `ux-microcopy` and `newsletter` content types (002)
- 1–2 sample styles from openly licensed sources (TBD)

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- Everything above is in `plugin/`, plus:
  - a `report` skill (from 016) and a `contribute` skill (local memory or rule → pull request against the built-in packs),
  - `scripts/scribb-config` (settings, status, off/on, packs, inbox, memories, approvals, versions), `scripts/scribb-guide` (all the guidance for one piece in one call) and `scripts/scribb-nudge` (nudge checks for skills),
  - a `newsletter` content type (issues, product updates, welcome emails), and two starter styles: `direct-developer-docs` and `crisp-product-ui`. `warm-and-plain` was dropped (002).
- `setup`, `report` set `disable-model-invocation`; `scribb-style` is model-only (`user-invocable: false`).

## Smoke test (2026-10-08)
Every command was run headless against throwaway repos (about $5 in total), with file edits allowed and nothing else, which also tests whether each skill's `allowed-tools` avoids permission prompts.
- **Worked first time:** `/scribb:style` (status, use, off), `/scribb:review` (no edits without `--fix`), correction capture into the inbox, `/scribb:setup` on a GitBook repo (read `SUMMARY.md` and mapped `api-reference/*` to developer docs), and the checker hook waking Claude after an edit.
- **Bugs found and fixed:**
  - `scribb-config` let `--session` override `--repo`/`--team`/`--everywhere`, so `/scribb:style off --everywhere` only turned scribb off for the session. Scope flags now always win.
  - The Stop hook never checked chat pieces: `/scribb:write` turned the write session off before the reply finished. The Stop hook now ends the session itself after checking. Per-piece freedom moved to its own `write_freedom` key.
  - The checker missed JSX text in `.tsx`, where most UI copy lives. `scribb-check` now lints a `.jsx` copy (see 008).
  - `HeadingCase` flagged "iOS setup"; common lower-case-first names are now exceptions.
- **Permission prompts removed:** skills and agents read pack files outside the project, chained helper calls (`cat a; ls b; …`), wrote temp draft files outside the project, and appended to the approvals index by hand, each of which asks the user. Now:
  - `scripts/scribb-guide` prints the base, content type, format and style guides, the UI role map and the memories in one allowed call; the reviewer gets that text from the caller.
  - `scribb-check --text "…"` checks a draft without a file.
  - `scribb-config` gained `inbox`, `memories`, `approvals`, `record-approval`, `hash` and `versions`.
  - Every skill says to run helpers as single commands, and allows `Read` on the plugin folder plus `Read`/`Write`/`Edit` on `~/.config/scribb/**` where it saves there.
  - `/scribb:learn` saves memories itself instead of invoking `/scribb:remember` (a skill call asks for permission).
  - `/scribb:contribute` allows the local git and test commands in its clone; cloning, forking, pushing and opening the pull request still ask, on purpose.
- **Judgement checks that passed:** Claude kept the user's explicit copy over checker findings and explained the conflict; `/scribb:learn inbox` merged duplicate signals and skipped one already saved; `/scribb:contribute` kept a product term and a house-voice preference local, and turned `please note` into a case-sensitive product-docs rule after noticing an existing rule already covered half of it.
- **Not covered by a headless run:** questions asked with AskUserQuestion (headless sessions can't answer them), so the prompts named their choices up front.


# 012 — v1 component set

Status: decided, needs implementation

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
- `tech-docs` and `ux-microcopy` content types
- 1–2 sample styles from openly licensed sources (TBD)

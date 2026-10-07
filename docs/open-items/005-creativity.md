# 005 — Where creativity fits

Status: decided, needs implementation

## Decision
Creativity is a **freedom** setting on the brief (per piece): `strict | balanced | expressive`. It is not a property of a pack.

- Every rule has a `severity`: `hard | convention | preference`, mapped to the checker's levels (Vale: error / warning / suggestion; see 007). Base anti-AI rules count as hard. Freedom maps to the checker's minimum alert level (Vale: `MinAlertLevel`).
- Freedom maps severity to what happens:

| Severity | strict | balanced | expressive |
|---|---|---|---|
| hard (incl. base anti-AI) | block | block | block |
| convention (content type) | block | block | warn |
| preference (style) | block | warn | suggest |

- Agent behaviour by level: strict gives one rewrite with minimal changes, balanced gives one rewrite, expressive gives 2–3 options with freer phrasing.
- Each content-type pack sets the default level. `ux-microcopy` and `tech-docs` default to strict; `marketing` and `journalism` default to expressive. The median user never sees the setting.
- Users override per piece, for example, `--freedom expressive`.

## Open questions
- Exact names of the CLI flag and the brief field.
- Should a project be able to lock freedom, for example, compliance docs fixed at strict?

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- `scribb-check` applies the freedom table above to each finding and prints `block`, `warn` or `suggest`.
- One base rule isn't hard: `ScribbBase.EmDashes` (more than 2 em dashes in a paragraph) is a convention, because only the frequency is a signal.
- Brief field and setting: `freedom`. Per piece it's set in the session scope by `/scribb:write --freedom <level>`. A project locks it by setting `freedom` in `.scribb/config.yaml` (offered by `/scribb:setup`).

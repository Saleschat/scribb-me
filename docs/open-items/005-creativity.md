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
- Users override per piece, e.g. `--freedom expressive`.

## Open questions
- Exact names of the CLI flag and the brief field.
- Should a project be able to lock freedom, e.g. compliance docs fixed at strict?

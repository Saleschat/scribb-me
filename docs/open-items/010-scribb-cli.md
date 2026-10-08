# 010 — scribb CLI (deferred)

Status: deferred, not in v1

## Context
v1 needs no custom CLI: the checker (Vale behind `scripts/scribb-check`) handles deterministic linting, and skills handle merging and memory. A `scribb` CLI would add:
- deterministic merging of layers and scopes into one effective style (instead of the agent re-doing it every session),
- schema validation of packs that users write,
- memory and pack management commands,
- the core logic the webapp API would reuse.

## When to revisit
- Merge results vary between sessions or tools in practice.
- Webapp work starts.
- Users ask for pack validation or scaffolding (`scribb new style`).

## Open questions
- Language: **Node** (decided in 018). The CLI grows out of the `npx scribb` installer.

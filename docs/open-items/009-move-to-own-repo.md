# 009 — scribb.me's own repo

Status: in progress. `Saleschat/scribb-me` exists, is **public**, and holds the design docs.

## Done
- Created the public repo `Saleschat/scribb-me` and moved `docs/open-items/` here.
- Added an MIT `LICENSE` (Copyright (c) 2026 Saleschat).

- `plugin/`, `evals/`, `docs/` and `tests/` exist; `.claude-plugin/marketplace.json` lists `./plugin` (v0.1).

## Remaining
- If Wikipedia text is ever quoted, it goes in a separate file under CC BY-SA 4.0 with its own notice (006). None is quoted in v0.1.
- `catalog/` (018).
- Teams with their own private plugin marketplace can list scribb there as an external `git-subdir` source pointing at `plugin/`.

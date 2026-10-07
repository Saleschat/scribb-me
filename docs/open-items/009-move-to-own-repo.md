# 009 — scribb.me's own repo

Status: in progress. `Saleschat/scribb-me` exists, is **public**, and holds the design docs.

## Done
- Created the public repo `Saleschat/scribb-me` and moved `docs/open-items/` here.
- Added an MIT `LICENSE` (Copyright (c) 2026 Saleschat).

## Remaining
- Wikipedia-derived data must go in a separate file under CC BY-SA 4.0 with its own notice, because the repo-level MIT licence doesn't cover it (006).
- Layout (decided in 018): `plugin/`, `catalog/`, `evals/`, `docs/`.
- A `marketplace.json` in this repo with an HTTPS git URL, for public installs.
- Teams with their own private plugin marketplace can list scribb there as an external `git-subdir` source pointing at `plugin/`.

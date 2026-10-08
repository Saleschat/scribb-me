# 018 — Distribution, bundled packs and the catalog

Status: decided, needs implementation

## Install paths
| Tool | How |
|---|---|
| Claude Code | Plugin marketplace. A `marketplace.json` in this repo with an **HTTPS** git URL (`/plugin marketplace add Saleschat/scribb-me`). Teams with a private marketplace can also list it as an external `git-subdir` source pointing at `plugin/`. Use HTTPS, not SSH: SSH fails for users without GitHub SSH keys |
| Codex | Native plugin marketplace via `adapters/codex/` + AGENTS.md snippet. Hooks need manual trust, which the docs explain |
| Others | Copy `skills/` + the generic AGENTS.md section. Best effort |
| Any, via npm | `npx scribb install [--tool …]`, `update`, `uninstall`, `doctor`. Node is needed **at install time only**. Keeps an ownership manifest in the user scope; detects marketplace installs to avoid running hooks twice; `doctor` checks tools, Vale and duplicate hooks |

- npm name: `scribb` (also `scribb-me`, `scribbme`, `@scribb/cli` returned 404 on 2026-10-07). Reserve `scribb` and the `@scribb` org. The `@scribb` npm org was created on 2026-10-07.
- The npm installer is the start of the future CLI (010), so the CLI language is **Node**.

## Bundled packs (ready for the median user, no download)
- base, Docs and UI copy (with formats and the shadcn role map), Newsletter, and starter styles named by traits from openly licensed sources (v0.1: "Direct developer docs", "Crisp product UI").
- Checker rules are bundled inside the packs, so no `vale sync` is needed.
- Vale itself is not bundled. It stays optional, suggested through the `install-checker` nudge and `doctor`.
- The bundle stays small on purpose: base + content types + about 6–8 styles at most.

## Catalog (non-bundled packs)
- **Same repo as the plugin**, kept out of installs:
  ```
  scribb/
    plugin/        # what installs (marketplace path + npm "files")
    catalog/
      catalog.json
      packs/<id>/
    evals/
    docs/
  ```
- Catalog entries are either packs hosted in `catalog/packs/` or links to external repos pinned to a commit.
- Clients fetch `catalog/catalog.json` from `main` over HTTPS (GitHub raw or the jsDelivr CDN for GitHub) and cache it in the user scope for 24h, working offline from the cache. When the webapp exists, the URL points at its API with the same schema.
- `/scribb:style add <git-url | path>` and picking from the catalog: show `style.md` + rule list + diff → approve (approver recorded) → copy into user or project scope, recording source and version. Packs containing executable files are refused. Packs are markdown, YAML and JSON only. `/scribb:style update` pulls changes, again with review.
- Contributions are PRs that add to `catalog/`. CI checks licence, no executables, naming by traits (014), and evals (015).
- Split `catalog/` into its own repo (`git subtree split`) only if PR volume or ownership calls for it.

## Release lifecycle
| Change | How it reaches users |
|---|---|
| New catalog pack | Merge to `main`; appears at the next catalog refresh. No plugin release |
| Promote to bundle | Passed evals, been in the catalog a while, good ratings and installs. `git mv catalog/packs/x plugin/packs/x` in a **minor** release |
| Update a bundled pack | Bump the pack `version`; styles that `extends:` it see "review changes?" in `/scribb:style` |
| Remove a bundled pack | **Major** release only, after a deprecation period of at least one minor release. `doctor` offers to copy the last version into the user scope |

- Versioning: the plugin uses semver; each pack has its own `version`; `extends:` records the version it extended.

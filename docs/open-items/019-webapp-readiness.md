# 019 — Webapp readiness

Status: deferred (revisit later)

## Ideas recorded, not decided
- JSON Schemas as the shared contract (pack frontmatter, memory, brief, format, config, catalog entry, telemetry event), validated in CI. The webapp's tables and API payloads would be generated from them.
- One `config.yaml` per scope.
- Stable IDs everywhere (`pack-id@version`, memory, rule and nudge IDs) for file ↔ database sync.
- Scope mapping: built-in → public library, user → account, project → workspace, local → the user's settings for that workspace. Approver fields become real user IDs.
- A future `scribb sync` (CLI, 010) mirrors the user and project scopes to the webapp.
- The catalog URL moves to the webapp API (018).

Note: a schema for pack frontmatter and config is probably needed anyway for CI pack validation (015, 018). Decide when implementation starts.

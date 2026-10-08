# 007 — Harness-neutral architecture and the "checker"

Status: decided, needs implementation

## Decision
- **No custom CLI or runtime in v1** (see 010).
- **The deterministic rule engine is called "the checker"** everywhere in skills, hooks, docs and config. **Vale** is the only engine in v1, and it's optional. Swapping it for another engine should only touch the checker wrapper and the engine's rule folders.
- **One entry point:** the plugin ships `bin/scribb-check` (bash). Hooks, skills and CI only call `scribb-check <files>`, never the engine directly. It:
  - reads `checker:` from scribb config (default `vale`),
  - resolves the config by scope (local > project),
  - runs the engine and normalises its output to `file:line:severity:rule:message`,
  - exits 0 when the engine is missing (with one notice), so nothing breaks.
- **Rule format is engine-specific, and kept in its own folder:** `packs/<kind folder>/<id>/checks/vale/*.yml`. A future engine adds `checks/<engine>/` beside it. Prose guidance and examples are engine-neutral.
- **Severity map:** our severity (hard/convention/preference) maps to the engine's levels (Vale: error/warning/suggestion). Freedom maps to the engine's minimum alert level (Vale: `MinAlertLevel`).
- **Engine config is generated into `.scribb/checker/`,** not the repo root:
  - project: `.scribb/checker/vale.ini`,
  - local override: `.scribb/local/checker/vale.ini`.

  The wrapper passes `--config`. The generated file holds:
  - styles = base + content type + style,
  - file-pattern sections mapping paths to content types (`[*.tsx]` → ux-microcopy, `[docs/**.md]` → tech-docs),
  - the minimum alert level from freedom.
- **Storage: four scopes.** Precedence: piece (brief) > local > project > user > built-in.
  - Built-in: ships inside the plugin. Users can't edit it; they extend it with `extends:`.
  - User: `~/.config/scribb/` (respects `$XDG_CONFIG_HOME`; can be overridden with `$SCRIBB_HOME`). Personal styles, global defaults, memories that apply everywhere, and an index of approvals used to promote memories across projects.
  - Project: `.scribb/`, committed. Team defaults, styles, memories, glossary, checker config.
  - Local: `.scribb/local/`, gitignored (onboarding adds the entry). Personal overrides for this repo, personal memories for this repo, the inbox, hook retry state, the write-session flag.
- **Skills follow the Agent Skills standard** (SKILL.md) and are shared across tools. They handle the fuzzy work: merging prose guidance, applying the brief, saving memories.
- **Hooks are thin per-tool adapters that call `scribb-check`.** Real enforcement is `scribb-check` in pre-commit or CI.
- **Layout:** `skills/` (shared) + `packs/` + `bin/` + `adapters/{claude-code,codex,generic}`. Subagents exist only in Claude Code; other tools get the same workflows as skills.

## Open questions
- Can the engine's file-pattern sections express everything we need for the brief, or does the brief stay prose-only?
- The exact severity → level map, and how freedom overrides it per piece (env var read by the wrapper?).
- Editor integrations (for example, Vale's VS Code extension) look for config at the repo root. Do we offer an optional root symlink?

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- `scribb-check` output is `file:line:col:action:severity:rule:message` (`action` is block, warn or suggest, from the freedom table). Exit 1 means something blocks.
- Severity map: Vale `error` = hard, `warning` = convention, `suggestion` = preference.
- **Changed:** at runtime the Vale config is generated in a temp folder for each run, so a zero-config install writes nothing into the repo. `scribb-check --export .scribb/checker` writes a standalone `vale.ini` plus rules for CI and editor extensions (offered by `/scribb:setup --ci`). This answers the root-symlink question: point the editor at `.scribb/checker/vale.ini`.
- Machine-local state (session flags, retry counts) lives in the plugin data dir (`${CLAUDE_PLUGIN_DATA}`, else `~/.cache/scribb`), not `.scribb/local/`. `.scribb/local/` holds only the inbox, local config, memories and ratings, and writes a self-ignoring `.gitignore` when it's created.
- `vocab.txt` in any scope lists accepted terms (product names); they become a Vale vocabulary.
- The brief stays prose-only; file-pattern sections only map paths to content types.

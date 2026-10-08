---
name: setup
description: Optional team setup for scribb.me in this repo. Writes the committed .scribb/ folder (default style, which files are Docs, UI copy and newsletters, freedom, glossary), adds .scribb/local/ to .gitignore, and can export a checker config for CI and editors. Use when the user wants to configure scribb for a team or repo, not for first use; scribb works without setup.
disable-model-invocation: true
argument-hint: "[--ci]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-check *)
---

# /scribb:setup

scribb works without setup. This writes shared settings for everyone in the repo. Keep it short: at most three questions, each with a sensible default.

Current state:
!`"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config" status`

Helper: `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"`.

## Steps
1. **Look first.** Check which kinds of files the repo has (`*.md`, `*.mdx`, `*.tsx`, `*.jsx`, `locales/` or `i18n/` JSON, a `newsletter/` or `emails/` folder) so the defaults fit. If the repo has no UI code, don't ask about UI copy. For docs, read the real layout instead of assuming folder names: the top-level docs folders, and the table of contents if there is one (GitBook `SUMMARY.md` and `.gitbook.yaml`, Docusaurus `sidebars.js`, MkDocs `mkdocs.yml` `nav`). Group the sections you find into product docs (getting started, guides, help) and developer docs (API, SDK, CLI reference, integrations).
2. **Ask** (one AskUserQuestion call, up to three questions):
   - Default style for the team: list styles from `scribb-config packs --kind style` by tagline, plus "None (neutral house style)" first and recommended.
   - Which docs sections are developer docs: offer the grouping from step 1 (for example `api/*, reference/*`) and "None; decide per page". Everything else in Markdown stays product docs.
   - Lock freedom for compliance docs? Default no. If yes, set `freedom: strict` in the project scope.
3. **Write** with `scribb-config set <key> <value> --scope project`: `style`, the paths for each content type the repo has (`paths_developer_docs` for the developer docs sections, `paths_ui`, `paths_newsletter`; leave `paths_docs` alone unless product docs shouldn't cover all Markdown), and `freedom` only if they chose to lock it.
4. **Glossary** (optional): if they name product terms, save each as a project memory with the `remember` steps (kind `term`).
5. **.gitignore**: make sure `.scribb/local/` is listed; add it if not.
6. **CI and editors** (if `--ci` was passed, or they ask): run `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-check" --export .scribb/checker`. That writes `.scribb/checker/vale.ini` and the rules, so CI or an editor extension can run `vale --config=.scribb/checker/vale.ini <files>`. Offer a minimal GitHub Actions step that installs Vale and runs that command on changed docs.
7. **Finish** with the files written and a one-line reminder to commit `.scribb/` (but not `.scribb/local/`).

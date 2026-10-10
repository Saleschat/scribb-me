---
name: setup
description: Optional team setup for scribb.me in this repo. Writes the committed .scribb/ folder (default style, which files are docs, UI copy, newsletters, website pages and sales materials, freedom, glossary), adds .scribb/local/ to .gitignore, and can export a checker config for CI and editors. Use when the user wants to configure scribb for a team or repo, not for first use; scribb works without setup.
disable-model-invocation: true
argument-hint: "[--ci]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**) Bash(git check-ignore *) Bash(git ls-files *)
---

# /scribb:setup

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

scribb works without setup. This writes shared settings for everyone in the repo. Keep it short: at most three questions, each with a sensible default.

Current state:
!`"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config" status`

## Where you're running
Look at this path: `${CLAUDE_PLUGIN_ROOT}/scripts`.
- **Claude Code:** it's a real folder path. Use the helpers and follow the numbered steps; the "In chat" section doesn't apply. If the setup above is still a literal `!` command (that happens when the plugin is synced from claude.ai), run that command yourself first, on its own.
- **claude.ai chat, or another app without scribb's helpers:** it still reads `${CLAUDE_PLUGIN_ROOT}`. Don't run any `${CLAUDE_PLUGIN_ROOT}` command; skip to **In chat** at the end.

Helper: `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config"`.

## Steps
1. **Look first.** Check which kinds of files the repo has (`*.md`, `*.mdx`, `*.tsx`, `*.jsx`, `locales/` or `i18n/` JSON, folders of newsletter issues or emails such as `newsletter/`, `emails/` or `issues/`, website or marketing pages such as `site/`, `marketing/` or `landing/`, and sales materials such as `sales/`, `proposals/` or `decks/`) so the defaults fit. If the repo has no UI code, don't ask about UI copy. For docs, read the real layout instead of assuming folder names: the top-level docs folders, and the table of contents if there is one (GitBook `SUMMARY.md` and `.gitbook.yaml`, Docusaurus `sidebars.js`, MkDocs `mkdocs.yml` `nav`). Group the sections you find into product docs (getting started, guides, help) and developer docs (API, SDK, CLI reference, integrations).
2. **Ask** (one AskUserQuestion call, up to three questions):
   - Default style for the team: list styles from `scribb-config packs --kind style` by tagline, plus "None (neutral house style)" first and recommended.
   - Which folders hold developer docs, newsletters, website pages or sales materials: offer the grouping from step 1 (for example developer docs `api/*, reference/*`, newsletters `emails/*`, website `marketing/*`, sales `proposals/*`) and "None; decide per piece". Everything else in Markdown stays product docs.
   - Lock freedom for compliance docs? Default no. If yes, set `freedom: strict` in the project scope.
3. **Write** with `scribb-config set <key> <value> --scope project`: `style`, the paths for each content type the repo has (`paths_developer_docs` for the developer docs sections, `paths_ui`, `paths_newsletter`, `paths_website`, `paths_sales`; leave `paths_docs` alone unless product docs shouldn't cover all Markdown), and `freedom` only if they chose to lock it.
4. **Glossary** (optional): if they name product terms, save each as a project memory with the `remember` steps (kind `term`).
5. **.gitignore**: make sure `.scribb/local/` is listed; add it if not.
6. **CI and editors** (if `--ci` was passed, or they ask): run `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check" --export .scribb/checker`. That writes `.scribb/checker/vale.ini` and the rules, so CI or an editor extension can run `vale --config=.scribb/checker/vale.ini <files>`. Offer a minimal GitHub Actions step that installs Vale and runs that command on changed docs.
7. **Finish** with the files written and a one-line reminder to commit `.scribb/` (but not `.scribb/local/`).

## In chat
This command configures a code repository, so it only works in Claude Code. Say so in one line. In chat, the user can put team defaults in their Project instructions instead, for example: `Write with scribb.me. Our docs are product docs; use the crisp-product-ui style for UI copy.`

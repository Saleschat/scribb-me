---
name: review
description: Review existing prose with scribb.me (pasted text, a file, a folder or a git diff) against the base anti-AI-writing rules, the content type, the active style and memories. Reports findings; rewrites only if asked. Use when the user asks to review, check, lint or proofread docs, a README, release notes, UI copy or a newsletter.
argument-hint: "<file | folder | diff | text> [--fix] [--freedom <level>]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-check *) Bash(git diff *)
---

# /scribb:review

Target: `$ARGUMENTS`

Helpers: `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-check"`, `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"`. Plugin root: `${CLAUDE_PLUGIN_ROOT}`.

## Steps
1. **Work out the target.**
   - A file or folder: the matching files (each content type's paths, as `scribb-config status` lists them: Docs `*.md`, `*.mdx`; UI copy `*.tsx`, `*.jsx`; Newsletter `newsletter/*`, `newsletters/*`). For more than about 10 files, check them all but review the 5 with the most checker findings, and say so.
   - "my changes", "the diff", a branch or PR: `git diff` for the changed files; review only the changed lines and their paragraphs.
   - Pasted text: write it to a temp `.md` file (UI strings: `.jsx`).
   - No target: ask what to review.
2. **Checker.** Run `scribb-check --session ${CLAUDE_SESSION_ID} [--freedom <f>] <files>`. If Vale isn't installed, say so once and continue with the review.
3. **Review.** Send each piece to the `scribb-reviewer` agent with the content type, freedom, style and the plugin root. Run several in parallel for several files.
4. **Report**, grouped by file, most important first:
   - `file:line` — the quoted words — what's wrong — the fix.
   - Checker findings and reviewer findings together, without duplicates.
   - End with a one-line verdict per file (ready / minor fixes / needs revision).
5. **Rewrite only if asked** (`--fix`, or the user says so after the report). Then fix with minimal changes and re-run the checker.

Don't edit anything during a plain review. If a finding looks like a false positive of a checker rule, say so and mention `/scribb:report` so the user can report it.

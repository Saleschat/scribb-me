---
name: review
description: Review existing prose with scribb.me (pasted text, a file, a folder or a git diff) against the base anti-AI-writing rules, the content type, the active style and memories. Reports findings; rewrites only if asked. Use when the user asks to review, check, lint or proofread docs, a README, release notes, UI copy or a newsletter.
argument-hint: "<file | folder | diff | text> [--fix] [--freedom <level>]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**) Bash(git diff *)
---

# /scribb:review

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

Target: `$ARGUMENTS`

Helpers: `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check"`, `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config"`. Plugin root: `${CLAUDE_PLUGIN_ROOT}`.

## Steps
1. **Work out the target.**
   - A file or folder: the matching files (each content type's paths, as `scribb-config status` lists them: Docs `*.md`, `*.mdx`; UI copy `*.tsx`, `*.jsx`; Newsletter `newsletter/*`, `newsletters/*`). For more than about 10 files, check them all but review the 5 with the most checker findings, and say so.
   - "my changes", "the diff", a branch or PR: `git diff` for the changed files; review only the changed lines and their paragraphs.
   - Pasted text: don't write a file. Check it with `scribb-check --session ${CLAUDE_SESSION_ID} --content-type <ct> --text "<the text>"` and give the reviewer the text itself.
   - No target: ask what to review.
2. **Checker.** Run `scribb-check --session ${CLAUDE_SESSION_ID} [--freedom <f>] <files>`. If Vale isn't installed, say so once and continue with the review.
3. **Review.** Get the guidance once per content type with `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide" --content-type <ct> --session ${CLAUDE_SESSION_ID}`. Send each piece to the `scribb-reviewer` agent with the content type, freedom, style, the plugin root, and that guidance text. Run several in parallel for several files.
4. **Report**, grouped by file, most important first:
   - `file:line` — the quoted words — what's wrong — the fix.
   - Checker findings and reviewer findings together, without duplicates.
   - End with a one-line verdict per file (ready / minor fixes / needs revision).
5. **Rewrite only if asked** (`--fix`, or the user says so after the report). Then fix with minimal changes and re-run the checker.

Don't edit anything during a plain review. If a finding looks like a false positive of a checker rule, say so and mention `/scribb:report` so the user can report it.

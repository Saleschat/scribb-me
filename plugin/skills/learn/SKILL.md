---
name: learn
description: Teach scribb.me. (a) Learn a writing style from sources (files, a website's pages, an RSS or Substack feed, an export, pasted text) and save it as a style pack after approval. (b) Review the inbox of captured corrections and save the approved ones as memories. Use when the user wants scribb to write like someone or something, or to go through suggested preferences.
argument-hint: "<sources...> | inbox"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**) Read(~/.config/scribb/**) Write(~/.config/scribb/**) Edit(~/.config/scribb/**)
---

# /scribb:learn

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

Arguments: `$ARGUMENTS`

Helper: `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"`. Plugin root: `${CLAUDE_PLUGIN_ROOT}`.

## `inbox` (or no sources given and the inbox isn't empty)
1. Hand the job to the `scribb-learner` agent (Job B), with the plugin root `${CLAUDE_PLUGIN_ROOT}`.
2. Show its proposals as one multi-select (AskUserQuestion, `multiSelect: true`), each labelled by its statement, with the suggested scope in the description.
3. For each one picked, save it here, without invoking `/scribb:remember` (a skill call would ask for permission). Write the memory file to the scope's `memories/` folder in the same format the `remember` skill uses (frontmatter: id, kind, scope, statement, confidence, evidence, proposed_by: scribb-learner, approved_by from `scribb-config approver`, approved_at, promoted_to_rule: null). Then run `scribb-config record-approval <scope> "<statement>"`, and delete the inbox files it came from. Use the learner's kind, confidence, evidence and suggested scope; ask once if the user wants to change scopes.
4. For each one not picked, append it to `.scribb/local/rejected.txt` and delete its inbox files, so it isn't suggested again.

## Sources: learn a style
1. **Gather.** Accept files the user names or attaches (md, txt, pdf, docx), page URLs, a sitemap or RSS feed (at most about 20 pages), a Substack (`<name>.substack.com/feed`, free posts only), or a social media export. Don't scrape sites or log in anywhere. If the user names a person or publication without sources, ask for links or files.
2. **Ask** the name and where it lives, in one AskUserQuestion: a private style (user scope, any name), a team style (project scope), or "I'll share it" (named by traits, only from openly licensed material or with the writer's permission; examples become original rewrites).
3. **Learn.** Hand the job to the `scribb-learner` agent (Job A), with the sources, the scope, the name and the plugin root.
4. **Show the proposal**: tagline, traits, `summary.md`, the sample paragraph next to the neutral one from the content type's `sample.md`, the validation score, the sample-size warning if any, and any proposed checker rules.
5. **Approve.** On yes, write the files to `<scope dir>/packs/styles/<id>/` (`scribb-config paths`). Add `approved_by` (from `scribb-config approver`) and `approved_at` to `pack.yaml`. Save `sources.json` there with metadata only (URL or file name, fetched date, and a content hash from `scribb-config hash <files>`). Never save raw source text in the repo; if useful, cache it under the user dir in `sources-cache/<id>/`.
6. Offer to switch to it now (`scribb-config set style <id> --scope local`).

Re-learning an existing style: run the same steps, then show a diff against the current pack and ask before replacing anything.

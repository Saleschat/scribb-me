---
name: learn
description: Teach scribb.me. (a) Learn a writing style from sources (files, a website's pages, an RSS or Substack feed, an export, pasted text) and save it as a style pack after approval. (b) Review the inbox of captured corrections and save the approved ones as memories. Use when the user wants scribb to write like someone or something, or to go through suggested preferences.
argument-hint: "<sources...> | inbox"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *)
---

# /scribb:learn

Arguments: `$ARGUMENTS`

Helper: `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"`. Plugin root: `${CLAUDE_PLUGIN_ROOT}`.

## `inbox` (or no sources given and the inbox isn't empty)
1. Hand the job to the `scribb-learner` agent (Job B), with the plugin root.
2. Show its proposals as one multi-select (AskUserQuestion, `multiSelect: true`), each labelled by its statement, with the suggested scope in the description.
3. For each one picked, follow the `remember` skill's steps 3–6 with the learner's kind, confidence and evidence, and the scope from the proposal (ask once if the user wants to change scopes).
4. For each one not picked, append it to `.scribb/local/rejected.txt` and delete its inbox files, so it isn't suggested again.

## Sources: learn a style
1. **Gather.** Accept files the user names or attaches (md, txt, pdf, docx), page URLs, a sitemap or RSS feed (at most about 20 pages), a Substack (`<name>.substack.com/feed`, free posts only), or a social media export. Don't scrape sites or log in anywhere. If the user names a person or publication without sources, ask for links or files.
2. **Ask** the name and where it lives, in one AskUserQuestion: a private style (user scope, any name), a team style (project scope), or "I'll share it" (named by traits, only from openly licensed material or with the writer's permission; examples become original rewrites).
3. **Learn.** Hand the job to the `scribb-learner` agent (Job A), with the sources, the scope, the name and the plugin root.
4. **Show the proposal**: tagline, traits, `summary.md`, the sample paragraph next to the neutral one from the content type's `sample.md`, the validation score, the sample-size warning if any, and any proposed checker rules.
5. **Approve.** On yes, write the files to `<scope dir>/packs/<id>/` (`scribb-config paths`). Add `approved_by` (from `scribb-config approver`) and `approved_at` to `pack.yaml`. Save `sources.json` there with metadata only (URL or file name, fetched date, a content hash). Never save raw source text in the repo; if useful, cache it under the user dir in `sources-cache/<id>/`.
6. Offer to switch to it now (`scribb-config set style <id> --scope local`).

Re-learning an existing style: run the same steps, then show a diff against the current pack and ask before replacing anything.

---
name: report
description: Draft a GitHub issue for scribb.me, such as a checker false positive, a missed AI-writing habit, or a bug in a hook or skill. Shows exactly what would be sent and submits only after the user approves. Use when the user wants to report a problem with scribb or a rule.
disable-model-invocation: true
argument-hint: "<what went wrong>"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

# /scribb:report

Current setup:
!`"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config" status`

## Where you're running
Look at this path: `${CLAUDE_PLUGIN_ROOT}/scripts`.
- **Claude Code:** it's a real folder path. Use the helpers and follow the numbered steps; the "In chat" section doesn't apply. If the setup above is still a literal `!` command (that happens when the plugin is synced from claude.ai), run that command yourself first, on its own.
- **claude.ai chat, or another app without scribb's helpers:** it still reads `${CLAUDE_PLUGIN_ROOT}`. Don't run any `${CLAUDE_PLUGIN_ROOT}` command; skip to **In chat** at the end.

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

Problem: `$ARGUMENTS`

1. Work out the kind, which matches an issue template in the repo: false positive (a rule flagged good text; template `false-positive`), missed pattern (`missed-pattern`), new content type (`new-content-type`), or bug (`bug`). If the user wants to share a fix they already made locally, suggest `/scribb:contribute` instead, which opens a pull request.
2. Draft the issue:
   - Title: `False positive: <RuleID> flags "<short phrase>"`, `Missed pattern: …`, `Content type: …`, or `Bug: …`.
   - Body: the template's fields as headings, filled in: what happened, what was expected, the smallest example text that shows it (written fresh or trimmed by the user; never paste private content without asking), the rule ID, and the versions from `scribb-config versions` (scribb, the pack, Vale, OS).
3. Show the full title and body and say: "This is exactly what will be posted publicly to github.com/Saleschat/scribb-me." Let the user edit it.
4. Only after they approve: if `gh` is installed and signed in, run `gh issue create --repo Saleschat/scribb-me --title … --body … --label <false-positive|missed-pattern|content-type|bug>`. Otherwise give them the template link with the title prefilled: `https://github.com/Saleschat/scribb-me/issues/new?template=<template>.yml&title=<urlencoded>`, and the body text to paste.

## In chat
Do steps 1–3. You can't run `gh` or `scribb-config` here, so leave out the versions you can't see, and give the user the template link with the title filled in (step 4) and the body to paste.

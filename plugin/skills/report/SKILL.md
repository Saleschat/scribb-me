---
name: report
description: Draft a GitHub issue for scribb.me, such as a checker false positive, a missed AI-writing habit, or a bug in a hook or skill. Shows exactly what would be sent and submits only after the user approves. Use when the user wants to report a problem with scribb or a rule.
disable-model-invocation: true
argument-hint: "<what went wrong>"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *)
---

# /scribb:report

Problem: `$ARGUMENTS`

1. Work out the kind, which matches an issue template in the repo: false positive (a rule flagged good text; template `false-positive`), missed pattern (`missed-pattern`), new content type (`new-content-type`), or bug (`bug`). If the user wants to share a fix they already made locally, suggest `/scribb:contribute` instead, which opens a pull request.
2. Draft the issue:
   - Title: `False positive: <RuleID> flags "<short phrase>"`, `Missed pattern: …`, `Content type: …`, or `Bug: …`.
   - Body: the template's fields as headings, filled in: what happened, what was expected, the smallest example text that shows it (written fresh or trimmed by the user; never paste private content without asking), the rule ID and pack version, `scribb` version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, Vale version, OS.
3. Show the full title and body and say: "This is exactly what will be posted publicly to github.com/Saleschat/scribb-me." Let the user edit it.
4. Only after they approve: if `gh` is installed and signed in, run `gh issue create --repo Saleschat/scribb-me --title … --body … --label <false-positive|missed-pattern|content-type|bug>`. Otherwise give them the template link with the title prefilled: `https://github.com/Saleschat/scribb-me/issues/new?template=<template>.yml&title=<urlencoded>`, and the body text to paste.

---
name: scribb-report
description: Draft a GitHub issue for scribb.me, such as a rule that flagged writing that was fine, a habit scribb missed, a kind of writing it should cover, or a bug. Shows exactly what would be posted. Use when the user wants to report a problem with scribb.
---

# scribb-report

1. **Work out the kind:** false positive (template `false-positive`), missed pattern (`missed-pattern`), new content type (`new-content-type`), or bug (`bug`).
2. **Draft the issue.**
   - Title: `False positive: <RuleID> flags "<short phrase>"`, `Missed pattern: …`, `Content type: …` or `Bug: …`.
   - Body: what happened, what was expected, and the smallest example text that shows it. The example should be trimmed or rewritten; never paste private or customer text without asking. Add the rule ID if the checker gave one, and say it happened in claude.ai chat.
3. **Show the full title and body** and say that it will be public on github.com/Saleschat/scribb-me.
4. **Give the user the link** to open it themselves, with the title filled in: `https://github.com/Saleschat/scribb-me/issues/new?template=<template>.yml&title=<url-encoded title>`, and the body to paste.

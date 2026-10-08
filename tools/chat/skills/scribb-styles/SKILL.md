---
name: scribb-styles
description: Show and compare scribb.me's writing styles and content types, with the same sample text written in each, and explain how to use one. Use when the user asks which styles scribb has, wants to compare them, or asks what scribb is doing.
---

# scribb-styles

{{REFERENCES}}

- **Which styles are there:** list each style in `references/styles/` by its tagline (from `pack.yaml`). Show its `sample.md` next to the neutral sample from the content type it suits (`references/content-types/<id>/sample.md`), so the user can compare them side by side.
- **Use a style:** in chat there are no settings. The user names the style in a request ("write this in the direct-developer-docs style"), or adds a line to their Project instructions, such as `Write with scribb.me in the direct-developer-docs style.`
- **What scribb does here:** it applies rules against AI writing habits and the conventions of four content types (product docs, developer docs, UI copy, newsletters), checks drafts with a built-in checker, and reviews them. Hooks, the reviewer agent, repo settings and team memories are Claude Code features.
- **Make a new style:** suggest the scribb-learn skill.
- **Turn scribb off:** turn the scribb-chat plugin off in **Customize > Plugins**.

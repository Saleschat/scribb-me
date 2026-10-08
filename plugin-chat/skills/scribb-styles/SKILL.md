---
name: scribb-styles
description: Show and compare scribb.me's writing styles and content types, with the same sample text written in each, and explain how to use one. Use when the user asks which styles scribb has, wants to compare them, or asks what scribb is doing.
---

# scribb-styles

Everything is in this skill's own folder; paths are relative to this file:
- `references/base/guide.md`: habits that mark machine-written text. Always applies.
- `references/content-types/<id>/`: `guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Each `pack.yaml` has the tagline and default freedom.
  - `product-docs`: getting started, how-tos, help articles, READMEs and other repo files, release notes. Default freedom strict.
  - `developer-docs`: API, SDK and CLI reference, integration guides. Strict.
  - `ux-microcopy`: interface strings such as buttons, dialogs, errors, empty states, toasts. Strict.
  - `newsletter`: newsletter issues, product updates, welcome emails. Balanced.
- `references/styles/<id>/`: optional voices. Use one only when the user names it. On a conflict, the content type wins.

- **Which styles are there:** list each style in `references/styles/` by its tagline (from `pack.yaml`). Show its `sample.md` next to the neutral sample from the content type it suits (`references/content-types/<id>/sample.md`), so the user can compare them side by side.
- **Use a style:** in chat there are no settings. The user names the style in a request ("write this in the direct-developer-docs style"), or adds a line to their Project instructions, such as `Write with scribb.me in the direct-developer-docs style.`
- **What scribb does here:** it applies rules against AI writing habits and the conventions of four content types (product docs, developer docs, UI copy, newsletters), checks drafts with a built-in checker, and reviews them. Hooks, the reviewer agent, repo settings and team memories are Claude Code features.
- **Make a new style:** suggest the scribb-learn skill.
- **Turn scribb off:** turn the scribb-chat plugin off in **Customize > Plugins**.

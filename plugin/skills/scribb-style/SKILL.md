---
name: scribb-style
description: Background writing guidance from scribb.me. Use whenever you write or substantially revise prose for people to read, such as documentation, READMEs, guides, how-tos, release notes, changelogs, error messages, empty states, dialogs, toasts, button labels and other UI copy, newsletters and product-update emails, or a written piece in chat. Applies the base anti-AI-writing rules, the content type's conventions, the active style and approved memories.
user-invocable: false
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

# scribb.me writing guidance

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

Active setup:
!`"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config" status --session "${CLAUDE_SESSION_ID}"`

## Where you're running
Look at this path: `${CLAUDE_PLUGIN_ROOT}/scripts`.
- **Claude Code:** it's a real folder path. Use the helpers and follow the numbered steps; the "In chat" section doesn't apply. If the setup above is still a literal `!` command (that happens when the plugin is synced from claude.ai), run that command yourself first, on its own.
- **claude.ai chat, or another app without scribb's helpers:** it still reads `${CLAUDE_PLUGIN_ROOT}`. Don't run any `${CLAUDE_PLUGIN_ROOT}` command; skip to **In chat** at the end. Everything you need is in this skill's own folder: `references/` (the guides) and `scripts/check.py` (the checker). Paths are relative to this file, and `${CLAUDE_SKILL_DIR}` points at the folder where an app fills it in.

If the setup above says scribb is off, stop here and write normally.

1. **Pick the content type.** Product docs (`product-docs`) for getting started, how-tos, help articles, READMEs and release notes: technical enough to be exact, no more. Developer docs (`developer-docs`) for API, SDK and CLI reference and integration guides, for a reader who writes code. Decide by what the page is for, not its folder; a `scribb-content-type:` frontmatter key settles it. UI copy (`ux-microcopy`) for strings in an interface; Newsletter (`newsletter`) for newsletter issues, product updates and welcome emails. The file path usually settles it; for a piece drafted in chat, the request does.
2. **Get the guidance** before a piece longer than a few sentences, in one call: `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide" --content-type <ct> --session ${CLAUDE_SESSION_ID}`, adding `--format <id>` if a format fits (`--format list` lists them). It prints the base, content type, format and style guides, the UI role map for UI copy, and the approved memories.
3. **Follow the memories** in the session-start note. They're approved by the user or team and beat the style.
4. **Write at the active freedom.** Strict: conventional, no flourishes. Balanced: one good version. Expressive: freer, and offer 2–3 options for short strings.
5. **Respect what the user says now.** An explicit instruction for this piece beats the format, the content type and the style. If the user says to skip scribb, skip it.

After you write to a matching file, the checker may send findings back; fix them with minimal changes. For a careful, reviewed draft, suggest `/scribb:write`.

## In chat
The references, all relative to this skill's folder:
- `references/base/guide.md` (always), `references/base/summary.md`
- `references/content-types/<id>/guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Content types: `product-docs`, `developer-docs`, `ux-microcopy`, `newsletter`; each `pack.yaml` has its tagline and default freedom.
- `references/styles/<id>/guide.md`, `summary.md`, `sample.md`. Styles: `direct-developer-docs`, `crisp-product-ui`.

Before a piece longer than a few sentences, read `references/base/guide.md`, the content type's `guide.md`, a matching format, and the style's guide if the user named a style. For short pieces, the `summary.md` files are enough. Then write as described in steps 3–5 above. For a checked and reviewed draft, suggest asking for `/scribb:write` (or "write this with scribb").

When the user corrects your wording or tone ("don't say X", "we call it Y", "too formal"), fix it, then offer once, in one line, to save it with the `remember` skill so it applies in future chats. Don't offer again for the same correction.

---
name: scribb-style
description: Background writing guidance from scribb.me. Use whenever you write or substantially revise prose for people to read, such as documentation, READMEs, guides, how-tos, release notes, changelogs, error messages, empty states, dialogs, toasts, button labels and other UI copy, or a written piece in chat. Applies the base anti-AI-writing rules, the content type's conventions, the active style and approved memories.
user-invocable: false
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *)
---

# scribb.me writing guidance

Active setup:
!`"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config" status --session "${CLAUDE_SESSION_ID}"`

If the setup above says scribb is off, stop here and write normally.

1. **Pick the content type.** Docs (`tech-docs`) for documentation and long-form technical prose; UI copy (`ux-microcopy`) for strings in an interface. The file type usually settles it.
2. **Read the guides** before a piece longer than a few sentences:
   - `${CLAUDE_PLUGIN_ROOT}/packs/base/guide.md` (always)
   - `${CLAUDE_PLUGIN_ROOT}/packs/<content type>/guide.md`, and a matching file in its `formats/` if one fits (how-to, release note, error message, …)
   - for UI copy in components, `${CLAUDE_PLUGIN_ROOT}/packs/ux-microcopy/roles/shadcn.yaml` to map each component to its role
   - the active style's `guide.md`, if a style is set
3. **Follow the memories** in the session-start note. They're approved by the user or team and beat the style.
4. **Write at the active freedom.** Strict: conventional, no flourishes. Balanced: one good version. Expressive: freer, and offer 2–3 options for short strings.
5. **Respect what the user says now.** An explicit instruction for this piece beats the format, the content type and the style. If the user says to skip scribb, skip it.

After you write to a matching file, the checker may send findings back; fix them with minimal changes. For a careful, reviewed draft, suggest `/scribb:write`.

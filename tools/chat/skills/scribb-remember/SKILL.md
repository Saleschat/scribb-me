---
name: scribb-remember
description: Save a writing preference with scribb.me, such as a term to use, a word to avoid, a tone or a format, so Claude follows it in future chats. Use when the user says to remember a wording or style preference, or accepts scribb's offer to save a correction.
---

# scribb-remember

Chat has no scribb settings files, so a preference is kept where claude.ai already looks: the user's Project instructions or personal preferences.

1. **State it** as one imperative sentence that stands on its own, for example `Say "workspace", never "account", for the shared space a team works in.` Use the user's intent, not their exact words.
2. **Give the user one line to paste**, starting with `scribb memory:`, for example:
   `scribb memory: Say "workspace", never "account", for the shared space a team works in.`
   - Inside a Project: paste it into the Project's instructions, so it applies to every chat in that Project.
   - Everywhere: paste it into personal preferences in claude.ai's settings.
3. **Follow it for the rest of this chat** straight away.
4. Mention once that in Claude Code, scribb saves preferences for a repo or a whole team with `/scribb:remember`, and checks for them automatically.

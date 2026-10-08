---
name: scribb-guidance
description: Background writing guidance from scribb.me. Use whenever you write or substantially revise prose for people to read, such as documentation, READMEs, how-tos, help articles, release notes, API reference, error messages, dialogs, empty states, button labels and other UI copy, newsletters and product-update emails. Applies scribb's rules against AI writing habits and the conventions of that kind of writing.
---

# scribb.me writing guidance

Everything is in this skill's own folder; paths are relative to this file:
- `references/base/guide.md`: habits that mark machine-written text. Always applies.
- `references/content-types/<id>/`: `guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Each `pack.yaml` has the tagline and default freedom.
  - `product-docs`: getting started, how-tos, help articles, READMEs and other repo files, release notes. Default freedom strict.
  - `developer-docs`: API, SDK and CLI reference, integration guides. Strict.
  - `ux-microcopy`: interface strings such as buttons, dialogs, errors, empty states, toasts. Strict.
  - `newsletter`: newsletter issues, product updates, welcome emails. Balanced.
- `references/styles/<id>/`: optional voices. Use one only when the user names it. On a conflict, the content type wins.

1. **Pick the content type** from the request: product docs, developer docs, UI copy or a newsletter. If none fits, use the base guide alone.
2. **Read the guidance.** For a short piece, read `references/base/summary.md` and the content type's `summary.md`. For anything longer than a paragraph, read the full `guide.md` files and a matching format in `formats/`.
3. **Follow the user's own preferences first.** Their Project instructions, personal preferences or earlier messages beat scribb's style rules (lines starting with `scribb memory:` are ones they saved).
4. **Write at the content type's default freedom** unless the user asks otherwise. Strict: plain and conventional. Balanced: one good version. Expressive: freer, with 2–3 options for short strings.
5. For a longer piece, check it before you show it. If you can run code, check the text with the bundled checker. Save it to a file (`.jsx` for UI strings inside components, `.md` otherwise), then run:
`python3 scripts/check.py --content-type <id> --freedom <strict|balanced|expressive> [--style <id>] <file>`
It prints `file:line:col:action:severity:rule:message`, the same findings scribb gives in Claude Code. Fix every `block` finding and consider the `warn` ones. If you can't run code here, say once that the automatic check didn't run, and be extra careful in the review.

When the user corrects your wording or tone ("don't say X", "we call it Y", "too formal", "that sounds like AI"), fix it, then offer once, in one line, to save it with the scribb-remember skill so it applies in future chats. Don't offer again for the same correction.

For a checked and reviewed draft, the user can ask for the scribb-write skill ("write this with scribb").

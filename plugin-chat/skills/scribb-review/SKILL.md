---
name: scribb-review
description: Review writing with scribb.me. Checks pasted text or an uploaded file against scribb's rules against AI writing habits and the conventions of its content type (product docs, developer docs, UI copy, newsletter), and reports findings with exact quotes and fixes. Rewrites only if asked. Use when the user asks scribb to review, check or proofread something.
---

# scribb-review

Everything is in this skill's own folder; paths are relative to this file:
- `references/base/guide.md`: habits that mark machine-written text. Always applies.
- `references/content-types/<id>/`: `guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Each `pack.yaml` has the tagline and default freedom.
  - `product-docs`: getting started, how-tos, help articles, READMEs and other repo files, release notes. Default freedom strict.
  - `developer-docs`: API, SDK and CLI reference, integration guides. Strict.
  - `ux-microcopy`: interface strings such as buttons, dialogs, errors, empty states, toasts. Strict.
  - `newsletter`: newsletter issues, product updates, welcome emails. Balanced.
- `references/styles/<id>/`: optional voices. Use one only when the user names it. On a conflict, the content type wins.

1. **Target:** the pasted text, an uploaded file, or the piece earlier in the conversation the user points to. Work out its content type from the request and the text.
2. **Check.** If you can run code, check the text with the bundled checker. Save it to a file (`.jsx` for UI strings inside components, `.md` otherwise), then run:
`python3 scripts/check.py --content-type <id> --freedom <strict|balanced|expressive> [--style <id>] <file>`
It prints `file:line:col:action:severity:rule:message`, the same findings scribb gives in Claude Code. Fix every `block` finding and consider the `warn` ones. If you can't run code here, say once that the automatic check didn't run, and be extra careful in the review.
3. **Review.**
Review the text as a separate pass, as if someone else wrote it:
1. Read it once for meaning. Then set aside what you meant to say and read only what's on the page.
2. Go through `references/base/guide.md` one habit at a time. For each, quote every passage that shows it.
3. Do the same for the content type's guide, and check the format's required sections if a format applies.
4. Keep a finding only if a careful human editor would agree with it, and name the rule it breaks. Don't flag quotes, code or product names.
5. Watch for over-correction: one em dash, one list of three or one short sentence is fine. A repeated habit is the problem. Don't flatten the voice the user asked for.
4. **Report**, most important first. For each finding: the quoted words, what's wrong and which rule (base, content type or style), and the fix. Put checker findings and your own together without duplicates. End with a one-line verdict: ready, minor fixes, or needs revision.
5. **Rewrite only if the user asks.** Then fix with minimal changes and check again.

When the user corrects your wording or tone ("don't say X", "we call it Y", "too formal", "that sounds like AI"), fix it, then offer once, in one line, to save it with the scribb-remember skill so it applies in future chats. Don't offer again for the same correction.

---
name: scribb-write
description: Write a piece with scribb.me's full loop. Infers a brief (content type, format, audience, length, freedom, style), drafts, runs scribb's checker, reviews the draft in a separate pass, and revises, at most twice. Use when the user asks to write something "with scribb", or wants a careful, reviewed draft of docs, a README, release notes, API reference, UI copy or a newsletter.
---

# scribb-write

Everything is in this skill's own folder; paths are relative to this file:
- `references/base/guide.md`: habits that mark machine-written text. Always applies.
- `references/content-types/<id>/`: `guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Each `pack.yaml` has the tagline and default freedom.
  - `product-docs`: getting started, how-tos, help articles, READMEs and other repo files, release notes. Default freedom strict.
  - `developer-docs`: API, SDK and CLI reference, integration guides. Strict.
  - `ux-microcopy`: interface strings such as buttons, dialogs, errors, empty states, toasts. Strict.
  - `newsletter`: newsletter issues, product updates, welcome emails. Balanced.
- `references/styles/<id>/`: optional voices. Use one only when the user names it. On a conflict, the content type wins.

## 1. Brief
Infer it from the request. The user never writes a form.
- **Content type:** product docs, developer docs, UI copy or newsletter. Decide by what the piece is for: an API reference page is developer docs; a README or help article is product docs.
- **Format:** one of the content type's `formats/`, if one fits (for example `how-to`, `api-reference`, `error-message`, `product-update`).
- **Audience, length, freedom** (the content type's default unless the user says otherwise) and **style** (only if the user names one).

What the user says now beats the format, the format beats the content type, and the content type beats the style. Show the brief as one line, for example `Newsletter · product-update · customers · ≤250w · balanced`, and go on unless the user corrects it.

## 2. Draft
Read `references/base/guide.md`, the content type's `guide.md`, the format, and the style's `guide.md` if there is one. Follow the user's own preferences (Project instructions, personal preferences, lines starting with `scribb memory:`); they beat the style. Then write the draft.

## 3. Check
If you can run code, check the text with the bundled checker. Save it to a file (`.jsx` for UI strings inside components, `.md` otherwise), then run:
`python3 scripts/check.py --content-type <id> --freedom <strict|balanced|expressive> [--style <id>] <file>`
It prints `file:line:col:action:severity:rule:message`, the same findings scribb gives in Claude Code. Fix every `block` finding and consider the `warn` ones. If you can't run code here, say once that the automatic check didn't run, and be extra careful in the review.

## 4. Review
Unless the user asked to skip review:
Review the text as a separate pass, as if someone else wrote it:
1. Read it once for meaning. Then set aside what you meant to say and read only what's on the page.
2. Go through `references/base/guide.md` one habit at a time. For each, quote every passage that shows it.
3. Do the same for the content type's guide, and check the format's required sections if a format applies.
4. Keep a finding only if a careful human editor would agree with it, and name the rule it breaks. Don't flag quotes, code or product names.
5. Watch for over-correction: one em dash, one list of three or one short sentence is fine. A repeated habit is the problem. Don't flatten the voice the user asked for.

## 5. Revise
Fix what the check and the review found, then check again. Stop after two rounds, or earlier when nothing is left to fix.

## 6. Deliver
Show the piece. Then, in one or two lines: anything still flagged, and any facts you assumed that the user should confirm (names, numbers, labels, links).

When the user corrects your wording or tone ("don't say X", "we call it Y", "too formal", "that sounds like AI"), fix it, then offer once, in one line, to save it with the scribb-remember skill so it applies in future chats. Don't offer again for the same correction.

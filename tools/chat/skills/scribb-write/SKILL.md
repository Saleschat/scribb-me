---
name: scribb-write
description: Write a piece with scribb.me's full loop. Infers a brief (content type, format, audience, length, freedom, style), drafts, runs scribb's checker, reviews the draft in a separate pass, and revises, at most twice. Use when the user asks to write something "with scribb", or wants a careful, reviewed draft of docs, a README, release notes, API reference, UI copy or a newsletter.
---

# scribb-write

{{REFERENCES}}

## 1. Brief
Infer it from the request. The user never writes a form.
- **Content type:** product docs, developer docs, UI copy or newsletter. Decide by what the piece is for: an API reference page is developer docs; a README or help article is product docs.
- **Format:** one of the content type's `formats/`, if one fits (for example `how-to`, `api-reference`, `error-message`, `product-update`).
- **Audience, length, freedom** (the content type's default unless the user says otherwise) and **style** (only if the user names one).

What the user says now beats the format, the format beats the content type, and the content type beats the style. Show the brief as one line, for example `Newsletter · product-update · customers · ≤250w · balanced`, and go on unless the user corrects it.

## 2. Draft
Read `references/base/guide.md`, the content type's `guide.md`, the format, and the style's `guide.md` if there is one. Follow the user's own preferences (Project instructions, personal preferences, lines starting with `scribb memory:`); they beat the style. Then write the draft.

## 3. Check
{{CHECK}}

## 4. Review
Unless the user asked to skip review:
{{SELF_REVIEW}}

## 5. Revise
Fix what the check and the review found, then check again. Stop after two rounds, or earlier when nothing is left to fix.

## 6. Deliver
Show the piece. Then, in one or two lines: anything still flagged, and any facts you assumed that the user should confirm (names, numbers, labels, links).

{{CAPTURE}}

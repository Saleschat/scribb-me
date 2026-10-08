---
name: scribb-learn
description: Learn a writing style with scribb.me from samples the user uploads or pastes (blog posts, docs, newsletters, emails), and hand it back as a skill to upload to claude.ai and as a scribb style pack for Claude Code. Use when the user wants Claude to write like a person, publication or brand, or to capture their own voice.
---

# scribb-learn

Everything is in this skill's own folder; paths are relative to this file:
- `references/base/guide.md`: habits that mark machine-written text. Always applies.
- `references/content-types/<id>/`: `guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Each `pack.yaml` has the tagline and default freedom.
  - `product-docs`: getting started, how-tos, help articles, READMEs and other repo files, release notes. Default freedom strict.
  - `developer-docs`: API, SDK and CLI reference, integration guides. Strict.
  - `ux-microcopy`: interface strings such as buttons, dialogs, errors, empty states, toasts. Strict.
  - `newsletter`: newsletter issues, product updates, welcome emails. Balanced.
- `references/styles/<id>/`: optional voices. Use one only when the user names it. On a conflict, the content type wins.

A style is taste: what good writers would disagree about (rhythm, tone, word choice). Conventions every good writer of a kind follows belong to the content type, not the style.

1. **Gather samples:** files the user uploads or pastes, and pages only if you can fetch them in this chat. Don't scrape sites or log in anywhere. If the user names a writer without samples, ask for some.
2. **Check the sample:** aim for 5–20 pieces and about 3,000 words. Below that, say so and mark the style `confidence: low`. Drop quotes, reposts and co-written pieces. Hold back one piece for validation.
3. **Extract style, not content:** rhythm, sentence and paragraph length, density, person (you, we, I), how pieces open and close, habits, favoured and avoided words. Don't carry over topics, claims or distinctive phrases.
4. **Write it up:** a tagline, traits (formality, density, person, which content types it suits), a 5–10 bullet summary, a guide in your own words with a few original example sentences, and the content type's `sample.md` rewritten in this style. Use `references/styles/direct-developer-docs/` as the model.
5. **Validate:** write one paragraph on the held-back piece's topic in the new style, compare it with that piece, and give a 1–5 score with what matches and what doesn't.
6. **Hand it over**, after the user approves, in two forms:
   - **A skill for claude.ai:** a folder `<style-id>/` with one `SKILL.md`. Its frontmatter `name` is the style id, and its `description` says when to use it ("Write in the <name> style. Use when the user asks for <name>'s voice, or writes <kinds of pieces>."). The body holds the summary, the guide and the sample. If you can run code, zip the folder (the zip must contain the folder itself, not just its files) and give it to the user to upload in **Customize > Skills**. Otherwise give them the `SKILL.md` text.
   - **A scribb style pack for Claude Code:** `pack.yaml`, `summary.md`, `guide.md` and `sample.md`, for `~/.config/scribb/packs/styles/<style-id>/` (just them) or a repo's `.scribb/packs/styles/<style-id>/` (their team).

A private style can be named after anyone. A style meant to be shared is named by its traits ("Short, plain product updates"), and learned only from openly licensed writing or with the writer's permission.

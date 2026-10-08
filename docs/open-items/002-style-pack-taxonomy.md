# 002 — Pack taxonomy (traits and taglines)

Status: decided, needs implementation

## Decision
- **Median user picks by tagline.** Every style and content-type pack has:
  - `tagline`: one line describing it,
  - `sample`: the same shared reference paragraph rewritten in this pack, for side-by-side comparison. Pickers show 3 options.
- **Experts also filter by traits.** A small fixed set of traits, each with fixed values:

| Trait | Values | Applies to |
|---|---|---|
| `kind` | base · content-type · style | all |
| `medium` | docs · ui · marketing · editorial · social · email | content type (and which content types a style is `good_for`) |
| `formality` | formal · neutral · casual | style |
| `density` | terse · balanced · expansive | style |
| `person` | you · we · I · impersonal | style |
| `source_type` | individual · publication · brand · original | style |
| `license` | SPDX id | all; required for built-in packs |
| `tags` | free-form | all |

- Free tags that show up often get promoted to traits.

## Open questions
- How the webapp library shows traits as filters.

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- The shared reference texts are one per content type: `plugin/packs/content-types/tech-docs/sample.md` (rotating an API key) and `plugin/packs/content-types/ux-microcopy/sample.md` (the strings for deleting a project). Each style's `sample.md` rewrites both where its `good_for` includes them.
- `pack.yaml` fields are in `docs/pack-format.md`.

## Changed in v0.1: newsletter content type, no persona concept (2026-10-08)
- New content type `newsletter` (`medium: email`), for founders and creators sending issues, product updates and welcome emails. Its shared reference text is `plugin/packs/content-types/newsletter/sample.md` (a product-update issue).
- The `warm-and-plain` style was removed: a vague voice nobody would pick on purpose. New packs start from a persona and their tasks, and a persona's writing task is a **content type**, not a style.
- Content types are data: `pack.yaml` gained `label`, `match_order` and `review_threshold` (see `docs/pack-format.md`).

## Changed in v0.1: packs split by kind (2026-10-08)
- Content types and styles answer different questions (what kind of writing vs. who it sounds like), so they now live in different folders in every scope: `packs/base/`, `packs/content-types/<id>/`, `packs/styles/<id>/`, plus `packs/rules/` for promoted memory rules. `kind:` in `pack.yaml` must match the folder.
- Test for where a rule goes: if two excellent writers would both follow it, it's a content-type rule; if they'd disagree, it's a style rule.

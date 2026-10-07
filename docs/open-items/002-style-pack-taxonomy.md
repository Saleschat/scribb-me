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
- The shared reference texts are one per content type: `plugin/packs/tech-docs/sample.md` (rotating an API key) and `plugin/packs/ux-microcopy/sample.md` (the strings for deleting a project). Each style's `sample.md` rewrites both where its `good_for` includes them.
- `pack.yaml` fields are in `docs/pack-format.md`.

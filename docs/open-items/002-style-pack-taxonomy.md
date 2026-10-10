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

## Changed in v0.1: product docs and developer docs (2026-10-08)
- `tech-docs` is split into two content types with the same conventions but different readers:
  - `product-docs`: people using or evaluating the product. Getting started, how-tos, help articles, release notes, and GitHub repo files (README, CONTRIBUTING): technical enough to be exact, no more. Default for all Markdown.
  - `developer-docs`: people writing code against the product. API, SDK and CLI reference, integration guides.
- Developer docs have **no default paths**, because docs layouts vary too much (a GitBook repo, a Docusaurus site, a `docs/` folder). A file gets `developer-docs` from its frontmatter (`scribb-content-type: developer-docs`), from `paths_developer_docs` (which `/scribb:setup` proposes after reading the real layout, including GitBook `SUMMARY.md`), or from the request when Claude writes the page. If the checker hook picks product docs for a developer page, little is lost: the two share nearly all checker rules; the differences are in the guides and formats Claude applies.
- The built-in packs are marked as worked examples of each layer (base, content type, format, style), for people building their own. The explanation of the layers is in the README.

## Changed: no default folder for newsletters (2026-10-08)
- `newsletter` no longer defaults to `newsletter/*` and `newsletters/*`. Like developer docs, newsletters live in folders with any name (`emails/`, `issues/`, `content/newsletter/`), so a guessed default only helped repos that happened to use it. A newsletter is chosen from the request, from `scribb-content-type: newsletter` frontmatter, or from `paths_newsletter`, which `/scribb:setup` proposes after reading the repo.
- Trade-off, as for developer docs: until setup runs or a file has the frontmatter, a newsletter written as Markdown gets the product-docs rules from the after-edit check.

## New content type: website and sales pages (2026-10-10)
- `website` (`medium: marketing`, label "Website and sales pages"): landing, feature, pricing and about pages, case studies, sales one-pagers and sales decks. Default freedom expressive, as 005 planned for marketing. No default folder, like newsletters and developer docs: chosen from the request, `scribb-content-type: website` frontmatter, or `paths_website` mapped by `/scribb:setup`.
- The first of the founder-facing content types. Built first so scribb's own README intro (landing-page copy) can be written with it, which also tests it on a real page. `evals/quality/landing-page/` measures it with and without scribb.


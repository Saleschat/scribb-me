# 021 — Easier ways to make your own content types and formats

Status: open

## Context
scribb can already load a team's or a user's own content types, formats and styles with no code changes (see `docs/pack-format.md`): a content type is a folder in `.scribb/packs/content-types/<id>/`, a format is a file in `.scribb/formats/<content type>/<id>.md`. But making one means copying a pack and editing YAML frontmatter and several Markdown files by hand. That's too much for the median user, so the README no longer explains it (2026-10-08); it covers only creating a style with `/scribb:learn`.

## Ideas to explore
- A guided command, in the spirit of `/scribb:learn`: "describe the kind of writing" or "give me three examples", then scribb drafts the content type or format, shows it, and saves it after approval.
- Turning a recurring brief into a format automatically ("you've asked for this structure three times; save it as a format?"), as 013 suggested.
- Learning a content type from a folder of existing pages (the team's best release notes, their help center).
- The webapp (019) as the place to edit packs without files.

## Until then
Contributors and power users can follow `docs/pack-format.md` and `CONTRIBUTING.md`.

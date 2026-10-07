# 013 — Brief and formats (formatting inputs)

Status: decided, needs implementation

## Decision
- **The brief is inferred from plain language.** Users never write YAML. Fields:
  - `content_type`, `format`, `audience`, `length`, `freedom`, `style`, `locale`, `output` (file path or chat), output format (markdown / plain / HTML / i18n JSON / JSX strings; inferred from the target file).
- **`/scribb:write` shows the inferred brief as one line** before drafting, for example, `Docs · how-to · admins · ≤400w · strict`, so the user can correct it.
- **Formats** are reusable structure templates (required sections, length limits, an example) shipped in content-type packs:
  - Docs: how-to, concept, reference, troubleshooting, release note (Diátaxis-style split).
  - UI copy: error message, empty state, confirmation dialog, toast, onboarding step, tooltip (lines up with the UI roles in 008).
  - Users and teams add their own in `~/.config/scribb/formats/` or `.scribb/formats/` (for example, "weekly changelog", "customer incident notice"). A brief that keeps recurring becomes a format.
- **Precedence for one piece:** prompt > format > content-type defaults > style. Saying "make this one casual" beats a formal style for that piece only.

## Open questions
- Can a format be checked mechanically (required headings present), or only by the reviewer?
- Diátaxis is CC BY-SA 4.0. Write our templates in our own words, citing it as inspiration.

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- Format files are markdown with frontmatter: `id`, `content_type`, `summary`, `sections: [{name, required, length}]`, then an example. Docs and UI formats are in each content type's `formats/`, written in our own words with Diátaxis cited as inspiration.
- Formats are checked by the reviewer only in v0.1.

# 014 — Learning a style from sources

Status: decided, needs implementation

## Ingestion (no scraping)
| Source | How |
|---|---|
| Uploads (md, txt, pdf, docx) | Read directly |
| Website | Pages the user names, or the site's sitemap or RSS, capped at about 20 pages |
| Substack | The publication's RSS feed (`<name>.substack.com/feed`). Free posts only; paid posts are skipped |
| Social media | The user's own data export (X archive, LinkedIn export) or pasted text. No scraping |

## Pipeline (`/scribb:learn` → `scribb-learner` agent)
1. **Sample check:** aim for 5–20 pieces and roughly 3,000+ words. Below that, warn and mark the style `confidence: low`. Drop quotes, reposts and co-written pieces; prefer recent ones.
2. **Extract style, not content:** rhythm, density, person, how it opens and closes, its habits, favourite and avoided words. It must not carry over topics or phrases.
3. **Draft a style pack:** tagline, traits, `style.md`, the shared sample paragraph rewritten in this style. Optionally proposes checker rules.
4. **Validate with held-out samples:** 1–2 pieces are held back; the reviewer compares a generated paragraph against them; scores are shown when approving.
5. **Human approval**, recording the approver (same as memories).

## Storage
- `sources.json`: metadata only (URL, fetched date, content hash).
- Raw text is cached in the user scope and never committed, so re-learning works without refetching.
- `examples/`: short excerpts only, about 50 words each and at most 10.

## Real people
- **Private styles** (user, project or local scope) can be learned from anyone and named anything.
- **Built-in and shared styles** are named by traits ("Direct developer docs"), learned only from openly licensed material or writers who gave permission. Their examples are original rewrites, not excerpts.

## Open questions
- Re-learning: full rebuild or a diff against the current pack? (Diff + approval fits 003.)
- PDF/docx extraction relies on the tool's own file reading; check this in Codex.

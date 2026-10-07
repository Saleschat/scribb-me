# Pack format

A pack is a folder that holds one base, content type or style. Built-in packs live in `plugin/packs/<id>/`. Users and teams add their own in the user scope (`~/.config/scribb/packs/<id>/`) or the project scope (`.scribb/packs/<id>/`). Packs contain markdown, YAML and plain text only. scribb refuses to install a pack that contains executable files.

```
packs/<id>/
  pack.yaml          # metadata (required)
  summary.md         # 5–12 short bullets, injected at session start (required)
  guide.md           # full guidance for writers and the reviewer (required)
  sample.md          # the shared reference text, rewritten in this pack (content types and styles)
  formats/<id>.md    # structure templates (content types only)
  roles/<system>.yaml  # component → UI role maps (ux-microcopy only)
  checks/vale/<ValeStyle>/*.yml   # checker rules for Vale (optional)
  checks/vale/config/views/*.yml  # Vale views, for example, to reach strings in JSX (optional)
  checks/vale/tests/<Rule>.bad.<ext>, <Rule>.good.<ext>  # one pair per rule
```

## `pack.yaml`
```yaml
id: tech-docs                 # matches the folder name
kind: content-type            # base | content-type | style
version: 0.1.0                # semver, per pack
tagline: Clear, task-first developer documentation.
license: MIT                  # SPDX id; required for built-in packs
traits:                       # see docs/open-items/002
  medium: docs                # content types: the medium they cover
  # styles: formality, density, person, source_type, good_for: [docs, ui]
freedom: strict               # content types only: the default freedom
paths: ["*.md", "*.mdx"]      # content types only: default file patterns
extends: null                 # styles: another style id@version, or null
sources:                      # what the pack drew on; text is always our own words
  - name: Google developer documentation style guide
    url: https://developers.google.com/style
    license: CC-BY-4.0
    use: inspiration
tags: []
```

The bash hooks read only flat `key: value` lines and simple `[a, b]` lists from `pack.yaml`, so keep `id`, `kind`, `version`, `tagline`, `license`, `freedom` and `paths` on one line each.

## Severity
Checker rules set Vale's `level`, which maps to scribb's severity:

| Vale `level` | Severity | Used for |
|---|---|---|
| `error` | hard | base anti-AI phrases; never relaxed |
| `warning` | convention | content-type conventions |
| `suggestion` | preference | style preferences |

Freedom then decides what each severity does (block, warn or suggest); see `docs/open-items/005-creativity.md`.

## Rule naming
- Each pack has one Vale style folder, named in PascalCase: `ScribbBase`, `ScribbDocs`, `ScribbUI`, or the style id in PascalCase (`DirectDeveloperDocs`).
- Rule IDs are `<ValeStyle>.<Rule>`, for example, `ScribbBase.ChatResidue`.
- Every rule has a test pair in `checks/vale/tests/`: `<Rule>.bad.md` must trigger it, `<Rule>.good.md` must not. Use `.jsx` or `.tsx` for UI-copy rules that target code. `evals/rules/run.sh` runs them.
- Prefer high-precision rules. A rule that fires on ordinary human writing does more harm than a missed tell. The reviewer catches the fuzzy patterns.

## Memories
A memory is one markdown file with frontmatter (see `docs/open-items/003-feedback-loop-learning-agent.md`), stored in `memories/` in the local (`.scribb/local/memories/`), project (`.scribb/memories/`) or user (`~/.config/scribb/memories/`) scope.

## Vocabulary
A `vocab.txt` in the user, project (`.scribb/vocab.txt`) or local scope lists terms that keep their own casing and spelling, one per line (`#` starts a comment). `scribb-check` passes them to Vale as an accepted vocabulary, which adds them to the exceptions of every rule. Use it for product names, so `HeadingCase` accepts "Connect scribb.me to Slack".

## Config
Each scope can have a `config.yaml` with flat `key: value` lines. Precedence: session > local (`.scribb/local/config.yaml`) > project (`.scribb/config.yaml`) > user (`~/.config/scribb/config.yaml`) > built-in defaults.

| Key | Values | Default |
|---|---|---|
| `enabled` | `true` · `false` | `true` |
| `style` | a style id, or `none` | `none` |
| `freedom` | `strict` · `balanced` · `expressive` | the content type's default |
| `checker` | `vale` · `none` | `vale` |
| `reviewer` | `off` · `auto` · `always` | `auto` |
| `capture` | `on` · `off` (memory capture from corrections) | `on` |
| `inject` | `on` · `off` (session-start style summary) | `on` |
| `nudges` | `on` · `off` | `on` |
| `paths_docs` | comma-separated globs | `*.md, *.mdx` |
| `paths_ui` | comma-separated globs | `*.tsx, *.jsx` |
| `paths_ignore` | comma-separated globs | see `plugin/lib/scribb.sh` |

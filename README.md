# scribb.me

scribb.me is a writing-style plugin for coding agents. It makes the docs, UI copy and newsletters your agent writes read like a careful human wrote them: no AI writing habits, your team's conventions, and optionally a style you pick or teach it.

v0.1 supports Claude Code. Codex and other tools are planned (see [docs/open-items](docs/open-items/)).

## Install (Claude Code)

```
/plugin marketplace add Saleschat/scribb-me
/plugin install scribb@scribb-me
```

Then just write. There's no setup step.

For the automatic checks after each edit, also install [Vale](https://vale.sh/docs/install) (`brew install vale` on macOS). Without Vale, everything else still works.

## What it does

- **At session start**, it gives Claude a short summary of the rules, the active style and your approved preferences.
- **After Claude edits a file of a known content type** (below), the checker (Vale with scribb's rules) runs in the background. If it finds a blocking issue, Claude gets the findings and revises, at most twice per file.
- **After a big prose edit** (about 150+ words of docs, or 5+ UI strings), Claude asks a reviewer agent with fresh context to check the passage.
- **When you correct Claude's wording** ("don't say account, we call it a workspace"), scribb offers to remember it for you or your team.

What gets checked depends on the **content type**, which scribb works out from the file:

| Content type | For | Files | Default freedom |
|---|---|---|---|
| Docs | Developers and technical writers | `*.md`, `*.mdx` | strict |
| UI copy | Product designers and engineers | `*.tsx`, `*.jsx` | strict |
| Newsletter | Founders and creators: issues, product updates, welcome emails | `newsletter/*`, `newsletters/*`, or a newsletter you ask for in chat | balanced |

**Freedom** (`strict`, `balanced` or `expressive`) sets how far a piece may stray from conventions and style preferences. The base anti-AI rules always apply.

## Commands

| Command | Does |
|---|---|
| `/scribb:style` | Shows the active setup. Lists and switches styles, sets freedom, turns scribb off or on |
| `/scribb:write` | Writes a piece with the full loop: brief, draft, check, review, revise |
| `/scribb:review` | Reviews a file, folder, diff or pasted text and reports findings |
| `/scribb:remember` | Saves a wording preference for you or your team |
| `/scribb:learn` | Learns a style from sources, or reviews captured corrections |
| `/scribb:setup` | Optional team setup: shared defaults in `.scribb/`, a checker config for CI |
| `/scribb:report` | Drafts a GitHub issue, for example a checker false positive |

## Styles

With no style set, scribb uses a neutral house style. Two starter styles ship with the plugin:

| Style | Tagline |
|---|---|
| `direct-developer-docs` | Short sentences, the imperative, and nothing the reader has to skip. |
| `crisp-product-ui` | Plain, compact interface copy that never makes people read twice. |

Pick one with `/scribb:style list`, or teach scribb your own with `/scribb:learn`.

## Turning it off

scribb is on by default. You can turn it off at any level:

| Level | How |
|---|---|
| One piece | Say "skip review" or "no checks" in your prompt |
| This session | `/scribb:style off` |
| This repo, just you | `/scribb:style off --repo` |
| This repo, whole team | `/scribb:style off --team`, then commit `.scribb/config.yaml` |
| Everywhere, for you | `/scribb:style off --everywhere` |
| Kill switch | `SCRIBB_DISABLE=1` in the environment |

You can also switch off parts of it with `/scribb:style`: the reviewer (`reviewer: off`), nudges (`nudges: off`), correction capture (`capture: off`) or the session-start summary (`inject: off`).

## Where things live

| Scope | Path | Committed |
|---|---|---|
| Built-in | the plugin's `packs/` | — |
| User | `~/.config/scribb/` | no |
| Project | `.scribb/` (settings, memories, `vocab.txt`) | yes |
| Local | `.scribb/local/` | no (it ignores itself) |

Product names that keep their own casing go in `vocab.txt`, one per line, so the checker accepts them. Captured corrections stay in `.scribb/local/inbox/` on your machine. scribb sends no telemetry.

## Development

```
evals/rules/run.sh     # every checker rule fires on bad text and stays quiet on good text
tests/hooks/run.sh     # hook and helper tests
claude --plugin-dir plugin   # try the plugin locally
```

The design and its open questions are in [docs/open-items](docs/open-items/); the pack format is in [docs/pack-format.md](docs/pack-format.md).

## Licence

MIT. Built-in packs are our own writing; [plugin/NOTICE.md](plugin/NOTICE.md) credits the style guides and rule sets they drew on.

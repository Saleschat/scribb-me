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
- **After a big prose edit** (about 150+ words of docs or newsletter prose, or 5+ UI strings), Claude asks a reviewer agent with fresh context to check the passage.
- **When you correct Claude's wording** ("don't say account, we call it a workspace"), scribb offers to remember it for you or your team.


## How scribb thinks about writing

Every piece of writing gets the same few layers. Two of them are easy to mix up, so they're kept apart on purpose.

| Layer | Answers | Holds | Per piece |
|---|---|---|---|
| **Base** | What does machine-written text look like? | Rules against AI writing habits | Always on |
| **Content type** | What kind of writing is this? | The conventions every good writer of that kind follows | Exactly one |
| **Format** | What is this particular piece? | A task template inside a content type: sections, length, an example | Zero or one |
| **Style** | Whose voice is it in? | Taste that good writers disagree on: tone, rhythm, word choice | Zero or one |

**Content type or style?** Ask whether two excellent writers would disagree about a rule. If both would follow it ("a how-to has numbered steps", "an error message says what to do next"), it belongs to the content type. If it's a matter of taste ("short punchy sentences", "use contractions"), it belongs to a style.

Content types and styles are **independent**. Neither is built from the other. Any content type works with no style, and one style can apply to several content types (its `good_for` lists them). A style can build on another style with `extends:`.

**When layers disagree**, the higher one wins:

```
  what you say now           "make this one casual" wins, for this piece only
  memories                   preferences you or your team approved
  format                     for example a how-to or a release note
  content type
  style                      fills in the voice; loses on conflict
  base                       hard rules: never relaxed, whatever the order
```

**Example.** Two founders write a product-update newsletter. The content type is the same: one clear subject line, one main point, a link and a short sign-off. The style differs: one writes warm first-person stories, the other terse numbers-first bullets. Both are good newsletters.

### Content types

| Content type | For | Picked when |
|---|---|---|
| Product docs | People using or evaluating the product: getting started, how-tos, help articles, READMEs and other repo files, release notes | Any Markdown file (`*.md`, `*.mdx`) |
| Developer docs | People writing code against the product: API, SDK and CLI reference, integration guides | The page is about that, or its frontmatter says `scribb-content-type: developer-docs`, or `/scribb:setup` mapped those folders |
| UI copy | Product designers and engineers writing interface strings | `*.tsx`, `*.jsx` |
| Newsletter | Founders and creators: issues, product updates, welcome emails | `newsletter/*`, `newsletters/*`, or a newsletter you ask for in chat |

Developer docs have no default folder, because every docs repo is laid out differently (a GitBook repo looks nothing like a Docusaurus one). `/scribb:setup` reads your real layout, including GitBook's `SUMMARY.md`, and asks which sections are developer docs.

**Freedom** (`strict`, `balanced` or `expressive`) sets how far a piece may stray from conventions and style preferences. Each content type has a default: strict for docs and UI copy, balanced for newsletters.

The built-in packs in `plugin/packs/` double as worked examples of each layer. To build your own, see [docs/pack-format.md](docs/pack-format.md).

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
| `/scribb:contribute` | Turns a preference your team keeps fixing into a pull request for the built-in packs |

## Styles

With no style set, scribb uses a neutral house style. Two starter styles ship with the plugin, mainly as examples of what a style is:

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
| Built-in | the plugin's `packs/` (`base/`, `content-types/`, `styles/`) | — |
| User | `~/.config/scribb/` | no |
| Project | `.scribb/` (settings, memories, `vocab.txt`) | yes |
| Local | `.scribb/local/` | no (it ignores itself) |

Product names that keep their own casing go in `vocab.txt`, one per line, so the checker accepts them. Captured corrections stay in `.scribb/local/inbox/` on your machine. scribb sends no telemetry.

## Development

```
evals/rules/run.sh     # every checker rule fires on bad text and stays quiet on good text
tests/hooks/run.sh     # hook and helper tests
evals/quality/run.sh   # with/without-scribb quality evals; uses your Claude credentials and costs money
claude --plugin-dir plugin   # try the plugin locally
```

To improve the built-in packs, see [CONTRIBUTING.md](CONTRIBUTING.md). The design and its open questions are in [docs/open-items](docs/open-items/); the pack format is in [docs/pack-format.md](docs/pack-format.md).

## Licence

MIT. Built-in packs are our own writing; [plugin/NOTICE.md](plugin/NOTICE.md) credits the style guides and rule sets they drew on.

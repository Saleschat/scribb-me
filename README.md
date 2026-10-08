# scribb.me

scribb.me is a writing-style plugin for Claude. It makes the docs, UI copy and newsletters Claude writes read like a careful human wrote them: no AI writing habits, your team's conventions, and optionally a style you pick or teach it.

It's one plugin that works in Claude Code, Cowork and claude.ai chat. Codex and other tools are planned (see [docs/open-items](docs/open-items/)).

## Install

scribb works in Claude Code, Cowork and claude.ai chat. Not sure which to use? See [Choose where to use it](#choose-where-to-use-it) at the end.

### Claude Code

```
/plugin marketplace add Saleschat/scribb-me
/plugin install scribb@scribb-me
```

`/plugin install` asks where to install it:
- **Just you, in this repository** (local scope): good for trying it.
- **Everyone in this repository** (project scope): writes `.claude/settings.json`, which you commit. Each teammate also runs `/plugin install scribb@scribb-me` once.
- **You, in every repository** (user scope).

Then run `/reload-plugins` (or start a new session) and just write. There's no setup step; run `/scribb:setup` when you want team defaults.

The checks after each edit work out of the box with scribb's built-in checker, which needs `python3`. [Vale](https://vale.sh/docs/install) (`brew install vale` on macOS) gives the same findings and adds editor and CI integration (`/scribb:setup --ci`); scribb uses it when it's installed.

### Cowork

1. In the Claude desktop app, open **Customize > Plugins > Add > Add marketplace**, enter `Saleschat/scribb-me`, and add **scribb**.
2. Start a new Cowork task. Plugins load when a task starts.
3. Use it as in Claude Code: `/scribb:write`, `/scribb:review`, or just ask for docs, UI copy or a newsletter.

Tested in Cowork in the desktop app: Cowork runs on your computer, so it uses your installed Vale (or scribb's built-in checker if you don't have Vale) and the same personal settings and memories as Claude Code, which carry over between tasks. The checks after each edit, the reviewer agent, nudges and scribb's questions all work as in Claude Code. If something looks off, run `/scribb:style doctor` and [report](https://github.com/Saleschat/scribb-me/issues/new?template=bug.yml) what it shows.

### claude.ai chat

1. In claude.ai (or the desktop app's chat), open **Customize > Plugins > Add > Add marketplace**, enter `Saleschat/scribb-me`, and add **scribb**.
2. In a chat, **type `/scribb`** in the message box to list every scribb skill (write, review, learn, remember, style…), or just ask for docs, UI copy or a newsletter and scribb's guidance applies on its own.
3. For the built-in checker, turn on code execution in your claude.ai settings if it's off. Without it, scribb still writes from its guides and reviews its own draft.

Chat runs skills only, so these stay in Claude Code and Cowork: checks after every edit, the reviewer agent, automatic correction capture, memory files, `/scribb:setup` and `/scribb:contribute`. When you correct scribb's wording in chat, it offers to save the correction; `/scribb:remember` then gives you a `scribb memory:` line for your Project instructions or personal preferences.

### Updates

- **Claude Code:** `/plugin marketplace update scribb-me`, then `/reload-plugins`.
- **Cowork and chat:** scribb updates from the repository on its own. To get the latest right away, select **Check for updates** in **Customize > Plugins**, or turn on **Sync automatically** for the marketplace.

## What it does

- **At session start**, it gives Claude a short summary of the rules, the active style and your approved preferences.
- **After Claude edits a file of a known content type** (below), the checker (Vale, or scribb's built-in checker when Vale isn't installed) runs in the background. That includes files Claude writes with a shell command instead of its editing tools. If it finds a blocking issue, Claude gets the findings and revises, at most twice per file.
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
| Newsletter | Founders and creators: issues, product updates, welcome emails | The request says it's a newsletter, or its frontmatter says `scribb-content-type: newsletter`, or `/scribb:setup` mapped those folders |

Developer docs and newsletters have no default folder, because every repo is laid out differently (a GitBook repo looks nothing like a Docusaurus one, and newsletters live in `emails/`, `issues/` or anywhere else). `/scribb:setup` reads your real layout, including GitBook's `SUMMARY.md`, and asks which folders hold developer docs or newsletters. Until then, a Markdown file counts as product docs unless its frontmatter says otherwise.

**Freedom** (`strict`, `balanced` or `expressive`) sets how far a piece may stray from conventions and style preferences. Each content type has a default: strict for docs and UI copy, balanced for newsletters.

The built-in packs in `plugin/packs/` double as worked examples of each layer. To build your own, see [docs/pack-format.md](docs/pack-format.md).

## Commands

Type `/scribb` to list them all, in any of the three apps. In chat, `/scribb:setup` and `/scribb:contribute` explain that they need Claude Code or Cowork.

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

## Make your own content type, format or style

The built-in packs are a starting point. Add your own for your team (committed in the repo) or just for you (in every repo), with no code changes. Every built-in pack is marked as an example of its layer, so copy the closest one.

**First, decide which one you need.** Ask whether two excellent writers would disagree about your rules (see [How scribb thinks about writing](#how-scribb-thinks-about-writing)):
- Both would follow them, and they cover a whole kind of writing: a **content type** (for example "website content").
- They describe one kind of piece inside a content type: a **format** (for example "changelog digest" for newsletters).
- They're a matter of taste or voice: a **style** (for example "our brand voice").

| To make | Copy | Into (team, committed) | Or (just you, every repo) |
|---|---|---|---|
| Content type | `plugin/packs/content-types/product-docs/` | `.scribb/packs/content-types/<id>/` | `~/.config/scribb/packs/content-types/<id>/` |
| Format | any file in a content type's `formats/` | `.scribb/formats/<content type>/<id>.md` | `~/.config/scribb/formats/<content type>/<id>.md` |
| Style | `plugin/packs/styles/direct-developer-docs/` | `.scribb/packs/styles/<id>/` | `~/.config/scribb/packs/styles/<id>/` |

### A style
The quickest way is `/scribb:learn`: give it 5–20 samples of the writing you want, and it drafts the style, shows you a sample paragraph next to the neutral one, and saves it once you approve. To write one by hand, edit the copy's:
- `pack.yaml`: `id` (the folder name), `kind: style`, a one-line `tagline`, and `good_for` (the content types it suits).
- `summary.md` (5–10 bullets), `guide.md` (the voice in your own words, with examples) and `sample.md` (the shared sample text rewritten in this style).
- Optional checker rules in `checks/vale/<StyleName>/`, at `level: suggestion`.

Turn it on with `/scribb:style use <id>`.

### A format
A format is one Markdown file: frontmatter with `id`, `content_type`, a one-line `summary` and the `sections` (each with `name`, `required` and `length`), then a short example. `/scribb:write` picks it up from the request ("write a changelog digest"), or name it with `--format <id>`. A format with the same id as a built-in one replaces it.

### A content type
Edit the copy's `pack.yaml`:
- `id` (the folder name), `kind: content-type`, `label` (the name people see) and a `tagline` that says who it's for.
- `freedom`: `strict`, `balanced` or `expressive`.
- `paths`: the files it covers (`["site/*"]`), or `[]` if it's chosen per piece, from the request or a `scribb-content-type: <id>` frontmatter line.
- `match_order`: lower wins when patterns overlap. Keep it under 90 so it beats Product docs' `*.md`.

Then write its `guide.md`, `summary.md`, `sample.md` and at least one format in `formats/`. Checker rules go in `checks/vale/<StyleName>/` at `level: warning`, each with a bad and a good example in `checks/vale/tests/`. Run `/scribb:style` to check that scribb lists it.

Your own packs work in Claude Code and Cowork. claude.ai chat uses the built-in packs only, so for chat, turn a style into a skill with `/scribb:learn`.

Think a pack would help everyone? See [CONTRIBUTING.md](CONTRIBUTING.md) to add it to the built-in packs. The full pack format is in [docs/pack-format.md](docs/pack-format.md).

## Where things live

| Scope | Path | Committed |
|---|---|---|
| Built-in | the plugin's `packs/` (`base/`, `content-types/`, `styles/`) | — |
| User | `~/.config/scribb/` (settings, memories, your own `packs/` and `formats/`) | no |
| Project | `.scribb/` (settings, memories, `vocab.txt`, the team's `packs/` and `formats/`) | yes |
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

## Choose where to use it

The same plugin works in three Claude apps. Each one loads a different part of it, so pick by where you write.

| | **Claude Code** | **Cowork** | **claude.ai chat** |
|---|---|---|---|
| Best for | Docs and UI copy that live in a code repository | Writing tasks on your computer, outside a repository | Drafting and reviewing in a conversation |
| Install from | `/plugin` in Claude Code | Your claude.ai account (Customize > Plugins) | Your claude.ai account (Customize > Plugins) |
| Write and review (`/scribb:write`, `/scribb:review`) | ✓ | ✓ | ✓ |
| Rules applied whenever you ask for docs, UI copy or a newsletter | ✓ | ✓ | ✓ |
| Checker, after every file edit | ✓ (Vale, or the built-in checker) | ✓ (your Vale, or the built-in checker) | Built-in checker on drafts, when code execution is on |
| Fresh-context reviewer agent | ✓ | ✓ | Self-review pass in the same chat |
| Corrections captured automatically | ✓ | ✓ | Offered when you correct a word |
| Memories (saved preferences) | Files for you or your team | Same files as Claude Code; carry over between tasks | A line for your Project instructions |
| Learn a style from samples | ✓ saved as a style pack | ✓ saved as a style pack | ✓ handed back as a skill to upload |
| Team setup, contributing fixes upstream | ✓ | ✓ | ✗ |

**Which to choose**
- **You write docs or UI copy in a repository:** use **Claude Code**. It's the full version: checks after every edit, team settings and memories committed with the repo, and the reviewer agent.
- **You work on files outside a repository** (a folder of drafts, a newsletter, a handbook): use **Cowork**. It runs the same hooks and agents as Claude Code.
- **You draft or review in a conversation,** or don't use Claude Code: use **claude.ai chat**. You get the guides, the built-in checker and a review pass, but nothing runs automatically between messages.

You can use more than one. Plugins you add on claude.ai appear in Cowork and also sync into Claude Code. If you've installed scribb in Claude Code from the marketplace too, Claude Code uses that copy and skips the synced one, so it never loads twice.

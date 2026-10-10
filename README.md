# scribb.me

**To be, or not to be… you.**

Hand Aristotle, Shakespeare, Tolstoy and Orwell the same AI, and by Friday they'd all post the same LinkedIn update. Two thousand years of different voices, gone in a week. Their voices are what made them. Yours is what makes you.

## Sound like yourself, even when AI writes for you

scribb.me is a free, open-source plugin for Claude that keeps your writing in your own voice. It works in Claude Code, Cowork and claude.ai chat.

Your customers get to know you through what you write. The landing page a founder wrote at midnight, the newsletter a marketer sent on Monday, the release note a product manager shipped this morning, the proposal a consultant tailored for one client: each carries a voice your customers learn to recognize and trust. That voice is your identity, and it's worth keeping when Claude writes the first draft.

Here's what scribb does for each of you:

- **Founders:** launch notes and newsletters that read like you wrote them yourself.
- **Marketers:** website pages that make one clear point and say it your way.
- **Content writers and creators:** newsletters in a voice your readers recognize from the first line.
- **Product managers:** onboarding guides, help pages, release notes and in-app copy that answer the question and stop.
- **Consultants and sellers:** proposals and pitch decks built around the client's own words.
- **Engineers:** API references and developer guides that stay inside their scope.
- **Journalists:** your own style, learned from your published work, on every draft.

Every piece comes out clear and to the point. scribb removes the habits readers have learned to spot (inflated words, reflexive lists, tidy one-line morals, a dash in every other sentence) and keeps each piece to what its reader needs. Run `/scribb:learn` on your best writing and scribb picks up your style, so a first draft needs editing, not rewriting. Save your terms and your team's rules as memories, and every piece after that follows them, for one person or a whole team.

### What scribb covers today

- **Website pages:** landing, feature or service, pricing and about pages, case studies
- **Sales materials:** proposals, pitch decks, one-pagers and follow-ups
- **Newsletters:** regular issues, announcements, welcome emails
- **Product docs:** onboarding guides, how-tos, help articles, release notes
- **Developer docs:** API, SDK and CLI reference, integration guides
- **UI copy:** the words in your app or dashboard
- **Your own style,** learned from your writing with `/scribb:learn`

### Coming next

LinkedIn and other social posts, emails, and client documents such as implementation plans. [Tell us what you need](https://github.com/Saleschat/scribb-me/issues/new?template=new-content-type.yml).

### Get started

```
/plugin install scribb --marketplace Saleschat/scribb-me
```

That's for Claude Code. For Cowork and claude.ai chat, see [Install](#install).

## Install

Not sure which app to use? See [Choose where to use it](#choose-where-to-use-it) below.

### Claude Code

In a Claude Code session, run:

```
/plugin install scribb --marketplace Saleschat/scribb-me
```

This adds scribb's marketplace (this GitHub repository) and installs the plugin in one step; Claude Code asks you to confirm the source first. It needs Claude Code 2.1.275 or later (`claude --version`). On an older version, run the two steps yourself:

```
/plugin marketplace add Saleschat/scribb-me
/plugin install scribb@scribb-me
```

Either way, Claude Code then asks where to install it:
- **Just you, in this repository** (local scope): good for trying it.
- **Everyone in this repository** (project scope): writes `.claude/settings.json`, which you commit. Each teammate also runs the install command once.
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

- **Claude Code:** `/plugin marketplace update scribb-me` pulls the latest from this repository's `main` branch; then run `/reload-plugins`.
- **Cowork and chat:** scribb updates from the repository on its own. To get the latest right away, select **Check for updates** in **Customize > Plugins**, or turn on **Sync automatically** for the marketplace.

## What it does

- **At session start**, it gives Claude a short summary of the rules, the active style and your approved preferences.
- **After Claude edits a file of a known content type** (below), the checker (Vale, or scribb's built-in checker when Vale isn't installed) runs in the background. That includes files Claude writes with a shell command instead of its editing tools. If it finds a blocking issue, Claude gets the findings and revises, at most twice per file.
- **After a big prose edit** (about 150+ words of docs or newsletter prose, or 5+ UI strings), Claude asks a reviewer agent with fresh context to check the passage.
- **When you correct Claude's wording** ("don't say account, we call it a workspace"), scribb offers to remember it for you or your team.

Everything stays on your machine or in your repo. scribb sends no telemetry.


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
| Website pages | Founders and teams writing public pages that win a stranger over in seconds: landing, feature, pricing and about pages, case studies | The request says it's a website page, or its frontmatter says `scribb-content-type: website`, or `/scribb:setup` mapped those folders |
| Sales materials | Founders, consultants and services teams writing for a known prospect: sales decks, one-pagers, proposals, follow-ups | The request says it's a deck, one-pager, proposal or follow-up, or its frontmatter says `scribb-content-type: sales`, or `/scribb:setup` mapped those folders |

Developer docs and newsletters have no default folder, because every repo is laid out differently (a GitBook repo looks nothing like a Docusaurus one, and newsletters live in `emails/`, `issues/` or anywhere else). `/scribb:setup` reads your real layout, including GitBook's `SUMMARY.md`, and asks which folders hold developer docs or newsletters. Until then, a Markdown file counts as product docs unless its frontmatter says otherwise.

**Freedom** (`strict`, `balanced` or `expressive`) sets how far a piece may stray from conventions and style preferences. Each content type has a default: strict for docs and UI copy, balanced for newsletters and sales materials, expressive for website pages.

To make your own voice, see [Create your own style](#create-your-own-style). (For contributors, the full pack format is in [docs/pack-format.md](docs/pack-format.md).)

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

Pick one with `/scribb:style list`, or [create your own](#create-your-own-style).

## Create your own style

Teach scribb a voice from writing you like: your own posts, your company's best docs, a newsletter you admire.

1. Run `/scribb:learn` and give it 5–20 samples: files, links or pasted text.
2. It shows you the style it found, with a sample paragraph written that way. Say yes to keep it, and choose **just me** (every repo) or **my team** (this repo).
3. Use it: `/scribb:style use <name>`. Or just ask for it in a request ("write this in my-style").

In claude.ai chat, `/scribb:learn` gives you the style as a file to upload in **Customize > Skills**.

Brand or product names with their own casing (like scribb.me): add them to `.scribb/vocab.txt`, one per line, so the checker leaves them alone.

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

## Open source

scribb.me is MIT-licensed. Its built-in packs are our own writing, and [plugin/NOTICE.md](plugin/NOTICE.md) credits the style guides they drew on. [DEVELOPMENT.md](DEVELOPMENT.md) explains how it's built and tested, and [CONTRIBUTING.md](CONTRIBUTING.md) explains how to improve the packs.

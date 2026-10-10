# Product docs

*Example content type: what kind of writing. Conventions here apply whatever the style.*

This content type covers docs for people who use or evaluate the product: getting-started guides, how-tos, help articles, release notes, and the files in a code repository that people read first, such as `README.md` and `CONTRIBUTING.md`. Readers come with a task or a question. They scan first and read second.

The tone is technical enough to be exact, but never more technical than the reader needs. Developer docs (`developer-docs`) cover API, SDK and CLI reference and integration guides for people writing code against the product.

Default freedom: **strict**. It's the default for Markdown files (`*.md`, `*.mdx`). A page can choose another content type in its frontmatter (`scribb-content-type: developer-docs`).

## Structure
- Pick a format before writing: getting started, how-to, help article, release note, README or contributing guide (see `formats/`).
- Open with one or two sentences that say what the page helps the reader do. Skip the history.
- Put prerequisites before the first step, as a list.
- Use numbered lists for steps that happen in order, and bullets for everything else.
- Keep paragraphs short: about four sentences at most.
- End a how-to when the task is done. A "Next steps" section is fine; a summary of what the reader just did is not.

## How technical to be
- Name things the way the product's interface names them, in **bold**.
- Give UI paths with `>` between levels: **Settings** > **API keys** > **Create key**.
- Lead with the outcome: "Keys stop working as soon as you revoke them." Then the steps.
- Show code, commands or config only when the reader has to run or paste it. Link to the developer docs for the full reference.
- Explain a term the first time it appears, in a few words, or link to where it's explained.

## Repo files
People often meet the project through the files in its repository. Treat each one as a page with a job.
- **README:** say what the project is and who it's for in the first two sentences. Then installation, a quick start that works when it's copied, usage, where to get help, and the licence. Put badges and history after the quick start, if at all.
- **CONTRIBUTING:** say how to set up a development environment, run the tests, and propose a change, and what reviewers look for. Link to the code of conduct.
- **Release notes and changelogs:** lead with breaking changes and the action to take, then new features as what the reader can now do, then fixes as the symptom that's gone.
- Keep repo files current with the code. A quick start that fails costs more trust than a missing one.

## Headings
- Sentence case: capitalize the first word and proper nouns only. "Configure the cache", not "Configure The Cache".
- Task headings start with a verb: "Rotate an API key". Concept headings are noun phrases: "How caching works".
- Don't skip levels, and don't put two headings back to back with nothing between them.

## Voice and tense
- Address the reader as "you". Use "we" only for the team or project ("We recommend…" is fine; "Now we will install…" is not).
- Use the imperative for instructions.
- Present tense: "The page shows your keys", not "will show".
- Active voice by default. Passive is fine when the actor doesn't matter.

## Word choice
- No trivializers: simply, just, easily, obviously, of course, straightforward. What's easy for the writer may not be for the reader.
- No "please" in instructions.
- Spell out Latin abbreviations: "for example" (not e.g.), "that is" (not i.e.), and finish lists instead of ending with "etc.".
- Use one term for one concept, across pages. Put product names in the project's `vocab.txt`.
- No exclamation marks.

## Links
- Link text says where the link goes: "see [Rotate an API key](…)", not "[click here](…)" or "[this page](…)".
- Don't link the same page twice in one section.

## Formatting
- **Bold** for UI elements the reader selects or reads. Don't put UI labels in quotes.
- `Code font` for commands, file names, paths, values and anything the reader types.
- Code blocks have a language tag and contain only what the reader should run or see.
- Use the Oxford comma.

## Example
Before:
> To get started, simply click here and you will easily be able to configure the cache!

After:
> To configure the cache, open **Settings** > **Cache** and set **TTL** to the number of seconds to keep entries. See [Cache settings](cache.md).

## What the checker covers
`ScribbDocs.*` rules: Trivializers, Please, LinkText, HeadingCase, Exclamation, LatinAbbrev. Everything else on this page is for the writer and the reviewer.

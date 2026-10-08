# Developer documentation

This content type covers READMEs, guides, how-tos, reference pages, troubleshooting pages and release notes. Readers come to docs with a task. They scan first and read second.

Default freedom: **strict**. Conventions on this page block under strict and balanced freedom and only warn under expressive.

## Structure
- Pick a format before writing: how-to, concept, reference, troubleshooting or release note (see `formats/`). Don't mix a tutorial into a reference page.
- Open with one or two sentences that say what the page covers and who it's for. Skip the history.
- Put prerequisites before the first step, as a list.
- Use numbered lists for steps that happen in order, and bullets for everything else.
- Keep paragraphs short: about four sentences at most.
- End a how-to when the task is done. A "Next steps" section is fine; a summary of what the reader just did is not.

## Headings
- Sentence case: capitalize the first word and proper nouns only. "Configure the cache", not "Configure The Cache".
- Task headings start with a verb: "Rotate an API key". Concept headings are noun phrases: "How caching works".
- Don't skip levels, and don't put two headings back to back with nothing between them.

## Voice and tense
- Address the reader as "you". Use "we" only for the team or project ("We recommend…" is fine; "Now we will install…" is not).
- Use the imperative for instructions.
- Present tense: "The command returns a token", not "will return".
- Active voice by default. Passive is fine when the actor doesn't matter.

## Word choice
- No trivializers: simply, just, easily, obviously, of course, straightforward. What's easy for the writer may not be for the reader.
- No "please" in instructions. Docs give directions; they don't ask favours.
- Spell out Latin abbreviations: "for example" (not e.g.), "that is" (not i.e.), and finish lists instead of ending with "etc.".
- Use one term for one concept, and keep it across pages. Put product names in the project glossary.
- No exclamation marks.
- Avoid unexplained jargon and acronyms. Expand an acronym the first time it appears.

## Links
- Link text says where the link goes: "see [Rotate an API key](…)", not "[click here](…)" or "[this page](…)".
- Don't link the same page twice in one section.

## Formatting
- **Bold** for UI elements the reader clicks or reads: "Select **Save**." Don't put UI labels in quotes.
- `Code font` for commands, file names, paths, parameters, values and anything the reader types.
- Code blocks have a language tag and contain only what the reader should run or see. Show output in a separate block.
- Use the Oxford comma.
- Use tables for comparisons across the same attributes, not for prose.

## Examples
Before:
> In order to get started, simply click here and you will easily be able to configure the cache!

After:
> To configure the cache, open **Settings** > **Cache** and set **TTL** to the number of seconds to keep entries. See [Cache settings](cache.md).

## What the checker covers
`ScribbDocs.*` rules: Trivializers, Please, LinkText, HeadingCase, Exclamation, LatinAbbrev. Everything else on this page is for the writer and the reviewer.

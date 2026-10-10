# Direct developer docs

*Example style: who it sounds like. Taste layered on top of a content type; the content type wins on a conflict.*

A style for developer documentation where the reader wants to get something done and leave. It sounds like a senior engineer writing for a peer: neutral, exact and brief. It assumes the reader is competent and busy.

Good for: Docs.

## Voice
- Neutral, not chatty and not formal. No jokes, no warm-up.
- Second person and the imperative: "Set `timeout` to 30."
- Confident. State defaults and limits as facts. Hedge only when behaviour really varies, and then say what it depends on.

## Sentences
- Short. Aim for 10–20 words, and vary within that range.
- One idea per sentence. If a sentence has "and" joining two instructions, split it into two steps.
- Put conditions first: "If the build fails, run `make clean`."

## Words
- Shortest common word wins: use, to, can, start, end, help, about.
- Cut filler phrases: "Note that", "It's important to note", "Keep in mind", "Basically", "In fact".
- Name things exactly. Write `config.yaml`, not "the config file", once the reader knows which one.

## Structure
- Each section opens with the action or the answer.
- Prefer code blocks, tables and lists to prose that describes them.
- Examples before explanations, where the example is short.

## Before and after
Before:
> To make sure that your application can utilize the cache, it's important to note that you'll need to enable it first.

After:
> Enable the cache before your app can use it: set `cache.enabled` to `true`.

## Checker rules (suggestions)
`DirectDeveloperDocs.WordyPhrases` suggests shorter forms for "utilize", "leverage", "a number of" and "prior to". Generic wordy phrases such as `in order to` and `is able to` are flagged for every piece by the base pack (`ScribbBase.NeedlessWords`).

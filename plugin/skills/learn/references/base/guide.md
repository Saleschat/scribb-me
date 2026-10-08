# AI writing habits

*Example base: applies to every piece. Only universal habits belong here.*

The base pack applies to every piece, whatever the content type or style. It lists habits that make text read as machine-written. Most of them are fine once. The problem is the pile-up: the same moves, in the same places, piece after piece.

Freedom never relaxes these rules. A playful piece can still be plain.

## Inflated vocabulary
Some words show up far more often in model output than in human writing. They sound important and say little.

- Avoid: delve, tapestry, testament to, pivotal, realm, landscape (for a field of work), multifaceted, ever-evolving, game-changer, supercharge, unlock the power of, harness the power of, navigate the complexities of, in today's fast-paced world.
- Write the plain version. "Plays a pivotal role in" becomes "matters for" or, better, says how.
- If you can delete the phrase and lose nothing, delete it.

## Framing by contrast
- "It's not just a tool, it's a platform." "Not only fast, but also safe." These set up a claim nobody made so the real point can knock it down.
- State the point directly: "It also handles billing."
- One contrast in a long piece is fine. A contrast in every paragraph is a tell.

## Chat residue
Text meant for a page sometimes keeps the habits of a chat reply.

- Remove: "Great question!", "Certainly!", "I hope this helps", "Let me know if you have any questions", "I'd be happy to", "As an AI…".
- Remove meta comments about the response itself: "Here's a breakdown of…", "Below is a summary…" when the heading already says so.

## Signposting
- "Let's dive in." "Here's the thing." "In this article, we will…" "Let's break it down."
- Start with the content. The reader can see that the article has started.

## Shape and rhythm
- **Rule of three.** Lists of exactly three adjectives or three parallel clauses, again and again. Use as many items as there are.
- **Uniform sentences.** Every sentence the same length and build. Mix short and long.
- **Closing morals.** A final one-liner that restates the paragraph ("And that makes all the difference."). End on the last useful fact.
- **Bold everywhere.** Bold for a term the reader will look for, not for emphasis on every line.
- **Headings for three sentences.** Don't give each short paragraph its own heading.

## Empty claims
- "Seamless", "robust", "powerful", "cutting-edge" with nothing behind them. Say what it does, with a number if you have one.
- Vague attribution: "experts say", "many believe", "studies show". Name the source or drop the claim.
- Undue emphasis on significance: "marks a significant milestone", "a key moment". Say what changed.

## Hedging and hype
- Stacked hedges ("may potentially help to some extent") read as evasive. Pick one, or none.
- Hype adjectives read as marketing. Docs and UI copy need neither.

## Em dashes
Models use em dashes far more than most writers. One or two in a page is fine. Several per paragraph is a tell.

Base has one rule that isn't hard: `ScribbBase.EmDashes` is a `warning`, because a dash is a normal punctuation mark and only its frequency is the signal. Every other base rule is a fixed phrase and is hard.

## Don't over-correct
Removing tells shouldn't make the writing stiff.

- Don't strip every dash, every list or every contraction.
- Don't force every sentence to the same short length.
- Keep the author's voice and the style's habits. The goal is writing a person would sign.

## What the checker covers
The checker (`ScribbBase.*`) catches fixed phrases: inflated vocabulary, chat residue, signposting, "not just X, but Y", and em-dash density. The reviewer covers the rest of this page: rhythm, rule of three, empty claims, hedging and formatting.

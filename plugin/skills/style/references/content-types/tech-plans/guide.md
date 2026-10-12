# Technical plans

*Content type: what kind of writing. Conventions here apply whatever the style.*

This content type covers engineering plans: implementation plans (including Claude Code's plan mode), design docs, RFCs and architecture decision records. The reader is an engineer who has to approve or carry out the plan, and who may never have seen this codebase. A good plan lets them do that without opening the code or asking the author.

Javadoc solved the same problem for API docs. Every symbol it mentions is a link, and every symbol has a one-line summary, so a reader never has to guess what something is. A plan should work the same way.

Default freedom: **balanced**.

## How scribb picks this content type
- Files in Claude Code's plans folder (`~/.claude/plans/`, or the folder the project's settings name) are technical plans.
- Any page can say so in frontmatter: `scribb-content-type: tech-plans`.
- A repo can map its design-doc folders with `paths_tech_plans` (for example `docs/design/*, rfcs/*, adr/*`).

Before Claude shows you a plan, scribb asks a cold reader, an agent that sees only the plan, what it would need to ask before acting on it. Claude answers those questions in the plan itself.

## Structure
1. **Context first.** The problem, why it matters now, and the outcome, written for someone who wasn't in the conversation.
2. **Words used.** Define each codebase term once, at first use or in a short glossary. After that, use the same word every time.
3. **Codebase primer.** List every part of the code the plan touches: a link, then one sentence on what it does today. This is the Javadoc summary idea; the reader should rarely need to click.
4. **Show, don't name.** When the plan reuses or changes a function, include its signature or a short excerpt (3–10 lines) so the reader sees what you mean.
5. **One diagram** when data or control flows across more than two components. Use Mermaid: it renders in Obsidian, on GitHub and in most editors.
6. **Numbered steps.** Each says what changes, where (linked) and why.
7. **Decisions.** One recommended approach, then a line on each alternative you rejected and why.
8. **Verification.** Commands a newcomer can run, with what they should see.

Keep it as short as those parts allow. A plan isn't a diary of how you got there.

## Links
Every file, function or other document the plan mentions is a link. Pick the form by the target:

| Link to | Form |
|---|---|
| Code in the repo | A Markdown link relative to the plan, with the line in the text: `[scribb.sh:394, content_type_for](../../plugin/lib/scribb.sh#L394)`. Obsidian opens the file; GitHub and editors jump to the line. |
| Code, when the plan sits outside the repo | A permalink pinned to a commit: `https://github.com/org/repo/blob/<commit>/path#L394` |
| A section of the plan, or another plan or note | An Obsidian wikilink: `[[#Codebase primer]]`, `[[2026-10-12 tech-plans]]` |

No bare paths. A path in backticks with nothing to click sends the reader off to search.

## Words
- Name things the way the code does. Put identifiers, paths and commands in code font, inside the link text.
- Don't lean on the conversation: "as discussed", "the existing helper", "the usual pattern" and "see above" mean nothing to a new reader. Name the thing and link it.
- Say what you'll do, not what you might do. Hedge only where something is truly unknown, and list those in the plan as open questions.
- Dates are absolute ("2026-10-12"), never "yesterday" or "last week".

## Example
A step that assumes context:

> Reuse the existing helper for the plan files and update the hook like before.

The same step, readable cold:

> 2. **Map plan files to this content type.** In [`content_type_for` (scribb.sh:394)](../../plugin/lib/scribb.sh#L394), which picks a file's content type from its frontmatter and path, return `tech-plans` for files in the plans folder before the "outside the project" check. *Why:* plans live in `~/.claude/plans/`, outside the repo, so today they're skipped.

## What the checker covers
`ScribbTechPlans.*` rules: ContextDependent, BarePath. The cold reader and the reviewer cover everything else on this page, including whether a newcomer could act on the plan.

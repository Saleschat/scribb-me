# 023 — Code comments

Status: done (PR 2 of 3, 2026-10-12)

## Context
Doc comments and inline comments that Claude writes while coding tend to be heavy: they restate the signature, narrate the implementation and leave notes such as "updated to use the cache". Good libraries in every language keep them short. Engineers asked for comments that read like the best of each ecosystem: Javadoc, Go doc comments, TSDoc, PEP 257 docstrings, rustdoc.

## Decisions
- **A content type, not a style:** every good engineer follows these rules (two-writers test).
- **Picked by the nature of the block, not the file extension** (`block: comments`). scribb splits each file into prose, UI text and comments (`plugin/lib/blocks.py`), so a `.tsx` file's doc comments are code comments and its JSX text is UI copy. Comments in Markdown code fences count too.
- **On by default.** Turned off like any setting, with `code_comments: off` in the user, project or local scope. No opt-in step and no new scope.
- **Only the comments a change touched** are checked by the hooks (`scribb-check --changed`), so editing a file never means rewriting old comments.
- **No auto reviewer** (`review_threshold: none`): the checker covers it, and a reviewer run per code edit would be noise.
- **Guide:** the shared core first (summary sentence, what and why, don't repeat the code, tags only when they add something, link, no history or reviewer notes, match the file's conventions), then a short section per ecosystem.
- **Rules:** `HistoryInComments` and `ReviewerNotes` (warnings), `RestatesSignature` (suggestion). Tuned for precision: "previously saved value" and "no longer valid" describe behaviour, not history, and pass.

## Open
- A rule for comments that only repeat the next line of code needs the code next to the comment; for now the reviewer guidance covers it.
- Quality eval `evals/quality/docstrings/` (with and without scribb) is still to run.

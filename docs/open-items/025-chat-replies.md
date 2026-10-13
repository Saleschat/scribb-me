# 025 — Chat replies

Status: pack and session-start rules done (PR #19, merged 2026-10-13); checking replies open

## Context
scribb's rules reached Claude's replies only loosely. The session-start context told Claude to follow the base rules for "a written piece in chat", and design discussions in the conversation weren't clearly one. The `tech-plans` guide (024) applied only to plan files and design docs. Nothing checked a reply: the `Stop` hook lints `last_assistant_message` only while `/scribb:write` has set `write_session: on` (011).

During design sessions, Claude's replies explain decisions and trade-offs to the person making them. Those replies should follow the same discipline as a technical plan, adjusted for a reader who was in the conversation.

## Decisions
- **A content type, `chat-replies`**, for replies that explain a design, a decision or a trade-off. Short replies about routine work, and pieces with their own content type (a newsletter drafted in chat), aren't covered.
- **`block: chat`.** The pack covers no files, so it never matches one. `content_type_for` skips block types, and `blocks.py` never produces a `chat` block.
- **Rules ride in the session-start context.** Replies happen every turn, so the summary is injected in full after the style rules, not loaded through a skill. It's on by default and turned off with `chat_replies: off` in any scope, like other content types.
- **Most tech-plans rules carry over:** one recommendation with a line per rejected alternative, defined terms, short excerpts and verification. Three change, because the reader was in the conversation:
  - Context first becomes answer first.
  - Links become `file:line`, which the terminal makes clickable.
  - `ContextDependent` doesn't apply: referring back is fine, as long as the reply names what it refers to.
- **Additions for replies:** say what's built, what's only decided and what's open, with the source; concede pushback that's right; end with the one decision or input needed, never a list of offers.
- **Format `design-discussion`:** answer, reasons, alternatives, state, ask.

## Built
- Step 1, the pack: `plugin/packs/content-types/chat-replies/` (pack.yaml, summary.md, guide.md, sample.md, formats/design-discussion.md), bundled for chat by `tools/build-chat.py`.
- Step 2, session-start rules: `session_start` in `plugin/hooks/scribb-hook` lists Chat replies as "your replies in this conversation" and injects its summary unless `chat_replies: off`.
- Tests in `tests/hooks/run.sh`: the type is listed, its rules are injected, it's not offered as a Markdown page type, it never matches a file, and `chat_replies: off` drops its rules.

## Open
- **Step 3, checking replies.** Run the regex checker (no reviewer agent) on `last_assistant_message` in the `Stop` hook for replies over about 150 words, with the retry cap of 2 the other checks use (011). Build it only if an eval shows the injected rules alone aren't enough: a check on every reply adds delay and noise to each turn.
- **Eval.** A `claude plugin eval` case where the user asks Claude to compare options for a design choice. Graders: the first sentence states a recommendation; one option is recommended; the reply doesn't end with a list of offers.
- **When to apply.** "Explains a design, a decision or a trade-off" is a judgement call for Claude. Watch for replies that should have followed the rules and didn't, and for short answers that got padded into the format.
- **Claude chat (claude.ai).** No session-start hook runs there. The `scribb-style` skill lists the type, but nothing loads it on every turn.

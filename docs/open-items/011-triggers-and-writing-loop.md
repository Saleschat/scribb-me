# 011 — Triggers and the writing loop

Status: triggers decided; writing loop proposed

## Decided: no custom planner. Match each behaviour to the right mechanism.
| How reliable | Mechanism | Used for |
|---|---|---|
| Always | Hooks (bash only) | inject the active style at session start, run `scribb-check` after an edit, capture memory signals |
| Always, when the user asks | Commands: `/scribb:write`, `/scribb:review`, `/scribb:remember`, `/scribb:learn` | anything the user starts on purpose |
| Best effort | Skills found from their descriptions | mid-conversation style requests |
| Background context | Style summary injected at session start (an AGENTS.md section in Codex) | active content type and style + top memories |

Memory: capture (a `UserPromptSubmit` grep for correction phrasing, or `/scribb:remember`) → add to inbox → learner agent proposes → human approves and picks the scope. Codex falls back to an AGENTS.md instruction for the capture step.

## Proposed: the detect-and-revise loop
Two loops that share the same exit criteria.

**Inner loop (always on, cheap, deterministic).** A `PostToolUse` hook on Write and Edit for files that match a content-type pattern:
- Runs `scribb-check` (the checker).
- If there are hard-level errors, it exits with code 2 so the findings go back to Claude, which revises. PostToolUse can't block, because the write has already happened; it can only feed back.
- At most 2 feedback retries per file per session; a small state file tracks attempts. After that it stops feeding back and shows what's left to the user.
- The orchestration is defined in a skill, not in a Claude Code Workflow script. Workflow scripts only run in Claude Code and can't pause for human approval (ECC keeps its approval gates in the main conversation for the same reason).

**Outer loop (`/scribb:write`, explicit, thorough).**
1. Brief: content type, style, freedom, format and audience.
2. Draft: writer.
3. Check: `scribb-check`.
4. Critique: reviewer subagent with **fresh context**. Its rubric is the base AI-habit patterns plus the style. It returns specific spans to fix, not a rewrite.
5. Revise.
6. Re-check.

At most 2 rounds, then present the result with any remaining flags.

**Exit criteria:** zero hard errors, and no reviewer findings at or above the freedom threshold.

**Why a separate reviewer:** a model reviewing its own draft in the same context doesn't notice its own patterns. A fresh context does, and it also lets us run the reviewer on a different model.

**Chat-only prose** (no file written): the `Stop` hook lints the last assistant message, but only when a scribb write session is active (flag file), so ordinary coding chat isn't touched.

**Codex and other tools:** no subagents, so the critique runs as a second skill pass. Hooks are only partly supported, so the skill calls `scribb-check` itself as a step.

## Open questions
- Retry cap and threshold defaults for each freedom level.
- Should the reviewer run on a different or cheaper model by default?
- Over-correction: tests that check revisions don't become stilted (for example, every em dash removed, every sentence the same length).

## Decided: running the reviewer without `/scribb:write`
- Setting `reviewer: off | auto | always`, default `auto`.
- `auto`: the PostToolUse hook asks Claude to run `scribb-reviewer` when one write or edit changes a lot of prose in a file that matches a content type (default ≥150 words for Docs, ≥5 strings for UI copy). Smaller edits only get the checker.
- Codex and other tools without subagents: `auto` falls back to the skill's second review pass.
- `/scribb:write` stays for chat-only pieces and explicit briefs.

## Decided: every automatic behaviour can be switched off at every level
Applies to the reviewer, the checker loop, memory capture, nudges and the session-start injection.

| Level | How |
|---|---|
| This piece | Say so in the prompt ("skip review", "no checks"). Hook-injected lines always tell Claude to respect an explicit skip. `/scribb:write --no-review` |
| This session | `/scribb:style reviewer off` (writes a session flag in `.scribb/local/`) |
| This repo, just me | local scope setting |
| This repo, whole team | project scope setting |
| Everywhere, for me | user scope setting |
| Kill switch | `SCRIBB_DISABLE=1` env var or `enabled: false`. Every hook exits immediately |

## Hook mechanics (verified against code.claude.com/docs/en/hooks.md, 2026-10-07)
- **Hooks are event-driven and run inside the agent loop.** They are not scheduled. By default Claude Code waits for them to finish (timeout: 600s for command hooks, 30s on UserPromptSubmit). All matching hooks for an event run in parallel.
- **Hooks from every location are merged, not overridden:** user, project and local settings, managed policy, plugin `hooks/hooks.json`, and skill/agent frontmatter. An identical handler defined in several settings files runs once, but a plugin's copy is separate. If someone installs the plugin and also copies the hook into their settings, it runs twice; the install docs must warn about this.
- **Output channels:**
  - `systemMessage` (top-level JSON) is shown to the user only.
  - `hookSpecificOutput.additionalContext` goes to Claude (SessionStart, UserPromptSubmit, PostToolUse).
  - Plain stdout is added to context for SessionStart and UserPromptSubmit.
  - On PostToolUse, `decision:"block"` or exit 2 adds the reason next to the tool result; the write has already happened.
- **Stop hooks:**
  - `decision:"block"` makes Claude continue.
  - `stop_hook_active` is true while Claude is already continuing because of a stop hook, so the hook must check it to avoid loops.
  - Claude Code ends the turn after 8 continuations in a row (`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`). Our own cap of 2 sits well below that.
- **`async: true`** runs a command hook in the background. **`asyncRewake: true`** runs it in the background and wakes Claude on exit 2.
- **Other hook types:** `http`, `mcp_tool`, `prompt` (single-turn LLM check) and `agent` (subagent with tools). These are Claude Code only.

## Decided (from the mechanics above)
- Run the checker hook with `asyncRewake: true`, so writing never waits on Vale and Claude is woken only when there are hard errors.
- Keep every synchronous hook to grep, ls or cat only (well under the 30s UserPromptSubmit timeout).
- In the Claude Code adapter, the `auto` reviewer could be an `agent`-type hook. Portable adapters keep the bash + additionalContext approach.

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- One hook adapter, `plugin/hooks/scribb-hook <event>`, registered in `plugin/hooks/hooks.json`. PostToolUse runs two handlers: a synchronous one (nudges and the auto reviewer trigger) and an `asyncRewake` one (the checker). A real headless session confirmed that the checker wakes Claude with its findings and Claude revises.
- Retry cap: 2 for every freedom level. On the third blocking result the hook tells Claude to stop revising and list what's left for the user, because a background hook's `systemMessage` isn't shown to the user.
- The Stop hook reads `last_assistant_message`, and only runs while `write_session: on` is set in the session scope by `/scribb:write`.
- The auto reviewer triggers once per file per session (`reviewer: always` every time).
- The reviewer agent inherits the session's model for now; a cheaper default is still open.

## Files written by shell commands (2026-10-08)
- A Cowork test showed Claude sometimes writes files with a shell command (`printf … > docs/a.md`) instead of the Write or Edit tool, so the PostToolUse `Write|Edit` checker never saw them.
- A second background hook on PostToolUse `Bash` (`scribb-hook check-bash`, `asyncRewake`) finds prose files changed since the last check (`git ls-files -m -o` newer than a per-session marker in a repository, `find -newer` otherwise; at most 10 files), and checks them the same way. The marker starts at session start, so files changed before the session don't count.
- `FileChanged` doesn't fit: it watches only exact file names, can't see new files it wasn't told about, and can't send findings to Claude.
- Not covered for shell-written files: the auto reviewer trigger and nudges, which still come from the Write/Edit hook.


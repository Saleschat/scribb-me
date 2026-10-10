---
name: style
description: Show or change scribb.me's writing setup. Shows the active style, content types, freedom and where each setting comes from; lists and switches styles; sets freedom or the reviewer; turns scribb off or on for this session, this repo or everywhere; adds a style pack from a git URL or path. Use when the user asks what style is active, wants a different style, or wants scribb off or on.
argument-hint: "[off|on [--repo|--team|--everywhere] | list | use <style> | freedom <level> | reviewer <off|auto|always> | add <git-url|path> | doctor]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**) Read(~/.config/scribb/**) Write(~/.config/scribb/**) Edit(~/.config/scribb/**)
---

# /scribb:style

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

Arguments: `$ARGUMENTS`

Current state:
!`"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config" status --session "${CLAUDE_SESSION_ID}"`

## Where you're running
Look at this path: `${CLAUDE_PLUGIN_ROOT}/scripts`.
- **Claude Code:** it's a real folder path. Use the helpers and follow the numbered steps; the "In chat" section doesn't apply. If the setup above is still a literal `!` command (that happens when the plugin is synced from claude.ai), run that command yourself first, on its own.
- **claude.ai chat, or another app without scribb's helpers:** it still reads `${CLAUDE_PLUGIN_ROOT}`. Don't run any `${CLAUDE_PLUGIN_ROOT}` command; skip to **In chat** at the end. Everything you need is in this skill's own folder: `references/` (the guides) and `scripts/check.py` (the checker). Paths are relative to this file, and `${CLAUDE_SKILL_DIR}` points at the folder where an app fills it in.

The helper is `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config"` (call it `scribb-config` below). Always pass `--session ${CLAUDE_SESSION_ID}` so session settings are read and written.

Scopes, in the user's words:
| User says | Scope | Flag |
|---|---|---|
| this session, for now | session | `--session ${CLAUDE_SESSION_ID}` |
| this repo, just me | local | `--repo` / `--scope local` |
| this repo, the whole team | project | `--team` / `--scope project` |
| everywhere, all my repos | user | `--everywhere` / `--scope user` |

## What to do
Pick the case from the arguments, or from what the user asked:

**No arguments**: summarise the current state above in 3–5 lines: on or off, style (tagline), content types and freedom, checker, memories and inbox. Then offer the most useful next step in one line (pick a style, install Vale, review the inbox).

**`off` / `on`**: run `scribb-config off|on` with the flag for the scope they named; default to the session. Confirm in one line and say how to undo it. Mention the other levels once: `--repo`, `--team`, `--everywhere`, or `SCRIBB_DISABLE=1` as a kill switch. For `--team`, remind them to commit `.scribb/config.yaml`.

**`list`** or "which styles are there": run `scribb-config packs --kind style`. Show at most three at a time as a choice (AskUserQuestion), labelled by tagline. In each option's preview, put that style's `sample.md` text for the content type they write most (read `<pack dir>/sample.md`), so they can compare side by side.

**`use <style>`** or "switch to …": run `scribb-config set style <id> --scope <scope>`. Ask for the scope only if it isn't clear; default to `local`. `use none` goes back to the neutral house style.

**`freedom <strict|balanced|expressive>`**: set `freedom` in the scope they named (default: session). Explain in one line what it changes: strict blocks on every rule; balanced lets style preferences through as warnings; expressive only blocks hard rules and offers 2–3 freer options.

**`reviewer <off|auto|always>`**: set `reviewer`. `auto` reviews after big prose edits (about 150+ words of docs, 5+ UI strings); `always` after every matching edit.

**`doctor`**: run `scribb-config doctor` and show its output. Explain the last hook runs in one or two lines: whether hooks ran at all, and why a file was skipped if it was.

**`content-type`**: show which files map to each content type (from the status above) and change them with `scribb-config set paths_<id> "<globs>" --scope project` if asked: `paths_docs`, `paths_ui`, `paths_newsletter`, `paths_website`, `paths_sales`.

**`add <git-url | path>`**: install a style pack.
1. Clone (shallow) or copy it into a temp folder.
2. Refuse it if it contains any executable or script file (anything other than `.md`, `.yaml`, `.yml`, `.json`, `.txt`). Say which file.
3. Show `pack.yaml` (tagline, licence, sources), `summary.md`, and the list of checker rules.
4. Ask to approve and pick the scope (user or project).
5. Copy it to `<scope>/packs/styles/<id>/` (paths from `scribb-config paths`) and add to its `pack.yaml`: `installed_from: <url>@<commit>`, `approved_by: <scribb-config approver>`, `approved_at: <UTC time>`.

The catalog of shared styles isn't published yet; for now `add` takes a git URL or a path.

## In chat
Chat has no scribb settings. Styles and content types are chosen per request.
- **list:** show the styles in `references/styles/` by their tagline (from `pack.yaml`), with each one's `sample.md` side by side, next to the neutral sample in `references/content-types/<id>/sample.md`.
- **use <style>:** tell the user to name the style in their request ("write this in the direct-developer-docs style"), or to add a line to their Project instructions, such as: `Write with scribb.me in the direct-developer-docs style.`
- **off:** scribb is off in chat unless a request asks for it or the background skill decides it applies. To stop that, turn the plugin off in **Customize > Plugins**.
- **freedom, reviewer, paths, add:** these are Claude Code settings. Say so in one line.

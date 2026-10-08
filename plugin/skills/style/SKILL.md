---
name: style
description: Show or change scribb.me's writing setup. Shows the active style, content types, freedom and where each setting comes from; lists and switches styles; sets freedom or the reviewer; turns scribb off or on for this session, this repo or everywhere; adds a style pack from a git URL or path. Use when the user asks what style is active, wants a different style, or wants scribb off or on.
argument-hint: "[off|on [--repo|--team|--everywhere] | list | use <style> | freedom <level> | reviewer <off|auto|always> | add <git-url|path>]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-check *)
---

# /scribb:style

Arguments: `$ARGUMENTS`

Current state:
!`"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config" status --session "${CLAUDE_SESSION_ID}"`

The helper is `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"` (call it `scribb-config` below). Always pass `--session ${CLAUDE_SESSION_ID}` so session settings are read and written.

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

**`content-type`**: show which files map to each content type (from the status above) and change them with `scribb-config set paths_<id> "<globs>" --scope project` if asked: `paths_docs`, `paths_ui`, `paths_newsletter`.

**`add <git-url | path>`**: install a style pack.
1. Clone (shallow) or copy it into a temp folder.
2. Refuse it if it contains any executable or script file (anything other than `.md`, `.yaml`, `.yml`, `.json`, `.txt`). Say which file.
3. Show `pack.yaml` (tagline, licence, sources), `summary.md`, and the list of checker rules.
4. Ask to approve and pick the scope (user or project).
5. Copy it to `<scope>/packs/<id>/` (paths from `scribb-config paths`) and add to its `pack.yaml`: `installed_from: <url>@<commit>`, `approved_by: <scribb-config approver>`, `approved_at: <UTC time>`.

The catalog of shared styles isn't published yet; for now `add` takes a git URL or a path.

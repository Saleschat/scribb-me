---
name: write
description: Write a piece of prose with scribb.me's full loop: infer a brief (content type, format, audience, length, freedom, style), draft, run the checker, get a fresh-context review, revise, at most two rounds. Use for docs, READMEs, guides, release notes, UI copy or chat-only pieces when the user asks scribb to write something or wants a careful, reviewed draft.
argument-hint: "<what to write> [--freedom strict|balanced|expressive] [--style <id>] [--format <id>] [--no-review]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**)
---

# /scribb:write

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

Request: `$ARGUMENTS`

Current setup:
!`"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config" status --session "${CLAUDE_SESSION_ID}"`

## Where you're running
Look at this path: `${CLAUDE_PLUGIN_ROOT}/scripts`.
- **Claude Code:** it's a real folder path. Use the helpers and follow the numbered steps; the "In chat" section doesn't apply. If the setup above is still a literal `!` command (that happens when the plugin is synced from claude.ai), run that command yourself first, on its own.
- **claude.ai chat, or another app without scribb's helpers:** it still reads `${CLAUDE_PLUGIN_ROOT}`. Don't run any `${CLAUDE_PLUGIN_ROOT}` command; skip to **In chat** at the end. Everything you need is in this skill's own folder: `references/` (the guides) and `scripts/check.py` (the checker). Paths are relative to this file, and `${CLAUDE_SKILL_DIR}` points at the folder where an app fills it in.

Helpers (full paths): `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config"`, `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide"`, `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check"`, `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge"`.

## 1. Brief
Infer the brief from the request and the target file. The user never writes YAML.
- `content_type`: `product-docs` (Product docs: getting started, how-tos, help articles, READMEs and other repo files, release notes), `developer-docs` (Developer docs: API, SDK and CLI reference, integration guides), `ux-microcopy` (UI copy) or `newsletter` (Newsletter), or another content type listed in the setup above. Take it from the file's `scribb-content-type:` frontmatter, then the request and what the page is about, then the file path. Docs folders are laid out differently in every repo, so don't decide developer vs product docs from the folder name alone. Ask only if it's truly ambiguous.
- `format`: one of the content type's `formats/` (Product docs: readme, contributing, getting-started, how-to, help-article, release-note; Developer docs: api-reference, cli-reference, integration-guide, concept, troubleshooting; UI: error-message, empty-state, confirmation-dialog, toast, onboarding-step, tooltip; Newsletter: regular-issue, product-update, welcome-email), or none.
- `audience`, `length`, `locale` (default: the repo's language), `output` (a file path, or chat).
- `freedom`: `--freedom`, else the setting, else the content type's default.
- `style`: `--style`, else the setting.

Precedence for this piece: what the user says now > format > content-type defaults > style. "Make this one casual" beats a formal style, for this piece only.

Show the brief as one line before drafting, for example `Docs · how-to · admins · ≤400w · strict · style: none` or `Newsletter · product-update · customers · ≤250w · balanced`, and go on unless the user corrects it.

If the output is chat (no file), turn on the write session so the Stop hook checks your reply when you finish:
`scribb-config set write_session on --scope session --session ${CLAUDE_SESSION_ID}`, then `scribb-config set content_type <ct> --scope session --session ${CLAUDE_SESSION_ID}`, and for a non-default freedom `scribb-config set write_freedom <level> --scope session --session ${CLAUDE_SESSION_ID}`. The Stop hook ends the write session itself after it has checked the reply; don't turn it off yourself.

## 2. Draft
Get the guidance in one call: `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide" --content-type <ct> --format <format> --session ${CLAUDE_SESSION_ID}` (leave out `--format` if there's none). It prints the base guide, the content type's guide, the format, the style and the approved memories. Write the draft. Strict: plain and conventional. Balanced: one good version. Expressive: freer phrasing, and offer 2–3 options for short pieces (titles, UI strings).

## 3. Check
If the piece is in a file, the checker hook runs on its own after the write. For a chat piece, check the draft before you show it, without writing a file: `scribb-check --session ${CLAUDE_SESSION_ID} --content-type <ct> --freedom <f> --text "<the draft>"` (findings say `text:line`). Fix every `block` finding. Consider `warn` ones.

## 4. Review
Unless `--no-review` or the user asked to skip review, give the `scribb-reviewer` agent: the text or file and changed range, content type, freedom, style, format, and the plugin root `${CLAUDE_PLUGIN_ROOT}`, and the full output of the `scribb-guide` call above, so the reviewer doesn't have to fetch the guides itself. Apply its confident findings. Don't apply a finding that would make the piece worse; you can overrule it.

## 5. Revise and repeat
Re-check after revising. Stop after two rounds, or earlier when there are no `block` findings and no confident reviewer findings at or above the freedom threshold.

## 6. Deliver
Present the piece (or confirm the file). If anything is still flagged, list it in one or two lines. Leave the write session on: the Stop hook checks this reply and then ends it.

Then run `scribb-nudge should-rate --session ${CLAUDE_SESSION_ID}`. If it exits 0, ask once with AskUserQuestion: "How was this draft?" with options Good, Fine, Bad, and Dismiss. Append the answer as one JSON line to `.scribb/local/ratings.jsonl`: `{"at": "<UTC time>", "content_type": "<ct>", "format": "<format>", "freedom": "<f>", "style": "<style>", "rating": "<answer>"}`. Never include the text.

## In chat
The references, all relative to this skill's folder:
- `references/base/guide.md` (always), `references/base/summary.md`
- `references/content-types/<id>/guide.md`, `summary.md`, `sample.md`, `formats/<format>.md`, and for UI copy `roles/shadcn.yaml`. Content types: `product-docs`, `developer-docs`, `ux-microcopy`, `newsletter`; each `pack.yaml` has its tagline and default freedom.
- `references/styles/<id>/guide.md`, `summary.md`, `sample.md`. Styles: `direct-developer-docs`, `crisp-product-ui`.

1. **Brief.** Infer it as in step 1, from the request alone: content type, format, audience, length, freedom (the content type's default unless the user says otherwise) and style (only if the user names one). Show the brief as one line and go on unless the user corrects it.
2. **Read** the base guide, the content type's guide, the format if there is one, and the style's guide. Follow any writing preferences in the user's Project instructions or earlier in the conversation; they beat the style.
3. **Draft.** Strict: plain and conventional. Balanced: one good version. Expressive: freer, with 2–3 options for short pieces.
4. **Check.** Run the checker if you can run code (code execution): save the text to a file, then `python3 scripts/check.py --content-type <ct> --freedom <level> [--style <id>] <file>`. Use a `.jsx` file for UI strings inside components, `.md` otherwise. It prints `file:line:col:action:severity:rule:message`, the same findings scribb's Vale checker gives in Claude Code. Fix every `block` finding and consider `warn` ones. If you can't run code, say once that the automatic check didn't run, and be extra careful in the review pass.
5. **Review it yourself, as a fresh reader.** Reread the draft against the base guide and the content type's guide, and list the exact passages that break a rule. Leave out anything you're unsure of, and don't over-correct (one em dash is fine; a habit is the problem).
6. **Revise**, re-check, and stop after two rounds. Present the piece, and list anything still flagged in one or two lines.
7. If the user corrects your wording during this, offer to turn the correction into a line for their Project instructions, so it applies next time (see the `remember` skill).

---
name: write
description: Write a piece of prose with scribb.me's full loop: infer a brief (content type, format, audience, length, freedom, style), draft, run the checker, get a fresh-context review, revise, at most two rounds. Use for docs, READMEs, guides, release notes, UI copy or chat-only pieces when the user asks scribb to write something or wants a careful, reviewed draft.
argument-hint: "<what to write> [--freedom strict|balanced|expressive] [--style <id>] [--format <id>] [--no-review]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-nudge *)
---

# /scribb:write

Request: `$ARGUMENTS`

Current setup:
!`"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config" status --session "${CLAUDE_SESSION_ID}"`

Helpers (full paths): `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"`, `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-check"`, `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-nudge"`. Packs: `${CLAUDE_PLUGIN_ROOT}/packs/`.

## 1. Brief
Infer the brief from the request and the target file. The user never writes YAML.
- `content_type`: `product-docs` (Product docs: getting started, how-tos, help articles, READMEs and other repo files, release notes), `developer-docs` (Developer docs: API, SDK and CLI reference, integration guides), `ux-microcopy` (UI copy) or `newsletter` (Newsletter), or another content type listed in the setup above. Take it from the file's `scribb-content-type:` frontmatter, then the request and what the page is about, then the file path. Docs folders are laid out differently in every repo, so don't decide developer vs product docs from the folder name alone. Ask only if it's truly ambiguous.
- `format`: one of the content type's `formats/` (Product docs: readme, contributing, getting-started, how-to, help-article, release-note; Developer docs: api-reference, cli-reference, integration-guide, concept, troubleshooting; UI: error-message, empty-state, confirmation-dialog, toast, onboarding-step, tooltip; Newsletter: regular-issue, product-update, welcome-email), or none.
- `audience`, `length`, `locale` (default: the repo's language), `output` (a file path, or chat).
- `freedom`: `--freedom`, else the setting, else the content type's default.
- `style`: `--style`, else the setting.

Precedence for this piece: what the user says now > format > content-type defaults > style. "Make this one casual" beats a formal style, for this piece only.

Show the brief as one line before drafting, for example `Docs · how-to · admins · ≤400w · strict · style: none` or `Newsletter · product-update · customers · ≤250w · balanced`, and go on unless the user corrects it.

If the output is chat (no file), turn on the write session so the Stop hook checks the reply:
`scribb-config set write_session on --scope session --session ${CLAUDE_SESSION_ID}` and `scribb-config set content_type <ct> --scope session --session ${CLAUDE_SESSION_ID}`. For a non-default freedom, also set `freedom` in the session scope, and unset it at the end.

## 2. Draft
Read, in order: `packs/base/guide.md`, the content type's `guide.md`, the format file, the style's `guide.md` (if any), and the memories listed at session start. Write the draft. Strict: plain and conventional. Balanced: one good version. Expressive: freer phrasing, and offer 2–3 options for short pieces (titles, UI strings).

## 3. Check
If the piece is in a file, the checker hook runs on its own after the write. Otherwise write the draft to a temp `.md` file (UI strings: `.jsx`) and run `scribb-check --session ${CLAUDE_SESSION_ID} --content-type <ct> --freedom <f> <file>`. Fix every `block` finding. Consider `warn` ones.

## 4. Review
Unless `--no-review` or the user asked to skip review, give the `scribb-reviewer` agent: the text or file and changed range, content type, freedom, style, format, and the plugin root `${CLAUDE_PLUGIN_ROOT}`. Apply its confident findings. Don't apply a finding that would make the piece worse; you can overrule it.

## 5. Revise and repeat
Re-check after revising. Stop after two rounds, or earlier when there are no `block` findings and no confident reviewer findings at or above the freedom threshold.

## 6. Deliver
Present the piece (or confirm the file). If anything is still flagged, list it in one or two lines. Turn the write session off if you turned it on: `scribb-config unset write_session --scope session --session ${CLAUDE_SESSION_ID}` (and `content_type`, `freedom` if set).

Then run `scribb-nudge should-rate --session ${CLAUDE_SESSION_ID}`. If it exits 0, ask once with AskUserQuestion: "How was this draft?" with options Good, Fine, Bad, and Dismiss. Append the answer as one JSON line to `.scribb/local/ratings.jsonl`: `{"at": "<UTC time>", "content_type": "<ct>", "format": "<format>", "freedom": "<f>", "style": "<style>", "rating": "<answer>"}`. Never include the text.

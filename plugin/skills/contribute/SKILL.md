---
name: contribute
description: Turn something learned locally with scribb.me (a memory, a vocab entry, a rule promoted from a memory, or a fix the user keeps making) into a pull request against the built-in packs in Saleschat/scribb-me, so every user gets it. Checks whether it's general enough, strips anything private, writes the rule or guide change with its tests, and opens the pull request only after the user approves. Use when the user wants to share or upstream a scribb preference or rule.
disable-model-invocation: true
argument-hint: "[memory id | rule | what to share]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-guide *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-check *) Bash(${CLAUDE_PLUGIN_ROOT}/scripts/scribb-nudge *) Read(/${CLAUDE_PLUGIN_ROOT}/**) Bash(git switch -c contrib/*) Bash(git checkout -b contrib/*) Bash(git add *) Bash(git commit *) Bash(git diff *) Bash(git status *) Bash(evals/rules/run.sh*)
---

# /scribb:contribute

**Running the helpers:** run each helper as its own command, with nothing chained before or after it (no `;`, `&&`, `|`, `2>&1` or `echo`). A chained command doesn't match this skill's allowed tools, so it would stop and ask the user for permission. Use the helpers instead of `cat` or `ls` on plugin files.

What to share: `$ARGUMENTS`

Helper: `"${CLAUDE_PLUGIN_ROOT}/scripts/scribb-config"`. Plugin root: `${CLAUDE_PLUGIN_ROOT}`. Upstream repo: `Saleschat/scribb-me` (public).

Everything this skill sends ends up public. Show the user every file and the pull request text before anything leaves their machine.

## 1. Pick what to share
If the arguments don't say, list the candidates and let the user pick (AskUserQuestion, multi-select):
- memories in `.scribb/memories/`, `.scribb/local/memories/` and the user dir's `memories/` (`scribb-config paths`), by their `statement:`
- rules promoted from memories in `.scribb/packs/rules/` and `.scribb/local/packs/rules/`
- entries in `vocab.txt`, but only generic terms; product names stay local

## 2. Decide whether it's general
Apply the two-writers test to each item: would two excellent writers of this kind both follow it?
- **Yes, for all writing**: a candidate for `base`. Be strict here; base rules apply everywhere.
- **Yes, for one kind of writing**: a candidate for that content type (`product-docs`, `developer-docs`, `ux-microcopy`, `newsletter`).
- **No, it's taste, or it's about this product** (names, internal terms, a house voice): tell the user it should stay local, say why in one line, and stop for that item. Offer `/scribb:learn` if they want to share a whole style; a style needs its own pack and licence review.

Say the verdict for each item and let the user overrule it.

## 3. Strip anything private
Rewrite examples so they're invented. Remove product names, customer names, internal URLs, people's names and text copied from the user's docs. If an item only makes sense with private detail, it stays local.

## 4. Draft the change
Work in a fresh clone in a temp folder, never in the user's own repositories:
- If the user can push to the repo (`gh repo view Saleschat/scribb-me --json viewerPermission` says `WRITE`, `MAINTAIN` or `ADMIN`): `cd <temp dir> && gh repo clone Saleschat/scribb-me`.
- Otherwise fork it: `cd <temp dir> && gh repo fork Saleschat/scribb-me --clone`.
- If `gh` isn't installed or signed in, write the files to a temp folder instead and finish with step 6's manual route.

Read `CONTRIBUTING.md` in the clone for the current rules.

Change into the clone first (`cd <clone>`, as its own command), so the commands below run there and match this skill's allowed tools. Pushing and opening the pull request will still ask the user, on purpose. In the clone, on a new branch (`git switch -c contrib/<short-slug>`):
- **A word or phrase rule**: add it to an existing rule file in the target pack's `checks/vale/<ValeStyle>/` if one fits (for example a substitution or existence list), or add a new rule file. Use `level: error` for base and `warning` for content types. Add or extend the test pair in `checks/vale/tests/` with invented bad and good text.
- **Guidance that a rule can't check**: add one or two lines to the target pack's `guide.md` (and `summary.md` if it's important enough to inject at session start), with an invented before/after example.
- Bump the pack's `version` (patch for a fix, minor for a new rule).
- Run `evals/rules/run.sh` in the clone (needs Vale), as its own command. Fix the change until it passes. For a guidance change, mention that the quality evals can be run with `evals/quality/run.sh --case <case>`, and offer to run the affected case (it costs money; say roughly how much).

## 5. Review with the user
Show the full diff, the test result and the draft pull request:
- Title: `<Pack>: <what changes>`, for example `product-docs: flag "utilize"`.
- Body: the repo's pull request template (`.github/PULL_REQUEST_TEMPLATE.md`) filled in, including the layer and why, and the before/after example.

Say plainly: "This will be posted publicly to github.com/Saleschat/scribb-me." Ask for approval (AskUserQuestion: open the pull request / edit first / cancel).

## 6. Submit
- With approval and `gh`: commit, push the branch (to the fork, if you forked), and run `gh pr create --repo Saleschat/scribb-me`. Give the user the pull request link.
- Without `gh`: give the user the files and the pull request text, and the link https://github.com/Saleschat/scribb-me/compare to open it themselves.
- Then add `contributed: <PR link>` to each local memory that was shared, so it isn't suggested again.

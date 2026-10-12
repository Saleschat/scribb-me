# 024 — Technical plans and the cold-read gate

Status: done (PR 3 of 3, 2026-10-12), with open questions below

## Context
Plans Claude writes (plan mode, design docs) name files, functions and "the existing helper" without saying what they are, so an engineer new to the codebase keeps switching between the plan and the code. Javadoc solves this for API docs: every symbol is a link with a one-line summary. Engineers asked for plans that read the same way, and that open in Obsidian so they can follow the links.

## Decisions
- **A content type, `tech-plans`:** implementation plans, design docs, RFCs and ADRs. Every good engineer follows these rules (two-writers test).
- **Plan files are technical plans** wherever they live: `~/.claude/plans/` (or `CLAUDE_CONFIG_DIR`), and a project folder named by `plansDirectory` in `.claude/settings.json` if Claude Code supports it. A repo can also map design-doc folders with `paths_tech_plans`, or a page can say so in frontmatter.
- **Guide:** context first; words defined once; a codebase primer (link plus one sentence per part touched); excerpts of reused code; one Mermaid diagram when the flow crosses more than two components; numbered steps with what, where and why; one recommendation with rejected alternatives; verification.
- **Links:** Markdown links relative to the plan for code (they open in Obsidian, and GitHub and editors jump to the line), commit permalinks when the plan sits outside the repo, `[[wikilinks]]` for sections and other notes. No bare paths.
- **Rules:** `ContextDependent` (warning: "as discussed", "the existing helper", "see above") and `BarePath` (suggestion: a path in backticks that isn't a link).
- **Cold-read gate:** before ExitPlanMode, the `scribb-cold-reader` agent reads only the plan and lists up to 8 questions a newcomer would ask; Claude answers them in the plan. One round per plan version. Claude Code documents ExitPlanMode as a permission request, so the gate listens on both PreToolUse and PermissionRequest with one state file. It's off when `tech_plans: off` or `reviewer: off`.

## Open
- **The plans folder setting isn't documented.** We checked the Claude Code docs on 2026-10-12 and found no setting to move plan files into the repo. scribb reads `plansDirectory` if a project sets it, but `/scribb:setup` doesn't write it. Until then, plans in `~/.claude/plans/` should link to commit permalinks. Alternative to build later: copy an approved plan into `docs/plans/` and rewrite its links.
- **Which event fires for ExitPlanMode** in each permission mode (PreToolUse, PermissionRequest, or both) needs checking in a live session, including whether the PermissionRequest hook fires in auto-accept modes.
- Quality eval `evals/quality/tech-plan/` (with and without scribb) is still to run.

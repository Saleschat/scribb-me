---
name: report
description: Draft a GitHub issue for scribb.me, such as a checker false positive, a missed AI-writing habit, or a bug in a hook or skill. Shows exactly what would be sent and submits only after the user approves. Use when the user wants to report a problem with scribb or a rule.
disable-model-invocation: true
argument-hint: "<what went wrong>"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *)
---

# /scribb:report

Problem: `$ARGUMENTS`

1. Work out the kind: false positive (a rule flagged good text), missed pattern, or bug.
2. Draft the issue:
   - Title: `False positive: <RuleID> flags "<short phrase>"`, `Missed pattern: …`, or `Bug: …`.
   - Body: what happened, what was expected, the smallest example text that shows it (written fresh or trimmed by the user; never paste private content without asking), the rule ID and pack version, `scribb` version from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, Vale version, OS.
3. Show the full title and body and say: "This is exactly what will be posted publicly to github.com/Saleschat/scribb-me." Let the user edit it.
4. Only after they approve: if `gh` is installed and signed in, run `gh issue create --repo Saleschat/scribb-me --title … --body …`. Otherwise give them a prefilled link: `https://github.com/Saleschat/scribb-me/issues/new?title=<urlencoded>&body=<urlencoded>`.

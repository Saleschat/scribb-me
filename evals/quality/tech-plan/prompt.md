---
description: Technical plans. A plan for a change to an unfamiliar repo, written to docs/plans/; tests that it stands on its own (primer with links, reused code shown, steps with where and why, verification).
tags: [tech-plans]
plugins: ["../../../plugin"]
max_turns: 20
timeout_seconds: 500
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Read this repo and write an implementation plan, saved as docs/plans/revoke-keys.md, for adding a `POST /v1/keys/:id/revoke` endpoint that marks a key revoked and records an audit event. Don't write the code; the plan is for another engineer who has never seen this repo. It should have `scribb-content-type: tech-plans` in its frontmatter.

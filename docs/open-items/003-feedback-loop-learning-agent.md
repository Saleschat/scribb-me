# 003 — Feedback loop and learning agent

Status: model decided (hybrid), mechanics proposed

## Decided
- **Sources are inputs.** The learning agent distills them into a pack once. References are stored in `sources.json` but not refetched; re-learning is on demand.
- **Hybrid learning:** capture is shaped like ECC's "instincts" and gets a confidence score, but nothing takes effect without human approval.
  - Captured signals go to an inbox and never change behaviour on their own.
  - The learner groups related signals and raises confidence when one recurs. Above a threshold (default: the same signal 3 times) it suggests saving it as a memory.
  - Changes to rules or packs always need explicit approval.
  - A signal approved in 2+ projects is suggested for the user scope.
- **Every approved change records who approved it** (see below).

## Proposed mechanics
**Capture (`UserPromptSubmit` hook, bash, no jq):**
- Greps the prompt for correction phrasing.
- On a match, writes one raw signal file to the inbox and adds a line of context telling Claude to offer to save it.
- The hook stays dumb: no deduplication or scoring. The learner does that.

**Inbox (decided):** in the local scope, `.scribb/local/inbox/`, gitignored.
- Each user has their own inbox for each project.
- On approval, the user picks a scope: local (just here), project (team) or user (everywhere for me). Approved memories are the only thing that reaches committed `.scribb/`.
- Cross-project promotion: the learner keeps an index in the user scope of what has been approved. When a statement has been approved in 2+ projects, it suggests saving it to the user scope.
- Known gap: teammates' signals aren't pooled. That can come later in the webapp.

**Suggesting a save:**
- *Inline:* after handling the correction, Claude asks in one line, using AskUserQuestion in Claude Code or plain text elsewhere: just me / whole team / don't save.
- *Batched:* the `SessionStart` hook counts pending inbox files. If any are above the threshold, it adds a line telling Claude to offer `/scribb:learn` at a natural pause. The learner subagent then presents them as one multi-select.
- *Rejected* suggestions are recorded so they're never asked again.

**Memory file** (one per memory, markdown + frontmatter):
```yaml
---
id: term-workspace-not-account
kind: term            # term | preference | avoid | format
scope: project        # user | project
statement: Say "workspace", never "account", for the tenant concept.
confidence: 0.8
evidence: [inbox/2026-10-07T10-02-ab12.md, inbox/2026-10-07T14-40-cd34.md]
proposed_by: scribb-learner
approved_by: Jane Doe <jane@example.com>   # git user.name/email, falls back to $USER
approved_at: 2026-10-07T15:02:11Z
promoted_to_rule: null # or the checker rule path, once a memory becomes a lint rule
---
```
- The approver is self-reported (from git config), not authenticated. Committing project-scope memories adds git history as a second record. The webapp will replace this with real user IDs.

**Applying memories:**
- The `SessionStart` hook injects the active style summary plus memories (size-capped, highest confidence first).
- A memory that can be checked mechanically (terms, banned words) can be promoted to a checker rule in the project pack (`.scribb/packs/project/checks/<engine>/`). That needs its own approval.

## Open questions
- Correction phrasing list and its false-positive rate.
- The size cap for injected memories, and what to do when memories exceed it.
- Re-learning from sources on demand (`/scribb:learn --from-sources`).

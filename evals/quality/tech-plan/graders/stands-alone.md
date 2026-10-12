---
type: llm
focus: { source: file, path: docs/plans/revoke-keys.md }
---

Read only the plan, as an engineer who has never seen this repository. FAIL if any of these clear problems is present; otherwise PASS.
- A file or function the plan changes or reuses (`find`, `save`, `record`, `routes`) is named without saying what it does.
- The plan says what to change but not where (no file or link) or not why.
- There's no way to check the work is done (no tests or commands to run).
- You'd have to open the code to understand what the `Key` or `AuditEvent` shapes are.

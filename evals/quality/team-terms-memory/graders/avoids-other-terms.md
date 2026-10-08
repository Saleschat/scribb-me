---
type: regex
target: { source: file, path: docs/invite-teammates.md }
match: not_contains
flags: i
pattern: "\\b(workspace|organization|organisation)s?\\b|your account"
---

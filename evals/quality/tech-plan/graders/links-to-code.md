---
type: regex
target: { source: file, path: docs/plans/revoke-keys.md }
match: contains
pattern: "\\]\\((\\.\\./)+src/(keys/store|audit/log|http/routes)\\.ts"
---

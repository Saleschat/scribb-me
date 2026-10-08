---
type: regex
target: { source: file, path: src/components/DeleteProjectDialog.tsx }
match: not_contains
flags: i
pattern: "[\"'>]\\s*(please|oops|whoops|uh oh|sorry)\\b|successfully|an error (has )?occurred|something went wrong[.!]?[\"'<]|click here"
---

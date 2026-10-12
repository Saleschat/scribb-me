---
type: regex
target: { source: file, path: src/ledger.ts }
match: not_contains
flags: i
pattern: "this (function|method|type) (is used to|will)|updated to|as requested|\\bdelve|robust|seamless"
---

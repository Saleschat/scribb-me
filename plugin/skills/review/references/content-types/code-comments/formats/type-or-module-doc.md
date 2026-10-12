---
id: type-or-module-doc
content_type: code-comments
summary: The doc comment on a type, class, module or package. What it represents and when to use it.
sections:
  - name: Summary
    required: true
    length: "one sentence: what it is, starting with its name where the language expects that (Go)"
  - name: Purpose
    required: false
    length: "1–3 sentences: when to use it, and what it's not for"
  - name: Usage
    required: false
    length: "a short example of the common case"
  - name: Related
    required: false
    length: "links to the types and functions it works with"
---
```go
// Package ledger records invoices and payments and reports what's due.
//
// Use [Open] to get a [Ledger]; it's safe for concurrent use.
package ledger
```

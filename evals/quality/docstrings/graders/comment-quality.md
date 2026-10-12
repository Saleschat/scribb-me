---
type: llm
focus: { source: file, path: src/ledger.ts }
---

Judge only the comments, not the code. FAIL if any of these clear problems is present; otherwise PASS.
- An exported item has no doc comment, or a doc comment doesn't open with a one-sentence summary of what the item does.
- A comment repeats types TypeScript already declares (for example "@param invoices {Invoice[]} the array of invoices" or "returns a number").
- A comment narrates the implementation step by step instead of saying what the function does.
- `dueBefore` doesn't mention that it returns unpaid invoices only, strictly before the cutoff, oldest first; or `totalCents` doesn't mention the RangeError.
- A doc comment is longer than about six lines for these small functions.

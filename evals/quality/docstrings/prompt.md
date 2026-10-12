---
description: Code comments. Document a small TypeScript module; tests that doc comments follow TSDoc and stay short (block-by-block checking picks code-comments with no setup).
tags: [code-comments]
plugins: ["../../../plugin"]
max_turns: 15
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Write src/ledger.ts with doc comments on everything exported. It exports `type Invoice = { id: string; amountCents: number; dueOn: Date; paidOn?: Date }`, a function `dueBefore(invoices: Invoice[], cutoff: Date): Invoice[]` that returns unpaid invoices due strictly before the cutoff, oldest first, and a function `totalCents(invoices: Invoice[]): number` that throws a RangeError if any amount is negative.

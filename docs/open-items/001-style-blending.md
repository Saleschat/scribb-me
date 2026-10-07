# 001 — Style blending ("create pack from A + B")

Status: deferred (out of scope for v1)

## Context
v1 allows exactly one style pack per piece, and styles never stack at runtime. A later version could let the learning agent combine two style packs into a new single style pack, which a human approves before use.

## Open questions
- What does the input look like: weights, or a prose instruction?
- Does the new pack keep a link to its parent packs, so it can be re-learned when they change?

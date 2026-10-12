---
id: adr
content_type: tech-plans
summary: An architecture decision record. One decision, its context and its consequences, kept short and never edited after it's accepted.
sections:
  - name: Title
    required: true
    length: "a short noun phrase, numbered (ADR 12: …)"
  - name: Status
    required: true
    length: "proposed, accepted, or superseded by ADR n"
  - name: Context
    required: true
    length: "the forces at play, linked to the code or docs they concern"
  - name: Decision
    required: true
    length: "one or two sentences, in the active voice: We will …"
  - name: Consequences
    required: true
    length: "what becomes easier, what becomes harder"
---
# ADR 12: Store audit events in Postgres

Status: accepted

## Decision
We will store audit events in the main Postgres database, in an append-only table.

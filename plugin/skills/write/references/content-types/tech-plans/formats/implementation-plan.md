---
id: implementation-plan
content_type: tech-plans
summary: A plan to change a codebase, such as Claude Code's plan mode produces. Readable by an engineer who has never seen the code.
sections:
  - name: Context
    required: true
    length: "2–5 sentences: the problem, why now, the outcome"
  - name: Words used
    required: false
    length: "one line per codebase term the plan relies on"
  - name: Codebase primer
    required: true
    length: "a table or list: each part touched, linked, with one sentence on what it does today; signatures or 3–10 line excerpts for code reused"
  - name: Diagram
    required: false
    length: "one Mermaid diagram when the flow crosses more than two components"
  - name: Steps
    required: true
    length: "numbered; each says what changes, where (linked) and why"
  - name: Rejected alternatives
    required: false
    length: "one line each"
  - name: Verification
    required: true
    length: "commands to run and what they should show"
---
See `sample.md` for a complete example.

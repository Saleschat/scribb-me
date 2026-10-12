---
id: design-doc
content_type: tech-plans
summary: A design doc or RFC that proposes a change for others to review before anyone builds it.
sections:
  - name: Summary
    required: true
    length: "2–3 sentences anyone in the company can follow"
  - name: Motivation
    required: true
    length: "the problem, who has it, and why now"
  - name: Background
    required: false
    length: "the parts of the system a reviewer needs, each linked with one sentence on what it does"
  - name: Proposal
    required: true
    length: "the design, with one diagram when it helps, and the interfaces it adds or changes"
  - name: Alternatives
    required: true
    length: "each option considered, and why it lost"
  - name: Risks and rollout
    required: false
    length: "what could go wrong, how it ships, how to roll back"
  - name: Open questions
    required: false
    length: "what's still undecided, and who decides"
---
# Rate-limit the public API per key

## Summary
Limit each API key to 600 requests a minute, so one noisy client can't slow the API for everyone.

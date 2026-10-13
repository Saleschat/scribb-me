---
id: design-discussion
content_type: chat-replies
summary: A reply that explains a design choice or compares options, so the user can decide and move on.
sections:
  - name: Answer
    required: true
    length: "one or two sentences: the recommendation or the finding"
  - name: Reasons
    required: true
    length: "the reasons that decide it, as bullets when there are several"
  - name: Alternatives
    required: false
    length: "one line per rejected option, saying why it lost"
  - name: State
    required: false
    length: "what's built, decided or open, with the doc section or file:line that says so"
  - name: Ask
    required: false
    length: "the one decision or input needed from the user, answerable in a word or two"
---
Store events locally first and send them in batches from the session hook.

- The user can read exactly what will be sent in `.scribb/local/telemetry.jsonl`.
- A failed send costs nothing: the next session retries.

Sending each event as it happens would add a network call to every hook run, which the hooks' 10-second timeout can't afford.

Decided in `docs/open-items/016-usage-telemetry.md`, not built yet.

How many sessions before the opt-in offer appears?

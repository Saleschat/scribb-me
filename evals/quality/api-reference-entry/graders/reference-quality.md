---
type: llm
focus: { source: file, path: docs/api/revoke-key.md }
---

FAIL if any of these clear problems is present; otherwise PASS.
- The `key_id` path parameter, the Authorization header or the `reason` body field is missing, or `reason`'s 200-character limit isn't mentioned.
- There's no example request or no example response.
- Errors are listed without saying when each one happens.
- It explains basics a developer already knows (what HTTP or a status code is) or pads with marketing language.

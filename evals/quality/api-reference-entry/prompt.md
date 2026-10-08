---
description: Developer docs. An API reference entry; developer-docs has no default path, so this tests choosing it from the request.
tags: [developer-docs]
plugins: ["../../../plugin"]
max_turns: 15
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Write the API reference page for our endpoint that revokes an API key, and save it as docs/api/revoke-key.md. It's `POST /v1/keys/{key_id}/revoke`, needs an admin token in the Authorization header, takes an optional JSON body with `reason` (string, max 200 chars), and returns 200 with the key object (`id`, `status: "revoked"`, `revoked_at`). Errors: 401 bad token, 403 not an admin, 404 unknown key, 409 already revoked.

---
id: how-to
content_type: product-docs
summary: Steps for one task, for a reader who already knows what they want to do.
sections:
  - name: Title
    required: true
    length: "≤ 8 words, starts with a verb"
  - name: Intro
    required: true
    length: "1–2 sentences: the task and its result"
  - name: Before you begin
    required: false
    length: "bullets: prerequisites, permissions, versions"
  - name: Steps
    required: true
    length: "numbered list, one action per step, ≤ 10 steps (split longer tasks)"
  - name: Verify
    required: false
    length: "1–3 sentences or a command and its expected output"
  - name: Next steps
    required: false
    length: "≤ 3 links"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# Rotate an API key

Replace an API key without downtime by running the old and new keys side by side.

## Before you begin
- You need the **Admin** role.

## Steps
1. Open **Settings** > **API keys** and select **Create key**.
2. Copy the new key and add it to each service that calls the API.
3. Deploy the services.
4. In **API keys**, select **Revoke** next to the old key.

## Verify
Check your logs for `401` responses. If there are none after an hour, the rotation worked.

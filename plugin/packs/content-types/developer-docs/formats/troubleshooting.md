---
id: troubleshooting
content_type: developer-docs
summary: Helps a reader who has a specific symptom find the cause and the fix.
sections:
  - name: Title
    required: true
    length: "the symptom or the error message, as the reader sees it"
  - name: Symptom
    required: true
    length: "1–2 sentences, including the exact error text"
  - name: Cause
    required: true
    length: "1–3 sentences per cause; list the likeliest cause first"
  - name: Fix
    required: true
    length: "steps for each cause"
  - name: Still not working
    required: false
    length: "where to get help, and what to include"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# Requests fail with 401 Unauthorized

## Symptom
API calls return `401 Unauthorized` with the message `invalid api key`.

## Cause
The key was revoked or belongs to a different project.

## Fix
1. Open **Settings** > **API keys** and check that the key is listed and active.
2. If it isn't, create a new key and update the service that sends the request.

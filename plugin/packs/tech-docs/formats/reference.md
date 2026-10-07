---
id: reference
content_type: tech-docs
summary: Describes every option, field or endpoint, for a reader who looks things up. Complete and consistent, no narrative.
sections:
  - name: Title
    required: true
    length: "the name of the thing described"
  - name: Intro
    required: true
    length: "1 sentence"
  - name: Entries
    required: true
    length: "one entry per item, same fields in the same order: name, type, default, description, example"
  - name: Errors
    required: false
    length: "table of codes and what each means"
---
# API keys endpoint

Create, list and revoke API keys for a project.

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | string | none | A label shown in **Settings** > **API keys**. |
| `role` | string | `read` | One of `read`, `write`, `admin`. |
| `expires_at` | timestamp | null | Optional. The key stops working at this time. |

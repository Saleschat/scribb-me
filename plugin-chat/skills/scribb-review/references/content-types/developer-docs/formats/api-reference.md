---
id: api-reference
content_type: developer-docs
summary: Describes an endpoint, method or object completely, for a developer who looks things up. Consistent entries, no narrative.
sections:
  - name: Title
    required: true
    length: "the method and path, or the name of the method or object"
  - name: Intro
    required: true
    length: "1–2 sentences: what it does and any side effect the reader must know"
  - name: Parameters
    required: true
    length: "one entry per parameter, same fields in the same order: name, location, type, required or default, description"
  - name: Example request
    required: true
    length: "one runnable request, per SDK if there are several"
  - name: Response
    required: true
    length: "status code and the shape of the body, with an example"
  - name: Errors
    required: false
    length: "table of code, error and cause, most likely first"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# List API keys

`GET /v1/keys`

Returns the API keys in a project, newest first. Revoked keys are left out unless you ask for them.

| Parameter | In | Type | Default | Description |
|---|---|---|---|---|
| `include_revoked` | query | boolean | `false` | Include revoked keys. |
| `limit` | query | integer | `20` | Keys per page, from 1 to 100. |

```bash
curl https://api.example.com/v1/keys?limit=50 \
  -H "Authorization: Bearer YOUR_API_KEY"
```

Returns `200` with `{"data": [...], "next_cursor": "..."}`.

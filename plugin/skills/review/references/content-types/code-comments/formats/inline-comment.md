---
id: inline-comment
content_type: code-comments
summary: A comment inside a function body. Only for a why the code can't show.
sections:
  - name: Why
    required: true
    length: "one line: the constraint, workaround or surprising choice"
  - name: Link
    required: false
    length: "the issue or spec that explains it, when there is one"
---
```python
# The API rounds to whole cents, so compare in cents to avoid float drift.
if round(total * 100) != expected_cents:
```

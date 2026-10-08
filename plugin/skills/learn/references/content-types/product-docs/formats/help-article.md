---
id: help-article
content_type: product-docs
summary: Answers one question a user asks about the product, in the words they'd search for.
sections:
  - name: Title
    required: true
    length: "the question or task as a user would type it, ≤ 10 words"
  - name: Answer
    required: true
    length: "1–3 sentences that answer it directly"
  - name: Steps
    required: false
    length: "numbered, if the answer is a task"
  - name: Details
    required: false
    length: "limits, plans, permissions or edge cases, as bullets"
  - name: Related
    required: false
    length: "≤ 3 links"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# Can I restore a deleted project?

Yes, for 30 days. After that, the project and its data are gone for good.

## Steps
1. Open **Settings** > **Deleted projects**.
2. Select **Restore** next to the project.

## Details
- You need the **Admin** role.
- Restored projects keep their dashboards but not their API keys. Create new keys after you restore.

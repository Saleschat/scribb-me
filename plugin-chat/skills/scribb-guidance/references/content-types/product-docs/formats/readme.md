---
id: readme
content_type: product-docs
summary: The front page of a code repository. Tells a visitor what the project is, whether it's for them, and how to start, in that order.
sections:
  - name: Title and one-line description
    required: true
    length: "the project name, then one sentence: what it is and who it's for"
  - name: What it does
    required: false
    length: "2–5 bullets or a short paragraph; outcomes, not internals"
  - name: Install
    required: true
    length: "the shortest working install command for each supported platform"
  - name: Quick start
    required: true
    length: "≤ 5 steps or one code block that works when copied"
  - name: Usage
    required: false
    length: "the 2–4 most common tasks, each with an example; link to full docs"
  - name: Getting help and contributing
    required: false
    length: "1–3 lines with links (issues, discussions, CONTRIBUTING.md)"
  - name: Licence
    required: true
    length: "one line naming the licence, linked to the LICENSE file"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# Foo

Foo syncs your team's API keys across environments, for developers who deploy to more than one cloud.

## Install
```bash
brew install foo
```

## Quick start
1. Sign in: `foo login`.
2. Link a project: `foo link my-project`.
3. Sync keys to staging: `foo sync --env staging`.

## Licence
MIT. See [LICENSE](LICENSE).

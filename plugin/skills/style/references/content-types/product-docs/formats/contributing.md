---
id: contributing
content_type: product-docs
summary: Tells someone who wants to change the project how to set up, test and propose the change, and what reviewers look for.
sections:
  - name: Intro
    required: true
    length: "1–2 sentences: which contributions are welcome and where to start"
  - name: Set up
    required: true
    length: "steps or commands to get a working development copy"
  - name: Run the tests
    required: true
    length: "the commands, and how long they take"
  - name: Propose a change
    required: true
    length: "branch, commit and pull request conventions, in a short list"
  - name: What reviewers look for
    required: false
    length: "3–6 bullets"
  - name: Code of conduct
    required: false
    length: "one line with a link"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# Contributing to foo

Bug fixes, docs and new sync targets are welcome. For a larger change, open an issue first so we can agree on the approach.

## Set up
```bash
git clone https://github.com/example/foo && cd foo
make setup
```

## Run the tests
`make test` runs the unit tests in about a minute.

## Propose a change
- Branch from `main` and keep each pull request to one change.
- Describe what changed and how you tested it.

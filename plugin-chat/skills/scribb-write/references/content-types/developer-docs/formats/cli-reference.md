---
id: cli-reference
content_type: developer-docs
summary: "Documents one command: what it does, its arguments and flags, examples and exit codes."
sections:
  - name: Title
    required: true
    length: "the full command, for example `foo keys revoke`"
  - name: Synopsis
    required: true
    length: "one usage line in a code block"
  - name: Description
    required: true
    length: "1–3 sentences"
  - name: Arguments and flags
    required: true
    length: "one entry each: name, short form, type, default, description"
  - name: Examples
    required: true
    length: "1–3 commands, each with a one-line description and the output"
  - name: Exit codes
    required: false
    length: "table of code and meaning"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# `foo keys revoke`

```
foo keys revoke <key-id> [--reason <text>] [--yes]
```

Revokes an API key immediately. The command asks for confirmation unless you pass `--yes`.

| Flag | Short | Type | Default | Description |
|---|---|---|---|---|
| `--reason` | `-r` | string | none | A note stored in the audit log. |
| `--yes` | `-y` | boolean | `false` | Skip the confirmation prompt. |

Revoke a key without a prompt:

```bash
foo keys revoke key_8f2c --yes
```

```text
Revoked key_8f2c
```

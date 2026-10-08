---
description: Product docs. A README for a small CLI, the most common repo file.
tags: [product-docs, smoke]
plugins: ["../../../plugin"]
max_turns: 15
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Write a README.md for a new open-source command-line tool called `tidy`. It formats YAML files in place, sorts keys, and can run as a pre-commit hook. It installs with `brew install tidy` or `go install github.com/example/tidy@latest`. Keep it to what a visitor needs to decide whether to use it and get started.

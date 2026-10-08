---
description: Not a writing task. scribb shouldn't run its reviewer or talk about writing style.
tags: [negative, smoke]
plugins: ["../../../plugin"]
max_turns: 10
timeout_seconds: 300
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---

Write src/slugify.py with a function slugify(text: str) -> str that lowercases, strips accents, replaces runs of non-alphanumeric characters with a single hyphen, and trims hyphens from both ends. Add a few doctest examples.

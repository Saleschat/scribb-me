---
id: concept
content_type: developer-docs
summary: Explains how something works and why, so the reader can make decisions. No steps.
sections:
  - name: Title
    required: true
    length: "noun phrase, ≤ 6 words"
  - name: Intro
    required: true
    length: "1–3 sentences: what it is and why it matters to the reader"
  - name: Body
    required: true
    length: "2–6 short sections, each answering one question"
  - name: Diagram or example
    required: false
    length: "one, if it explains faster than prose"
  - name: Related
    required: false
    length: "links to the how-tos and reference pages that use this concept"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# How API keys work

An API key identifies the project that sends a request. Keys don't expire, so the risk grows the longer a key is in use.

## What a key can access
Each key belongs to one project and has the permissions of the role it was created with.

## Why rotation matters
A leaked key works until someone revokes it. Regular rotation limits how long a leaked key stays useful.

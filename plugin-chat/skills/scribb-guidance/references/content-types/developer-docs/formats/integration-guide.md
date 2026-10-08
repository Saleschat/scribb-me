---
id: integration-guide
content_type: developer-docs
summary: Walks a developer through connecting the product to their code or another system, from credentials to a verified working integration.
sections:
  - name: Title
    required: true
    length: "≤ 8 words, starts with a verb, names both systems"
  - name: Intro
    required: true
    length: "1–2 sentences: what the integration does and what the reader ends up with"
  - name: Prerequisites
    required: true
    length: "bullets: accounts, keys, roles, language and SDK versions"
  - name: Steps
    required: true
    length: "numbered, one action per step, each code step with a runnable sample"
  - name: Verify
    required: true
    length: "a request, command or test that proves it works, with the expected output"
  - name: Next steps
    required: false
    length: "≤ 3 links, for example to the reference pages used"
---
<!-- Example FORMAT: a task template inside a content type. It fixes the structure of one kind of page; the content type's rules still apply. -->
# Send events from Node.js to Foo

Install the Foo SDK in a Node.js service and send your first event.

## Prerequisites
- Node.js 20 or later.
- An API key with the `write` role.

## Steps
1. Install the SDK:
   ```bash
   npm install @foo/sdk
   ```
2. Create a client with your key:
   ```js
   import { Foo } from "@foo/sdk";
   const foo = new Foo({ apiKey: process.env.FOO_API_KEY });
   ```
3. Send an event:
   ```js
   await foo.events.send({ name: "signup", userId: "u_123" });
   ```

## Verify
Open **Events** in Foo. The `signup` event appears within a few seconds.

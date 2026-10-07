---
name: remember
description: Save one writing preference as a scribb.me memory (a term, a word to avoid, a preference or a format), after asking who it applies to (just me here, the whole team, or me everywhere) and recording who approved it. Use when the user says to remember a wording or style preference, or after a scribb hook suggests saving a correction.
argument-hint: "<the preference, e.g. say workspace, not account>"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/scribb-config *)
---

# /scribb:remember

Preference: `$ARGUMENTS`

Helper: `"${CLAUDE_PLUGIN_ROOT}/bin/scribb-config"`.

## Steps
1. **State it.** Turn the preference into one imperative sentence that stands on its own, e.g. `Say "workspace", never "account", for the tenant concept.` If it came from a conversation, use the user's intent, not their exact words. Pick the kind: `term` (what to call something), `avoid` (words or habits to drop), `preference` (tone, length, structure), `format` (how a type of piece is laid out).
2. **Ask the scope** (AskUserQuestion, unless the user already said): "Just me, in this repo" (local), "The whole team" (project; it's committed), "Me, in every repo" (user), "Don't save". Suggest the team for product terms, and just me for personal taste.
3. **Write the file** `<dir>/<id>.md`, where `<dir>` is `.scribb/local/memories/` (local), `.scribb/memories/` (project) or `<user dir>/memories/` (user; `scribb-config paths` prints it). `<id>` is a short kebab-case slug of the statement; if the file exists, the user is updating that memory.

   ```markdown
   ---
   id: term-workspace-not-account
   kind: term
   scope: project
   statement: Say "workspace", never "account", for the tenant concept.
   confidence: 0.8
   evidence: []
   proposed_by: user
   approved_by: <output of scribb-config approver>
   approved_at: <UTC time, ISO 8601>
   promoted_to_rule: null
   ---

   <optional: one or two short examples of right and wrong>
   ```
   Keep `statement:` on one line, in double quotes only if it contains a colon. Use confidence 0.8 when the user stated it directly, and the learner's score when it came from the inbox. List the inbox files it came from under `evidence`.
4. **Clean up the inbox.** Delete the inbox files the memory came from (`.scribb/local/inbox/`). On "Don't save", delete them too and append the statement to `.scribb/local/rejected.txt` so it isn't suggested again.
5. **Cross-project index.** Append `<UTC time>\t<scope>\t<repo name>\t<statement>` to `approvals.index` in the user dir. If the same statement now appears for 2 or more repos, offer once to save it for every repo (user scope).
6. **Names.** If the memory is a product or feature name with its own casing, also append it to `vocab.txt` in the same scope (`.scribb/vocab.txt` for the team), so the checker accepts it.
7. **Checker rule (optional).** If the memory is a fixed word or phrase, offer to also make it a checker rule. On yes, write a Vale rule in `.scribb/packs/project/checks/vale/ScribbProject/` (or the local equivalent `.scribb/local/packs/local/checks/vale/ScribbLocal/`), create that pack's `pack.yaml` if missing (`id: project`, `kind: memory-rules`, `version: 0.1.0`, `tagline: Rules promoted from memories`, `license: MIT`), and set `promoted_to_rule:` to the rule path.
8. Confirm in one line: what was saved, where, and that it applies from now on (and from the next session start for the injected summary).

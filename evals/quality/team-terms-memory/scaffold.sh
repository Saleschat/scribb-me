#!/usr/bin/env bash
# A repo where the team approved a scribb memory about one term.
set -e
git init -q .
mkdir -p .scribb/memories docs
cat > .scribb/memories/term-studio.md <<'MEM'
---
id: term-studio
kind: term
scope: project
statement: Call the shared space a team works in a "studio", never a "workspace", "account" or "organization".
confidence: 0.8
evidence: []
proposed_by: user
approved_by: Eval Fixture <eval@example.com>
approved_at: 2026-10-01T00:00:00Z
promoted_to_rule: null
---
MEM

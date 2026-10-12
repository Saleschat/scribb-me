#!/usr/bin/env bash
# A small repo with an API, a key store and an audit log, to plan a change against.
set -e
git init -q .
mkdir -p src/keys src/audit src/http docs/plans
cat > src/keys/store.ts <<'TS'
export type Key = { id: string; projectId: string; revokedAt?: Date };

const keys = new Map<string, Key>();

export function find(id: string): Key | undefined {
  return keys.get(id);
}

export function save(key: Key): void {
  keys.set(key.id, key);
}
TS
cat > src/audit/log.ts <<'TS'
export type AuditEvent = { type: string; actor: string; target: string; at: Date };

const events: AuditEvent[] = [];

export function record(event: AuditEvent): void {
  events.push(event);
}
TS
cat > src/http/routes.ts <<'TS'
import { find } from "../keys/store";

export const routes = {
  "GET /v1/keys/:id": (id: string) => find(id) ?? { error: "not_found" },
};
TS
git add -A
git -c user.email=eval@example.com -c user.name=Eval commit -qm "Initial"

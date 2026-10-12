<!-- Shared tech-plans reference text. Every style with docs in good_for can rewrite this plan in its sample.md, so users can compare styles side by side. -->
# Plan: revoke API keys from the dashboard

## Context
Admins can revoke an API key only through the API today, so a leaked key stays live until someone with a terminal acts. This plan adds a **Revoke** button to the key list. Outcome: an admin revokes a key in two clicks, and every revocation lands in the audit log.

## Codebase primer
| Part | What it does today |
|---|---|
| [`revoke` (keys/service.ts:42)](../../src/keys/service.ts#L42) | Marks a key revoked and returns it. Throws `NotFound` for an unknown ID. |
| [`KeyList` (dashboard/KeyList.tsx:10)](../../src/dashboard/KeyList.tsx#L10) | Renders the project's keys in a table. Read-only. |
| [`audit.record` (audit/log.ts:8)](../../src/audit/log.ts#L8) | Appends an event to the audit log. |

```ts
export async function revoke(id: string, reason?: string): Promise<Key>
```

## Steps
1. **Add the button.** In [`KeyList`](../../src/dashboard/KeyList.tsx#L10), add a **Revoke** action per row that opens a confirmation dialog. *Why:* revocation can't be undone.
2. **Call the service.** On confirm, call [`revoke`](../../src/keys/service.ts#L42) with the admin's reason, then [`audit.record`](../../src/audit/log.ts#L8) with the key ID and the admin's ID.

Rejected: a bulk "revoke all" action. It's riskier, and no one has asked for it.

## Verification
`npm test -- keys` passes, including the new `KeyList revoke` test. In the dashboard, revoking a key removes it from the active list and adds a `key.revoked` audit event.

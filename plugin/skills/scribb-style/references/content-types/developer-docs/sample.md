<!-- Shared developer-docs reference text. Every style with docs in good_for rewrites this entry in its sample.md, so users can compare styles side by side. -->
## Revoke an API key

`POST /v1/keys/{id}/revoke`

Revokes an API key immediately. Requests that use the key afterwards fail. You can't undo a revocation; create a new key instead.

| Parameter | In | Type | Required | Description |
|---|---|---|---|---|
| `id` | path | string | yes | The ID of the key to revoke, for example `key_8f2c`. |
| `reason` | body | string | no | A note stored in the audit log. Up to 200 characters. |

```bash
curl -X POST https://api.example.com/v1/keys/key_8f2c/revoke \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"reason": "Employee left the team"}'
```

Returns `200` with the revoked key, including `revoked_at`.

| Code | Error | Cause |
|---|---|---|
| `403` | `insufficient_role` | The calling key doesn't have the `admin` role. |
| `404` | `key_not_found` | No key with this ID exists in the project. |
| `409` | `already_revoked` | The key was revoked earlier. |

## Developer docs reference text in this style
<!-- Rewrites the shared developer-docs sample (content-types/developer-docs/sample.md). -->

### Revoke an API key

`POST /v1/keys/{id}/revoke`

Revokes a key now. Requests with it fail from then on. Revocation is permanent; create a new key instead.

| Parameter | In | Type | Required | Description |
|---|---|---|---|---|
| `id` | path | string | yes | Key ID, for example `key_8f2c`. |
| `reason` | body | string | no | Audit-log note, up to 200 characters. |

```bash
curl -X POST https://api.example.com/v1/keys/key_8f2c/revoke \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"reason": "Employee left"}'
```

Returns `200` and the revoked key, with `revoked_at` set.

| Code | Error | Cause |
|---|---|---|
| `403` | `insufficient_role` | Calling key lacks `admin`. |
| `404` | `key_not_found` | No such key in this project. |
| `409` | `already_revoked` | Already revoked. |

## Docs reference text in this style
Rotate API keys on a schedule, and whenever someone with access leaves. Keys don't expire.

1. Create a key in **Settings** > **API keys**.
2. Replace the old key in every service that uses it.
3. Revoke the old key.

Requests with a revoked key fail with `401`. Check your logs for them after you revoke.

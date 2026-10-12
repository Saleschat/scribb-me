<!-- Shared code-comments reference text. Every style with code in good_for rewrites these comments in its sample.md, so users can compare styles side by side. -->
```go
// Revoke disables an API key immediately. Requests that use the key
// afterwards fail with [ErrRevoked].
//
// A revocation can't be undone; create a new key with [Create] instead.
func Revoke(ctx context.Context, id string, reason string) (*Key, error)
```

```ts
/**
 * Revokes an API key immediately. Requests that use it afterwards fail.
 *
 * @param reason - A note for the audit log, up to 200 characters.
 * @throws {@link NotFound} if no key has this ID.
 */
export async function revoke(id: string, reason?: string): Promise<Key>
```

```python
def revoke(key_id: str, reason: str | None = None) -> Key:
    """Revoke an API key immediately.

    Requests that use the key afterwards fail. A revocation can't be undone.

    Args:
        reason: A note for the audit log, up to 200 characters.
    """
```

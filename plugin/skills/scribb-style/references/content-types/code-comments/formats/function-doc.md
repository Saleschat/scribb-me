---
id: function-doc
content_type: code-comments
summary: The doc comment on a function or method. A summary sentence, then only the facts the signature can't show.
sections:
  - name: Summary
    required: true
    length: "one sentence, a verb phrase about what it does"
  - name: Details
    required: false
    length: "1–3 sentences: behaviour the caller must know (side effects, units, what null means)"
  - name: Tags
    required: false
    length: "parameters, return value and errors, only those that add something"
  - name: Example
    required: false
    length: "one short, runnable example, when usage isn't obvious"
---
```java
/**
 * Returns the invoices due before the given date, oldest first.
 *
 * @param before the cutoff, exclusive
 * @throws IllegalStateException if the ledger is closed
 */
public List<Invoice> dueBefore(LocalDate before)
```

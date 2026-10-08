---
type: llm
focus: { source: file, path: src/components/DeleteProjectDialog.tsx }
---

Judge only the user-facing strings, not the code. FAIL if any of these clear problems is present; otherwise PASS.
- The confirm button says "OK", "Yes", "Confirm" or "Continue" instead of naming the action.
- The description doesn't say that the deletion is permanent or can't be undone.
- The failure message gives no next step (such as retrying or checking the connection).
- A string is apologetic or chatty ("Oops", "Sorry", "Uh oh", jokes, emoji).

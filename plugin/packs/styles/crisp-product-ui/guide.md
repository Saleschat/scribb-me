# Crisp product UI

A style for interface copy in busy, task-heavy products: dashboards, admin tools, developer consoles. It's calm and compact. The user should never have to read a string twice.

Good for: UI copy.

## Voice
- Neutral and calm. The same tone for success and failure.
- "You" for the user. "We" almost never; the product doesn't talk about itself.
- No personality jokes, puns or emoji.

## Length
- Buttons: 1–2 words where possible ("Save", "Delete project").
- Toasts: 2–4 words ("Changes saved").
- Errors: one sentence, with a next step.
- Cut articles in buttons, badges and toasts when the meaning stays clear: "Create project", "Invite sent".

## Words
- Device-neutral verbs: "select", "choose", "enter", not "click", "tap" or "type".
- Standard spellings: "email" (not "e-mail"), "sign in" / "log in to" (not "log into"), "set up" for the verb and "setup" for the noun.
- Front-load the important word. "Project deleted" scans faster than "Your project has been deleted".

## Before and after
| Role | Before | After |
|---|---|---|
| toast | Your changes have been saved | Changes saved |
| button | Click to continue | Continue |
| field-error | The e-mail you entered is not valid. | Enter a valid email address. |

## Checker rules (suggestions)
`CrispProductUi.Terms` suggests "email" for "e-mail", "log in to" for "log into", "sign in to" for "sign into", and "select" for "click on" and "click".

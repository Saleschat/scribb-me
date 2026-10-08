# Interface copy

*Example content type: what kind of writing. Conventions here apply whatever the style.*

This content type covers strings in a product's interface: buttons, dialogs, toasts, form errors, empty states, tooltips and badges. People read UI copy while doing something else. Every word competes with the task.

Default freedom: **strict**.

## Rules for every role
- Sentence case. Capitalize the first word and proper nouns only.
- Address the user as "you". Use "we" sparingly, for the product team ("We'll email you when it's ready").
- Present tense, active voice.
- No "please", "sorry", "oops" or exclamation marks.
- Same term for the same thing everywhere. If the button says **Archive**, the toast says "Project archived".
- Numbers as numerals: "3 projects".
- Don't end buttons, labels, titles or badges with a full stop. Use one in descriptions, toasts and errors that are full sentences.

## Roles
The checker can't tell which role a string has. You can: look at the component it's passed to, using the role map in `roles/` (for example `roles/shadcn.yaml`).

| Role | Length | Casing and punctuation | Structure |
|---|---|---|---|
| `button` | 1–3 words, ≤ 25 characters | Sentence case, no full stop | Verb + object: "Delete project", "Save changes". Avoid "OK", "Yes", "Submit" |
| `dialog-title` | ≤ 8 words | Sentence case, no full stop; a question is fine | Name the action: "Delete this project?" |
| `dialog-description` | 1–2 sentences | Full sentences | Consequence first, then anything the user should know |
| `destructive-confirm` | 1–3 words | Same as button | Repeats the title's verb: "Delete project". The cancel button says "Cancel" |
| `toast` | ≤ 1 sentence, ≤ 60 characters | Full stop optional if one short phrase | Object + past-tense verb: "Project deleted". Add an action if there is one ("Undo") |
| `field-error` | 1 sentence | Full stop | What's wrong and how to fix it: "Enter an email address, like name@example.com." |
| `empty-state` | Title ≤ 6 words + 1–2 sentences + 1 button | Sentence case | What would be here, and how to add the first one |
| `tooltip` | ≤ 1 sentence, ≤ 80 characters | No full stop for fragments | Adds information the label can't hold. Never repeats the label |
| `badge` | 1–2 words | Sentence case, no full stop | A state: "Draft", "Expires soon" |
| `label` | 1–4 words | Sentence case, no colon | Names the field: "Project name" |
| `placeholder` | Example only | No full stop | An example value, never the only instruction: "name@example.com" |

### Errors
- Say what happened, in the user's terms: "Couldn't save the project", not "Error 500".
- Say what to do next: "Check your connection and try again."
- Don't blame: "That password is incorrect", not "You entered the wrong password".
- "Something went wrong" is acceptable only as a last-resort fallback, with a next step. The checker flags the emptier "An error occurred" and "Unknown error".

### Destructive actions
- The title names the action and the object. The description names the consequence, including what can't be undone.
- The confirm button repeats the verb. Never "OK" or "Yes".
- Don't ask "Are you sure?" on its own. Say what will happen.

## Examples
| Role | Before | After |
|---|---|---|
| button | Submit | Create project |
| toast | Project was successfully deleted! | Project deleted |
| field-error | Invalid input | Enter a project name. |
| empty-state | Oops, nothing here! | No projects yet. Create a project to start tracking work. |
| dialog-title | Are you sure? | Delete this project? |

## What the checker covers
`ScribbUI.*` rules check role-independent things: PleaseSorry, Oops, Exclamation, Successfully, GenericError and ClickHere.

Coverage in v1:
- `.jsx`: JSX text and string literals (the `JSXCopy` view).
- `.tsx`: JSX text and string literals too. `scribb-check` lints a `.jsx` copy of the file, because Vale's TypeScript grammar can't see text between tags. A standalone config from `scribb-check --export` (for CI or an editor) still uses the `TSXCopy` view, which reaches string literals only.
- i18n JSON files: not checked. Vale can't select only the values.

The reviewer covers what the checker can't reach, and applies the role rules above.

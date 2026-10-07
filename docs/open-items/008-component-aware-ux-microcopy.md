# 008 — Component-aware UX microcopy (shadcn first)

Status: v1 approach decided, needs implementation

## Context
shadcn/ui is the first design system we support. UX copy rules depend on where a string appears: a button label, an alert-dialog title or description, a toast, a form error, an empty state, a tooltip, a badge.

## Decided (v1)
- **The UI-copy pack defines rules for each generic UI role** (button, dialog-title, dialog-description, destructive-confirm, toast, field-error, empty-state, tooltip, badge…): length, casing, structure and examples for each. The UI-copy formats in 013 line up with these roles.
- **Component → role maps are data:** `packs/ux-microcopy/roles/shadcn.yaml` (`AlertDialogTitle` → dialog-title, `Button` → button, `toast()`/sonner → toast, `FormMessage` → field-error…). Another design system means adding another YAML file.
- **In v1 the model works out roles:**
  - When writing, Claude knows which component it's filling in; the background skill and reviewer apply the role guide.
  - When reviewing existing files, the reviewer judges roles using the same map.
- **The checker in v1 covers only role-independent UI rules:** sentence case, no trailing period on buttons, banned words, no "Please/Sorry" filler.
- **Later (with the CLI, 010):** an AST extractor turns strings and their components into a role-tagged list, so role rules can be enforced mechanically and i18n keys get roles from where they're used.
- Starting examples come from shadcn examples (MIT) and Grafana and PatternFly UX writing guidance (Apache-2.0 / MIT). Users add reference UIs as style sources in their own scopes.

## Open questions
- Check whether Vale can reach string literals in `.tsx` files and values in i18n JSON (Vale views or tree-sitter scoping?), before promising checker coverage there.

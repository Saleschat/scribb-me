# 008 — Component-aware UX microcopy (shadcn first)

Status: v1 approach decided, needs implementation

## Context
shadcn/ui is the first design system we support. UX copy rules depend on where a string appears: a button label, an alert-dialog title or description, a toast, a form error, an empty state, a tooltip, a badge.

## Decided (v1)
- **The UI-copy pack defines rules for each generic UI role** (button, dialog-title, dialog-description, destructive-confirm, toast, field-error, empty-state, tooltip, badge…): length, casing, structure and examples for each. The UI-copy formats in 013 line up with these roles.
- **Component → role maps are data:** `packs/content-types/ux-microcopy/roles/shadcn.yaml` (`AlertDialogTitle` → dialog-title, `Button` → button, `toast()`/sonner → toast, `FormMessage` → field-error…). Another design system means adding another YAML file.
- **In v1 the model works out roles:**
  - When writing, Claude knows which component it's filling in; the background skill and reviewer apply the role guide.
  - When reviewing existing files, the reviewer judges roles using the same map.
- **The checker in v1 covers only role-independent UI rules:** sentence case, no trailing period on buttons, banned words, no `Please`/`Sorry` filler.
- **Later (with the CLI, 010):** an AST extractor turns strings and their components into a role-tagged list, so role rules can be enforced mechanically and i18n keys get roles from where they're used.
- Starting examples come from shadcn examples (MIT) and Grafana and PatternFly UX writing guidance (Apache-2.0 / MIT). Users add reference UIs as style sources in their own scopes.

## Open questions
- How to check i18n JSON values (see below).

## Checked 2026-10-07 (Vale 3.24)
- Vale views (tree-sitter) reach string literals in `.tsx` and both string literals and JSX text in `.jsx`. Vale parses `.tsx` with the TypeScript grammar, which has no `jsx_text` node, so JSX text in `.tsx` isn't reachable. The views are `plugin/packs/content-types/ux-microcopy/checks/vale/config/views/{JSXCopy,TSXCopy}.yml`.
- i18n JSON: a dasel view didn't select values, and plain linting would also lint keys, so i18n JSON isn't checked in v0.1. The reviewer covers it, and the AST extractor (010) will.
- `roles/shadcn.yaml` adds `label`, `placeholder`, `menu-item`, `heading` and `field-help` roles, each following an existing role's rules.

## Changed 2026-10-08 (smoke test)
- A smoke test showed the gap mattered: most UI copy in React apps is JSX text in `.tsx` files (`<h2>No projects yet</h2>`), and the checker missed all of it.
- Fix: `scribb-check` lints a `.jsx` copy of each `.tsx` file with the `JSXCopy` view. Vale's JSX grammar skips TypeScript-only syntax (types, interfaces, `as`, `satisfies`) without false findings, and line numbers don't change. One known miss: text inside a component with a generic type argument (`<Button<Props>>…`) can be skipped.
- An exported config (`scribb-check --export`) can't do this, because Vale run on its own always parses `.tsx` with the TypeScript grammar, so it still reaches string literals only.


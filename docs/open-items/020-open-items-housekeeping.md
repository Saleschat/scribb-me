# 020: Open-items housekeeping

Status: open

## Context
Several items still list open questions that later work answered, for example:
- 005: "Should a project be able to lock freedom?" (answered: `freedom` in `.scribb/config.yaml`, offered by `/scribb:setup`)
- 007: the root symlink for editor integrations (answered: `scribb-check --export .scribb/checker`)
- 013: the format schema (answered in 013 and `docs/pack-format.md`)
- 008: checker coverage for `.tsx` (answered: lint a `.jsx` copy)

## To do
- Go through every item's "Open questions", move answered ones into the item's decisions, and set each item's `Status:` to match what's built.
- Keep the items that are still open, including: correction phrasing and memory size caps (003), retry and threshold defaults and the reviewer's model (011), re-learning a style (014), the telemetry backend and offer timing (016), and the `feedbackRate` default (017).

## Also still open after v0.1 (recorded in their items)
- Files written by shell commands don't trigger the auto reviewer or nudges (011).
- Quality evals that show a gain: longer pieces, a weaker model, styles, and style fidelity (015).
- i18n JSON checks (008), the Codex adapter and `npx scribb` installer (018), the catalog (018), telemetry (016).

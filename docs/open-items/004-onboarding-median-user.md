# 004 — Onboarding for the median user

Status: decided, flow details open

## Decided: progressive disclosure, nothing required up front
- **Install the plugin, then just write.** No setup step is required.
- **Picking a style is optional.** With no style chosen, scribb applies base + content type only (a neutral house style).
- **Content type is usually inferred** from the prompt or task, or from the file path or extension. The user is asked only when it's ambiguous.
- **`/scribb:setup` is optional.** It's for teams or deliberate configuration: writes project `.scribb/` (default style, file-path mapping, glossary, freedom lock).
- **The checker (Vale) is optional but recommended.** Without it, everything still works except the deterministic check loop. scribb suggests installing it once, at a moment when it's useful, never at install time.
- **One-time nudges, each shown once** (flag in user scope), each at the moment it's relevant:
  - after the first written piece: "Pick a style with `/scribb:style`, or teach me one with `/scribb:learn`"
  - the first time a check would have run without the checker installed: "Install Vale for automatic checks (`brew install vale`)"
  - when an inbox signal crosses its threshold: the memory suggestion (see 003)
- Zero-config defaults:
  - plugin-shipped default checker config mapping file types to content types (`*.md` → Docs, `*.tsx/*.jsx/*.vue` → UI copy),
  - each content type's default freedom,
  - base summary injected at session start.
- The median user picks by tagline; experts can also filter by traits (see 002).
- Precedence: piece > local > project > user > built-in.

## Open questions
- How a user creates their own style (uploads or links) the first time they ask for one.
- A way to turn off all nudges (`nudges: off`).

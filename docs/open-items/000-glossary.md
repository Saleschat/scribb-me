# 000 — Glossary

User-facing words come first. Contributors also use the file terms.

| User-facing | File / contributor term | Meaning |
|---|---|---|
| **Style** | `kind: style` | Who it sounds like: a person, publication or brand, distilled from samples. Optional; at most one per piece. Chosen by its tagline. |
| **Content type** | `kind: content-type` | What kind of writing it is: Docs, UI copy (later Marketing, Editorial…). Usually inferred from the task or file; the user only picks one if it's ambiguous. |
| *(hidden)* | `kind: base` | Universal anti-AI-writing rules. Always on. |
| **Brief** | `brief` | Inputs for one piece: audience, format, freedom, length, and so on. |
| **Freedom** | `freedom` | strict · balanced · expressive. How far a piece may depart from preference and convention rules. Hard and anti-AI rules never relax. |
| **Traits** | `traits:` | Fixed attributes for filtering styles and content types (formality, density, person, source_type, medium). The values within each trait are the tags experts pick. |
| **Tagline** | `tagline` | One-line description; the median user chooses by it. |
| **Sample** | `sample` | The shared reference paragraph rewritten in this style, for side-by-side comparison. |
| **Memory** | memory file | One learned preference with confidence, scope and approver. |
| **Checker** | `bin/scribb-check` | The deterministic rule engine wrapper (Vale in v1). |
| *(hidden)* | **pack** | The folder that holds a base, content type or style. |
| *(hidden)* | **scope** | built-in · user · project · local. Precedence: piece > local > project > user > built-in. |

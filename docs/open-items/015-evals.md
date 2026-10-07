# 015 — Eval suite

Status: decided, needs implementation

## Layers (pull requests that change packs, rules or skills must pass in CI)
| Layer | Tests | How |
|---|---|---|
| 1. Rule tests | Each checker rule fires on bad text and stays quiet on good text | `checks/<engine>/tests/<rule>.{bad,good}.md`, plus a false-positive suite: base rules run over human-written text (human half of RAID + openly licensed docs) with a maximum allowed hit rate |
| 2. Before/after | scribb makes output less AI-like | Fixed prompts per content type and format, generated with and without scribb. Checker hits per 1,000 words + a pairwise LLM judge with the order randomised |
| 3. Over-correction | Revisions don't turn stilted | Sentence-length variance, punctuation use and readability stay within a band of the human reference |
| 4. Style fidelity | A learned style sounds like its source | Held-out comparison (see 014), run on built-in styles |

## Rules
- Eval data lives in `evals/` with each dataset's license recorded. It is never shipped in the plugin.
- The judge runs on a different model from the writer.
- A scoreboard file is committed with each release.

## Open questions
- Does `claude plugin eval` fit layers 2–4, or do we need our own runner?
- Cost budget for nightly runs.

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- Layer 1: `evals/rules/run.sh` runs a bad/good pair for every rule plus a false-positive pass of the base rules over every good example and pack text. `tests/hooks/run.sh` tests the hook adapter with and without jq. CI (`.github/workflows/ci.yml`) runs both, shellcheck and `claude plugin validate`.
- `claude plugin eval` exists (cases of prompt + graders, `--ablation with-without`), so it likely fits layer 2. Not tried yet.

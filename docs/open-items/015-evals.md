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
- `claude plugin eval` fits layers 2 and 3 (see below). Layer 4 (style fidelity) is still open.
- Cost budget for nightly runs.

## Implemented in v0.1 (branch `v1-claude-code-plugin`, 2026-10-07)
- Layer 1: `evals/rules/run.sh` runs a bad/good pair for every rule plus a false-positive pass of the base rules over every good example and pack text. `tests/hooks/run.sh` tests the hook adapter with and without jq. CI (`.github/workflows/ci.yml`) runs both, shellcheck and `claude plugin validate`.
- `claude plugin eval` exists (cases of prompt + graders, `--ablation with-without`), so it likely fits layer 2. Not tried yet.

## Quality evals (layers 2–3), added 2026-10-08
- `evals/quality/` is a `claude plugin eval` suite, kept at the repo root so it never ships in the plugin. Run it from the repo root with `evals/quality/run.sh` (it passes `--eval-dir evals/quality`; cases point at the plugin with `plugins: ["../../../plugin"]`, which the eval tool only allows inside the directory it runs against).
- Cases: `readme-for-cli` (product docs), `api-reference-entry` (developer docs), `ui-delete-dialog` (UI copy), `newsletter-product-update`, `team-terms-memory` (a scaffolded project memory), and `ignores-coding-task` (scribb mustn't intrude on code work). Graders: free `regex` checks on the produced file for habits and required structure, `llm` rubrics written as short lists of clear failures (judge: Sonnet), and a "not over-corrected" rubric on two cases (layer 3).
- First results (2 runs per arm, about $3.30 in total):
  - The generic writing cases score 1.00 **with and without** scribb. On short tasks the default model already avoids the obvious habits, so the suite catches regressions there but doesn't show a gain.
  - `team-terms-memory` scores 1.00 with scribb and 0.00 without (Δ +1.00): a team term the model can't guess ("studio") reaches the writing only through scribb's memories.
  - Lessons: the first rubrics demanded too much and the default small judge failed good copy; rubrics as lists of clear failures with a Sonnet judge are stable. A case must use something the model wouldn't do anyway (the first memory case used "workspace", which the baseline picked on its own).
- Next: cases where the gain should show without team context: longer pieces, a weaker `--model`, styles, and the checker loop on habits that appear in long drafts.
- CI: `.github/workflows/quality-evals.yml` runs the suite manually (workflow_dispatch) with an `ANTHROPIC_API_KEY` secret. It isn't run on every pull request because of cost.

## To do: run the quality evals in CI
`.github/workflows/quality-evals.yml` (manual) needs an `ANTHROPIC_API_KEY` repository secret before it can run.

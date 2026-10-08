#!/usr/bin/env bash
# Quality evals (layers 2 and 3): each case runs with and without scribb, and
# the report shows what scribb adds (Δ). Uses your Claude credentials and costs
# money: about $3–4 for the whole suite at 2 runs per arm.
#
# Usage: evals/quality/run.sh [extra claude plugin eval options]
#   evals/quality/run.sh --case ui-delete-dialog --runs 1
set -eu
cd "$(dirname "$0")/../.."
exec claude plugin eval . \
  --eval-dir evals/quality \
  --scaffold \
  --runs "${RUNS:-2}" \
  -j 4 \
  --judge-model "${JUDGE_MODEL:-sonnet}" \
  --allow-tools Write Edit \
  --trust-plugin \
  --threshold 0.8 \
  --max-cost-usd "${MAX_COST_USD:-10}" \
  "$@"

#!/usr/bin/env bash
# Run all denseness probe examples. Exit non-zero if any FAIL.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

EXAMPLES=(
  examples/01-single-loop/main.aura
  examples/02-business-signal/main.aura
  examples/03-researcher-executor/main.aura
  examples/04-hot-strategy-heal/main.aura
  examples/05-long-run-denseness/main.aura
  examples/06-propose-edge-escape/main.aura
  examples/07-proposal-schema/main.aura
  examples/08-parse-proposal-wire/main.aura
)

fail=0
for ex in "${EXAMPLES[@]}"; do
  echo "======== $ex ========"
  if ! out=$(./scripts/run-aura.sh "$ex" 2>&1); then
    echo "$out"
    echo "HARD FAIL: runner error on $ex"
    fail=1
    continue
  fi
  echo "$out" | tail -n 5
  if ! echo "$out" | grep -q '^PASS:'; then
    echo "FAIL: no PASS line in $ex"
    fail=1
  fi
  echo
done

if [[ "$fail" -ne 0 ]]; then
  echo "run-all: SOME FAILED"
  exit 1
fi
echo "run-all: ALL PASSED (${#EXAMPLES[@]} examples)"

#!/usr/bin/env bash
# Run denseness suite and write notes/last-run-report.md
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR="$ROOT/notes"
REPORT="$OUT_DIR/last-run-report.md"
RAW="$OUT_DIR/.last-run-raw.txt"
mkdir -p "$OUT_DIR"

EXAMPLES=(
  examples/01-single-loop/main.aura
  examples/02-business-signal/main.aura
  examples/03-researcher-executor/main.aura
  examples/04-hot-strategy-heal/main.aura
  examples/05-long-run-denseness/main.aura
  examples/06-propose-edge-escape/main.aura
  examples/07-proposal-schema/main.aura
  examples/08-parse-proposal-wire/main.aura
  examples/10-long-n-stress/main.aura
  examples/11-arbitrated-multi/main.aura
  examples/12-parallel-yield/main.aura
  examples/13-multi-tenant-region/main.aura
  examples/14-long-n-100/main.aura
)

: >"$RAW"
pass=0
fail=0
rows=()

for ex in "${EXAMPLES[@]}"; do
  name=$(basename "$(dirname "$ex")")
  echo "======== $ex ========" | tee -a "$RAW"
  if ! out=$(./scripts/run-aura.sh "$ex" 2>&1); then
    echo "$out" | tee -a "$RAW"
    rows+=("| \`$name\` | runner-error | |")
    fail=$((fail + 1))
    continue
  fi
  echo "$out" | tee -a "$RAW" | tail -n 8
  result_line=$(echo "$out" | grep '^RESULT ' | tail -n 1 || true)
  if echo "$out" | grep -q '^PASS:'; then
    status=pass
    pass=$((pass + 1))
  else
    status=fail
    fail=$((fail + 1))
  fi
  if [[ -z "$result_line" ]]; then
    result_line="RESULT $status example=$name (no RESULT line)"
  fi
  rows+=("| \`$name\` | $status | \`$result_line\` |")
done

{
  echo "# Last denseness run"
  echo
  echo "- **When:** $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- **Host:** \`../aura-grok/build/aura\` (via run-aura.sh)"
  echo "- **Passed:** $pass / $((pass + fail))"
  echo "- **Failed:** $fail"
  echo
  echo "| Example | Status | RESULT |"
  echo "|---------|--------|--------|"
  for r in "${rows[@]}"; do echo "$r"; done
  echo
  echo "Full log: \`notes/.last-run-raw.txt\` (gitignored if desired)."
  echo
  if [[ "$fail" -eq 0 ]]; then
    echo "**Suite: ALL PASSED**"
  else
    echo "**Suite: HAS FAILURES**"
  fi
} >"$REPORT"

echo
echo "Wrote $REPORT"
[[ "$fail" -eq 0 ]]

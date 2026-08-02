#!/usr/bin/env bash
# Lightweight structure checks (no Aura binary required).
# Exit non-zero if probe conventions or suite wiring drift.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0

need_files=(
  README.md
  LICENSE
  notes/denseness-report.md
  notes/escape-log.md
  lib/aether-min.aura
  lib/aether-domain.aura
  lib/aether-propose.aura
  lib/aether-orch.aura
  lib/aether-region.aura
  lib/aether-mutate-policy.aura
  scripts/run-aura.sh
  scripts/run-all.sh
  scripts/report.sh
  examples/README.md
  examples/_template/main.aura
)

echo "== required files =="
for f in "${need_files[@]}"; do
  if [[ ! -e "$f" ]]; then
    echo "MISSING: $f"
    fail=1
  else
    echo "ok  $f"
  fi
done

echo
echo "== offline suite paths (run-all.sh) =="
mapfile -t suite < <(grep -E '^\s*examples/.+\.aura' scripts/run-all.sh | sed 's/^[[:space:]]*//' || true)
if [[ "${#suite[@]}" -lt 8 ]]; then
  echo "FAIL: expected many suite entries in run-all.sh, got ${#suite[@]}"
  fail=1
fi
for ex in "${suite[@]}"; do
  if [[ ! -f "$ex" ]]; then
    echo "MISSING suite file: $ex"
    fail=1
  else
    if ! grep -q 'RESULT ' "$ex"; then
      echo "WARN/FAIL: no RESULT line in $ex"
      fail=1
    else
      echo "ok  $ex"
    fi
  fi
done

echo
echo "== report.sh suite matches run-all =="
mapfile -t report_suite < <(grep -E '^\s*examples/.+\.aura' scripts/report.sh | sed 's/^[[:space:]]*//' || true)
if [[ "${#report_suite[@]}" -ne "${#suite[@]}" ]]; then
  echo "FAIL: report.sh has ${#report_suite[@]} examples, run-all has ${#suite[@]}"
  fail=1
else
  echo "ok  both have ${#suite[@]} examples"
fi

echo
if [[ "$fail" -ne 0 ]]; then
  echo "check-structure: FAILED"
  exit 1
fi
echo "check-structure: ALL PASSED (${#suite[@]} suite entries)"

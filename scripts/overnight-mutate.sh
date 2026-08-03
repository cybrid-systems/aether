#!/usr/bin/env bash
# Overnight / multi-minute continuous mutation harness (Aether issue #4).
#
# Loops examples/22-overnight-mutate under rate + budget limits.
# Default target is domain gate via the driver (sandbox-only promotion policy).
# Does not auto-mainline lib/aether-*.aura.
#
# Usage:
#   ./scripts/overnight-mutate.sh
#   AETHER_OVERNIGHT_MAX_MINUTES=3 AETHER_OVERNIGHT_MAX_PROPOSES=12 ./scripts/overnight-mutate.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MAX_MINUTES="${AETHER_OVERNIGHT_MAX_MINUTES:-480}"
MAX_PROPOSES="${AETHER_OVERNIGHT_MAX_PROPOSES:-200}"
ROUNDS="${AETHER_OVERNIGHT_ROUNDS:-8}"
SLEEP_SEC="${AETHER_OVERNIGHT_SLEEP_SEC:-15}"
DRIVER="${AETHER_OVERNIGHT_DRIVER:-examples/22-overnight-mutate/main.aura}"
ANOMALY_LOG="${AETHER_ANOMALY_LOG:-$ROOT/notes/aura-anomaly-log.md}"
RUN_LOG="${AETHER_OVERNIGHT_LOG:-$ROOT/notes/.overnight-run.log}"

export AETHER_OVERNIGHT_ROUNDS="$ROUNDS"

# Prefer live MiniMax when key available unless caller forces mode.
if [[ -z "${AETHER_LLM_PROPOSE:-}" ]]; then
  if [[ -f "${MINIMAX_KEY_FILE:-$HOME/code/keys/minimax}" ]] || [[ -n "${LLM_API_KEY:-}" ]]; then
    export AETHER_LLM_PROPOSE=live
  else
    export AETHER_LLM_PROPOSE=stub
  fi
fi

mkdir -p "$(dirname "$ANOMALY_LOG")"
: >>"$ANOMALY_LOG"
: >"$RUN_LOG"

start_ts=$(date +%s)
deadline=$((start_ts + MAX_MINUTES * 60))
invocations=0
pass_n=0
fail_n=0
crash_n=0

echo "overnight-mutate: start $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  max_minutes=$MAX_MINUTES max_proposes=$MAX_PROPOSES rounds/driver=$ROUNDS sleep=${SLEEP_SEC}s mode=${AETHER_LLM_PROPOSE}"
echo "  driver=$DRIVER"
echo "  anomaly_log=$ANOMALY_LOG"

append_anomaly() {
  local kind="$1"
  local detail="$2"
  {
    echo
    echo "## [$(date -u +%Y-%m-%dT%H:%M:%SZ)] $kind"
    echo "- Location: $DRIVER (overnight harness)"
    echo "- Detail: $detail"
    echo "- Host: AURA_BIN=${AURA_BIN:-default} mode=$AETHER_LLM_PROPOSE"
    echo "- Action: review for Aura issue if reproducible; do not count known host-residuals as denseness fail"
  } >>"$ANOMALY_LOG"
}

while true; do
  now=$(date +%s)
  if (( now >= deadline )); then
    echo "overnight-mutate: stop — wall-clock budget (${MAX_MINUTES}m)"
    break
  fi
  if (( invocations >= MAX_PROPOSES )); then
    echo "overnight-mutate: stop — propose/invocation budget ($MAX_PROPOSES)"
    break
  fi

  invocations=$((invocations + 1))
  echo "======== invocation $invocations / $MAX_PROPOSES ========" | tee -a "$RUN_LOG"
  set +e
  out=$(./scripts/run-aura.sh "$DRIVER" 2>&1)
  rc=$?
  set -e
  echo "$out" | tee -a "$RUN_LOG" | tail -n 12

  if (( rc != 0 )); then
    crash_n=$((crash_n + 1))
    append_anomaly "runner-nonzero-exit" "rc=$rc invocation=$invocations"
    echo "WARN: runner exit $rc (logged anomaly)"
  elif echo "$out" | grep -q '^PASS:'; then
    pass_n=$((pass_n + 1))
  else
    fail_n=$((fail_n + 1))
    append_anomaly "driver-FAIL-line" "invocation=$invocations (see run log)"
    echo "WARN: no PASS line"
  fi

  # Cooldown / rate limit (skip sleep on last if budget exhausted next iter)
  now=$(date +%s)
  if (( invocations < MAX_PROPOSES && now < deadline )); then
    sleep "$SLEEP_SEC"
  fi
done

end_ts=$(date +%s)
elapsed=$((end_ts - start_ts))
{
  echo
  echo "## [$(date -u +%Y-%m-%dT%H:%M:%SZ)] overnight session summary"
  echo "- Invocations: $invocations"
  echo "- PASS: $pass_n FAIL: $fail_n crash/runner: $crash_n"
  echo "- Elapsed_sec: $elapsed"
  echo "- Mode: $AETHER_LLM_PROPOSE"
  if (( crash_n == 0 && fail_n == 0 )); then
    echo "- Aura issues opened: none required (no new anomalies this session)"
  else
    echo "- Aura issues: review entries above; open when stable repro exists"
  fi
} >>"$ANOMALY_LOG"

echo
echo "overnight-mutate: done invocations=$invocations pass=$pass_n fail=$fail_n crash=$crash_n elapsed_sec=$elapsed"
echo "  log=$RUN_LOG anomaly=$ANOMALY_LOG"
# Exit 0 if at least one pass and no crashes (soft fail lines still exit 0 for long-run)
if (( crash_n > 0 )); then
  exit 2
fi
if (( pass_n == 0 )); then
  exit 1
fi
exit 0

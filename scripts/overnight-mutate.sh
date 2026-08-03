#!/usr/bin/env bash
# Overnight / multi-minute continuous mutation harness (Aether issue #4).
#
# Loops examples/22-overnight-mutate under rate + wall-clock budgets.
# Default target is domain gate via the driver (sandbox-only promotion policy).
# Does not auto-mainline lib/aether-*.aura.
#
# ## What "default budget" means (NOT MiniMax account quota)
#
# The harness only enforces *local* stop conditions:
#   1. wall-clock: AETHER_OVERNIGHT_MAX_MINUTES  (default 300 = 5h)
#   2. invocations: AETHER_OVERNIGHT_MAX_PROPOSES (default 60 process restarts)
#   3. cooldown:    AETHER_OVERNIGHT_SLEEP_SEC    (default 30s between invocations)
#
# It does NOT know your MiniMax plan token/RPM balance. If the account is
# rate-limited (429) or out of quota, llm:chat fails soft → rule fallback;
# the loop still burns wall-clock until one of the local caps hits.
#
# Tuned for a ~5h limited MiniMax session + short one-shot proposes
# (see README: ~4 live calls / invocation, each ~hundreds of tokens, no
# multi-turn history — 1M context is never filled).
#
# Usage:
#   ./scripts/overnight-mutate.sh
#   # short smoke:
#   AETHER_OVERNIGHT_MAX_MINUTES=3 AETHER_OVERNIGHT_MAX_PROPOSES=4 \
#     AETHER_OVERNIGHT_SLEEP_SEC=5 ./scripts/overnight-mutate.sh
#   # stricter burn:
#   AETHER_OVERNIGHT_MAX_MINUTES=120 AETHER_OVERNIGHT_MAX_PROPOSES=20 \
#     AETHER_OVERNIGHT_SLEEP_SEC=60 ./scripts/overnight-mutate.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Defaults aligned to a ~5h limited MiniMax session (not 8h unbounded overnight).
MAX_MINUTES="${AETHER_OVERNIGHT_MAX_MINUTES:-300}"
MAX_PROPOSES="${AETHER_OVERNIGHT_MAX_PROPOSES:-60}"
SLEEP_SEC="${AETHER_OVERNIGHT_SLEEP_SEC:-30}"
DRIVER="${AETHER_OVERNIGHT_DRIVER:-examples/22-overnight-mutate/main.aura}"
ANOMALY_LOG="${AETHER_ANOMALY_LOG:-$ROOT/notes/aura-anomaly-log.md}"
RUN_LOG="${AETHER_OVERNIGHT_LOG:-$ROOT/notes/.overnight-run.log}"

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
# Rough live-call estimate: driver does ~4 aether:propose live paths per run.
LIVE_CALLS_PER_INV=4
est_live_calls_max=$((MAX_PROPOSES * LIVE_CALLS_PER_INV))

echo "overnight-mutate: start $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  budget (local only — not MiniMax account quota):"
echo "    max_minutes=$MAX_MINUTES  max_invocations=$MAX_PROPOSES  sleep=${SLEEP_SEC}s"
echo "    est. live LLM calls upper bound ≈ $est_live_calls_max (4/invocation × max_invocations)"
echo "  context: each llm:chat is a fresh one-shot (system+user, ~hundreds tokens);"
echo "           no multi-turn history — 1M window is not accumulated across rounds"
echo "  mode=${AETHER_LLM_PROPOSE}  driver=$DRIVER"
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
    echo "overnight-mutate: stop — invocation budget ($MAX_PROPOSES)"
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

  # Soft detect rate-limit / quota signals in driver output
  if echo "$out" | grep -qiE 'rate-limit|429|quota|insufficient'; then
    append_anomaly "possible-provider-quota-or-rate-limit" "invocation=$invocations"
    echo "WARN: possible provider rate/quota signal — consider raising SLEEP or lowering MAX_PROPOSES"
  fi

  now=$(date +%s)
  if (( invocations < MAX_PROPOSES && now < deadline )); then
    sleep "$SLEEP_SEC"
  fi
done

end_ts=$(date +%s)
elapsed=$((end_ts - start_ts))
est_live=$((invocations * LIVE_CALLS_PER_INV))
{
  echo
  echo "## [$(date -u +%Y-%m-%dT%H:%M:%SZ)] overnight session summary"
  echo "- Invocations: $invocations (cap $MAX_PROPOSES)"
  echo "- Wall minutes budget: $MAX_MINUTES; elapsed_sec: $elapsed"
  echo "- PASS: $pass_n FAIL: $fail_n crash/runner: $crash_n"
  echo "- Est. live LLM calls this session: ~$est_live (one-shot, short prompts)"
  echo "- Mode: $AETHER_LLM_PROPOSE"
  if (( crash_n == 0 && fail_n == 0 )); then
    echo "- Aura issues opened: none required (no new anomalies this session)"
  else
    echo "- Aura issues: review entries above; open when stable repro exists"
  fi
} >>"$ANOMALY_LOG"

echo
echo "overnight-mutate: done invocations=$invocations pass=$pass_n fail=$fail_n crash=$crash_n elapsed_sec=$elapsed"
echo "  est_live_calls≈$est_live  log=$RUN_LOG anomaly=$ANOMALY_LOG"
if (( crash_n > 0 )); then
  exit 2
fi
if (( pass_n == 0 )); then
  exit 1
fi
exit 0

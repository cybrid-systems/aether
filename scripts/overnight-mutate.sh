#!/usr/bin/env bash
# Overnight / multi-minute continuous mutation harness (Aether issue #4).
#
# Loops examples/22-overnight-mutate under rate + clock-aligned budgets.
# Does not auto-mainline lib/aether-*.aura.
#
# ## MiniMax plan model (default schedule)
#
# Plan time is counted from local midnight (00:00); the useful high-quota
# window is the next 5 hours (00:00–05:00), then it resets again at the next
# 00:00 cycle.
#
# Typical overnight session (e.g. start ~22:50):
#   now ──► 00:00 (reset) ──► 05:00 (end of window)  STOP
#   residual ~1h before reset + full 5h peak after.
#
# Default schedule `minimax-0-5` sets the hard stop to the *next* 05:00 in
# AETHER_OVERNIGHT_TZ (default Asia/Shanghai). Secondary caps still apply:
#   - AETHER_OVERNIGHT_MAX_PROPOSES (default 120)
#   - AETHER_OVERNIGHT_SLEEP_SEC    (default 30)
#   - optional AETHER_OVERNIGHT_MAX_MINUTES as an *extra* hard ceiling
#
# Context: each llm:chat is a short one-shot (no multi-turn; 1M window unused).
#
# Usage:
#   ./scripts/overnight-mutate.sh
#   # short smoke (ignore clock window):
#   AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=3 \
#     AETHER_OVERNIGHT_MAX_PROPOSES=4 AETHER_OVERNIGHT_SLEEP_SEC=5 \
#     ./scripts/overnight-mutate.sh
#   # only the peak window (sleep until 00:00 if outside):
#   AETHER_OVERNIGHT_PEAK_ONLY=1 ./scripts/overnight-mutate.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Clock for MiniMax window (plan resets at 00:00 in this TZ).
export TZ="${AETHER_OVERNIGHT_TZ:-Asia/Shanghai}"

SCHEDULE="${AETHER_OVERNIGHT_SCHEDULE:-minimax-0-5}"
# Window: [RESET_HOUR, RESET_HOUR+WINDOW_HOURS) e.g. 00:00–05:00
RESET_HOUR="${AETHER_OVERNIGHT_RESET_HOUR:-0}"
WINDOW_HOURS="${AETHER_OVERNIGHT_WINDOW_HOURS:-5}"
PEAK_ONLY="${AETHER_OVERNIGHT_PEAK_ONLY:-0}"

# Secondary caps (invocations / rate). MAX_MINUTES is optional extra ceiling.
MAX_PROPOSES="${AETHER_OVERNIGHT_MAX_PROPOSES:-120}"
SLEEP_SEC="${AETHER_OVERNIGHT_SLEEP_SEC:-30}"
# Empty = no duration ceiling unless schedule=duration
MAX_MINUTES="${AETHER_OVERNIGHT_MAX_MINUTES:-}"

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

# ── clock helpers (GNU date; Linux) ─────────────────────────────────
# next local midnight (00:00 of the next calendar day if past midnight moment)
next_midnight_ts() {
  date -d "tomorrow 00:00:00" +%s
}

# next window end = next occurrence of (RESET_HOUR + WINDOW_HOURS):00
# e.g. RESET=0 WINDOW=5 → next 05:00
next_window_end_ts() {
  local end_h=$((RESET_HOUR + WINDOW_HOURS))
  if (( end_h >= 24 )); then
    end_h=$((end_h % 24))
  fi
  local now_h now_m
  now_h=$(date +%H)
  now_m=$(date +%M)
  # strip leading zeros for arithmetic
  now_h=$((10#$now_h))
  now_m=$((10#$now_m))
  if (( now_h < end_h || (now_h == end_h && now_m == 0) )); then
    # still before today's window end
    date -d "today ${end_h}:00:00" +%s
  else
    date -d "tomorrow ${end_h}:00:00" +%s
  fi
}

# Is "now" inside the peak window [RESET_HOUR, RESET_HOUR+WINDOW_HOURS)?
in_peak_window() {
  local now_h end_h
  now_h=$((10#$(date +%H)))
  end_h=$((RESET_HOUR + WINDOW_HOURS))
  if (( end_h > 24 )); then end_h=24; fi
  (( now_h >= RESET_HOUR && now_h < end_h ))
}

# Seconds until next peak window start (00:00 when RESET_HOUR=0)
secs_until_peak_start() {
  local now_h end_h
  now_h=$((10#$(date +%H)))
  end_h=$((RESET_HOUR + WINDOW_HOURS))
  if (( now_h >= RESET_HOUR && now_h < end_h )); then
    echo 0
    return
  fi
  # After peak: wait until tomorrow RESET_HOUR
  if (( now_h >= end_h )); then
    date -d "tomorrow ${RESET_HOUR}:00:00" +%s
  else
    # Before peak same day (RESET_HOUR > 0 case)
    date -d "today ${RESET_HOUR}:00:00" +%s
  fi | {
    read -r target
    local now
    now=$(date +%s)
    echo $(( target - now ))
  }
}

start_ts=$(date +%s)
deadline=0
stop_reason=""

case "$SCHEDULE" in
  minimax-0-5|minimax|clock)
    deadline=$(next_window_end_ts)
    stop_reason="clock window end ($(date -d "@$deadline" '+%Y-%m-%d %H:%M %Z'))"
    # Optional extra ceiling in minutes from start
    if [[ -n "$MAX_MINUTES" ]]; then
      local_cap=$((start_ts + MAX_MINUTES * 60))
      if (( local_cap < deadline )); then
        deadline=$local_cap
        stop_reason="MAX_MINUTES=${MAX_MINUTES} (earlier than clock window)"
      fi
    fi
    ;;
  duration|minutes)
    if [[ -z "$MAX_MINUTES" ]]; then
      MAX_MINUTES=300
    fi
    deadline=$((start_ts + MAX_MINUTES * 60))
    stop_reason="duration MAX_MINUTES=${MAX_MINUTES}"
    ;;
  *)
    echo "error: unknown AETHER_OVERNIGHT_SCHEDULE=$SCHEDULE (use minimax-0-5 or duration)" >&2
    exit 1
    ;;
esac

# Peak-only: sleep until window opens if outside 00:00–05:00
if [[ "$PEAK_ONLY" == "1" || "$PEAK_ONLY" == "true" ]]; then
  if ! in_peak_window; then
    wait_s=$(secs_until_peak_start)
    if (( wait_s > 0 )); then
      echo "overnight-mutate: PEAK_ONLY — outside ${RESET_HOUR}:00–$((RESET_HOUR + WINDOW_HOURS)):00; sleeping ${wait_s}s until peak"
      sleep "$wait_s"
      # recompute deadline after wait (should be today/tomorrow window end)
      start_ts=$(date +%s)
      if [[ "$SCHEDULE" == duration || "$SCHEDULE" == minutes ]]; then
        :
      else
        deadline=$(next_window_end_ts)
        stop_reason="clock window end ($(date -d "@$deadline" '+%Y-%m-%d %H:%M %Z'))"
      fi
    fi
  fi
fi

invocations=0
pass_n=0
fail_n=0
crash_n=0
LIVE_CALLS_PER_INV=4
est_live_calls_max=$((MAX_PROPOSES * LIVE_CALLS_PER_INV))

now_local=$(date '+%Y-%m-%d %H:%M:%S %Z')
next_reset_ts=$(next_midnight_ts)
# If still before today's midnight and past window, next reset is tonight 00:00
# next_midnight_ts is "tomorrow 00:00" which is correct for "next reset at 0:00"
# When hour is already 0-5, "reset already happened" at today's 00:00:
if in_peak_window; then
  reset_note="inside peak window (reset already at today's ${RESET_HOUR}:00)"
else
  reset_note="next plan reset ≈ $(date -d "@$next_reset_ts" '+%Y-%m-%d %H:%M %Z') (then peak until window end)"
fi

remain_to_deadline=$(( (deadline - start_ts) / 60 ))

echo "overnight-mutate: start $now_local"
echo "  schedule=$SCHEDULE  TZ=$TZ  plan window=${RESET_HOUR}:00–$((RESET_HOUR + WINDOW_HOURS)):00"
echo "  $reset_note"
echo "  hard stop: $stop_reason  (≈ ${remain_to_deadline} min from now)"
echo "  secondary: max_invocations=$MAX_PROPOSES  sleep=${SLEEP_SEC}s  peak_only=$PEAK_ONLY"
echo "  est. live LLM calls upper bound ≈ $est_live_calls_max (4/invocation × max_invocations)"
echo "  context: each llm:chat is a fresh short one-shot — does not fill 1M window"
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
    echo "- Host: AURA_BIN=${AURA_BIN:-default} mode=$AETHER_LLM_PROPOSE TZ=$TZ"
    echo "- Action: review for Aura issue if reproducible; do not count known host-residuals as denseness fail"
  } >>"$ANOMALY_LOG"
}

while true; do
  now=$(date +%s)
  if (( now >= deadline )); then
    echo "overnight-mutate: stop — $stop_reason"
    break
  fi
  if (( invocations >= MAX_PROPOSES )); then
    echo "overnight-mutate: stop — invocation budget ($MAX_PROPOSES)"
    break
  fi

  invocations=$((invocations + 1))
  rem_m=$(( (deadline - now) / 60 ))
  echo "======== invocation $invocations / $MAX_PROPOSES  (~${rem_m}m left to hard stop) ========" | tee -a "$RUN_LOG"
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

  if echo "$out" | grep -qiE 'rate-limit|429|quota|insufficient'; then
    append_anomaly "possible-provider-quota-or-rate-limit" "invocation=$invocations"
    echo "WARN: possible provider rate/quota signal — raise SLEEP or lower MAX_PROPOSES"
  fi

  now=$(date +%s)
  if (( invocations < MAX_PROPOSES && now < deadline )); then
    # don't sleep past deadline
    left=$((deadline - now))
    if (( left <= 0 )); then
      break
    fi
    if (( SLEEP_SEC < left )); then
      sleep "$SLEEP_SEC"
    else
      sleep "$left"
    fi
  fi
done

end_ts=$(date +%s)
elapsed=$((end_ts - start_ts))
est_live=$((invocations * LIVE_CALLS_PER_INV))
{
  echo
  echo "## [$(date -u +%Y-%m-%dT%H:%M:%SZ)] overnight session summary"
  echo "- Schedule: $SCHEDULE TZ=$TZ window=${RESET_HOUR}:00-$((RESET_HOUR + WINDOW_HOURS)):00"
  echo "- Hard stop reason: $stop_reason"
  echo "- Invocations: $invocations (cap $MAX_PROPOSES)"
  echo "- Elapsed_sec: $elapsed"
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

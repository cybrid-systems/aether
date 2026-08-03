#!/usr/bin/env bash
# Overnight multi-agent mutation harness (Aether issue #4).
#
# Loops examples/22-overnight-mutate under clock-aligned budgets.
# Logs are issue-oriented: session header, per-invocation files, anomaly
# entries with repro recipes and log excerpts for Aura/Aether issues.
#
# Default schedule: hard stop at next 08:00 Asia/Shanghai
#   now ──► 00:00 reset ──► 08:00 STOP
#
# Usage:
#   ./scripts/overnight-mutate.sh
#   AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=3 \
#     AETHER_OVERNIGHT_MAX_PROPOSES=2 AETHER_OVERNIGHT_SLEEP_SEC=5 \
#     ./scripts/overnight-mutate.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export TZ="${AETHER_OVERNIGHT_TZ:-Asia/Shanghai}"

SCHEDULE="${AETHER_OVERNIGHT_SCHEDULE:-minimax-0-5}"
RESET_HOUR="${AETHER_OVERNIGHT_RESET_HOUR:-0}"
WINDOW_HOURS="${AETHER_OVERNIGHT_WINDOW_HOURS:-8}"
PEAK_ONLY="${AETHER_OVERNIGHT_PEAK_ONLY:-0}"
MAX_PROPOSES="${AETHER_OVERNIGHT_MAX_PROPOSES:-80}"
SLEEP_SEC="${AETHER_OVERNIGHT_SLEEP_SEC:-20}"
MAX_MINUTES="${AETHER_OVERNIGHT_MAX_MINUTES:-}"
export AETHER_OVERNIGHT_AGENTS="${AETHER_OVERNIGHT_AGENTS:-6}"

DRIVER="${AETHER_OVERNIGHT_DRIVER:-examples/22-overnight-mutate/main.aura}"
ANOMALY_LOG="${AETHER_ANOMALY_LOG:-$ROOT/notes/aura-anomaly-log.md}"
RUN_LOG="${AETHER_OVERNIGHT_LOG:-$ROOT/notes/.overnight-run.log}"
INV_DIR="${AETHER_OVERNIGHT_INV_DIR:-$ROOT/notes/overnight-invocations}"
SESSION_ID="${AETHER_OVERNIGHT_SESSION_ID:-$(date +%Y%m%dT%H%M%S%z)}"

if [[ -z "${AETHER_LLM_PROPOSE:-}" ]]; then
  if [[ -f "${MINIMAX_KEY_FILE:-$HOME/code/keys/minimax}" ]] || [[ -n "${LLM_API_KEY:-}" ]]; then
    export AETHER_LLM_PROPOSE=live
  else
    export AETHER_LLM_PROPOSE=stub
  fi
fi

AURA_BIN="${AURA_BIN:-$ROOT/../aura-grok/build/aura}"
AETHER_SHA="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
AURA_SHA="unknown"
if [[ -d "$ROOT/../aura-grok/.git" ]]; then
  AURA_SHA="$(git -C "$ROOT/../aura-grok" rev-parse --short HEAD 2>/dev/null || echo unknown)"
fi

mkdir -p "$(dirname "$ANOMALY_LOG")" "$INV_DIR"
: >>"$ANOMALY_LOG"
: >"$RUN_LOG"

# ── clock helpers ─────────────────────────────────────────────
next_midnight_ts() { date -d "tomorrow 00:00:00" +%s; }

next_window_end_ts() {
  local end_h=$((RESET_HOUR + WINDOW_HOURS))
  if (( end_h >= 24 )); then end_h=$((end_h % 24)); fi
  local now_h now_m
  now_h=$((10#$(date +%H)))
  now_m=$((10#$(date +%M)))
  if (( now_h < end_h || (now_h == end_h && now_m == 0) )); then
    date -d "today ${end_h}:00:00" +%s
  else
    date -d "tomorrow ${end_h}:00:00" +%s
  fi
}

in_peak_window() {
  local now_h end_h
  now_h=$((10#$(date +%H)))
  end_h=$((RESET_HOUR + WINDOW_HOURS))
  if (( end_h > 24 )); then end_h=24; fi
  (( now_h >= RESET_HOUR && now_h < end_h ))
}

secs_until_peak_start() {
  local now_h end_h target now
  now_h=$((10#$(date +%H)))
  end_h=$((RESET_HOUR + WINDOW_HOURS))
  if (( now_h >= RESET_HOUR && now_h < end_h )); then
    echo 0
    return
  fi
  if (( now_h >= end_h )); then
    target=$(date -d "tomorrow ${RESET_HOUR}:00:00" +%s)
  else
    target=$(date -d "today ${RESET_HOUR}:00:00" +%s)
  fi
  now=$(date +%s)
  echo $(( target - now ))
}

# Extract last matching lines for issue snippets
excerpt_match() {
  local text="$1" pattern="$2" n="${3:-20}"
  echo "$text" | grep -E "$pattern" | tail -n "$n" || true
}

start_ts=$(date +%s)
deadline=0
stop_reason=""

case "$SCHEDULE" in
  minimax-0-5|minimax|clock)
    deadline=$(next_window_end_ts)
    stop_reason="clock window end ($(date -d "@$deadline" '+%Y-%m-%d %H:%M %Z'))"
    if [[ -n "$MAX_MINUTES" ]]; then
      local_cap=$((start_ts + MAX_MINUTES * 60))
      if (( local_cap < deadline )); then
        deadline=$local_cap
        stop_reason="MAX_MINUTES=${MAX_MINUTES} (earlier than clock window)"
      fi
    fi
    ;;
  duration|minutes)
    if [[ -z "$MAX_MINUTES" ]]; then MAX_MINUTES=300; fi
    deadline=$((start_ts + MAX_MINUTES * 60))
    stop_reason="duration MAX_MINUTES=${MAX_MINUTES}"
    ;;
  *)
    echo "error: unknown AETHER_OVERNIGHT_SCHEDULE=$SCHEDULE" >&2
    exit 1
    ;;
esac

if [[ "$PEAK_ONLY" == "1" || "$PEAK_ONLY" == "true" ]]; then
  if ! in_peak_window; then
    wait_s=$(secs_until_peak_start)
    if (( wait_s > 0 )); then
      echo "overnight-mutate: PEAK_ONLY — sleeping ${wait_s}s until ${RESET_HOUR}:00"
      sleep "$wait_s"
      start_ts=$(date +%s)
      if [[ "$SCHEDULE" != duration && "$SCHEDULE" != minutes ]]; then
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
quota_n=0
LIVE_CALLS_PER_INV=36
est_live_calls_max=$((MAX_PROPOSES * LIVE_CALLS_PER_INV))
remain_to_deadline=$(( (deadline - start_ts) / 60 ))
now_local=$(date '+%Y-%m-%d %H:%M:%S %Z')
next_reset_ts=$(next_midnight_ts)

if in_peak_window; then
  reset_note="inside peak window (reset already at today's ${RESET_HOUR}:00)"
else
  reset_note="next plan reset ≈ $(date -d "@$next_reset_ts" '+%Y-%m-%d %H:%M %Z')"
fi

# Shared repro env (for anomaly → issue paste)
repro_env_block() {
  cat <<EOF
\`\`\`bash
cd $ROOT
export TZ=$TZ
export AETHER_LLM_PROPOSE=$AETHER_LLM_PROPOSE
export AETHER_OVERNIGHT_AGENTS=$AETHER_OVERNIGHT_AGENTS
export AURA_BIN=$AURA_BIN
# optional: source ./scripts/env-minimax.sh
./scripts/run-aura.sh $DRIVER
# or full harness:
# AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=10 \\
#   AETHER_OVERNIGHT_MAX_PROPOSES=3 ./scripts/overnight-mutate.sh
\`\`\`
EOF
}

session_header() {
  cat <<EOF
================================================================================
OVERNIGHT SESSION
  session_id:     $SESSION_ID
  started_local:  $now_local
  started_utc:    $(date -u +%Y-%m-%dT%H:%M:%SZ)
  aether_sha:     $AETHER_SHA
  aura_sha:       $AURA_SHA
  aura_bin:       $AURA_BIN
  driver:         $DRIVER
  schedule:       $SCHEDULE  TZ=$TZ  window=${RESET_HOUR}:00–$((RESET_HOUR + WINDOW_HOURS)):00
  reset_note:     $reset_note
  hard_stop:      $stop_reason  (~${remain_to_deadline}m)
  max_invocations:$MAX_PROPOSES  sleep=${SLEEP_SEC}s  peak_only=$PEAK_ONLY  agents=$AETHER_OVERNIGHT_AGENTS
  mode:           $AETHER_LLM_PROPOSE
  pressure:       6 agents × 6 waves ≈ ${LIVE_CALLS_PER_INV} LLM calls/inv (live)
  est_live_max:   $est_live_calls_max
  logs:
    run_log:      $RUN_LOG
    anomaly_log:  $ANOMALY_LOG
    inv_dir:      $INV_DIR
  issue_help:     see notes/aura-anomaly-log.md (template + how to file)
================================================================================
EOF
}

append_anomaly() {
  local kind="$1"
  local severity="$2"   # crash | fail | quota | warn
  local inv="$3"
  local inv_file="$4"
  local detail="$5"
  local out_excerpt="$6"
  local result_line="$7"
  local host_hints="$8"

  {
    echo
    echo "## [${SESSION_ID}] $(date -u +%Y-%m-%dT%H:%M:%SZ) \`$kind\`"
    echo
    echo "| Field | Value |"
    echo "|-------|-------|"
    echo "| Severity | \`$severity\` |"
    echo "| Session | \`$SESSION_ID\` |"
    echo "| Invocation | \`$inv\` / \`$MAX_PROPOSES\` |"
    echo "| Driver | \`$DRIVER\` |"
    echo "| Mode | \`$AETHER_LLM_PROPOSE\` |"
    echo "| Fanout / agents | multi-agent stress (\`$AETHER_OVERNIGHT_AGENTS\`) |"
    echo "| Aether SHA | \`$AETHER_SHA\` |"
    echo "| Aura SHA | \`$AURA_SHA\` |"
    echo "| AURA_BIN | \`$AURA_BIN\` |"
    echo "| TZ | \`$TZ\` |"
    echo "| Inv log | \`$inv_file\` |"
    echo "| RESULT | \`${result_line:-"(none)"}\` |"
    echo
    echo "### Detail"
    echo
    echo "$detail"
    echo
    if [[ -n "$host_hints" ]]; then
      echo "### Host residual hints"
      echo
      echo "$host_hints"
      echo
    fi
    echo "### Log excerpt"
    echo
    echo '```'
    echo "$out_excerpt"
    echo '```'
    echo
    echo "### Repro (paste into Aura/Aether issue)"
    echo
    repro_env_block
    echo
    echo "### Suggested issue title"
    echo
    echo "> overnight \`$kind\` inv=$inv aether=$AETHER_SHA aura=$AURA_SHA"
    echo
    echo "### Action"
    echo
    echo "- [ ] Reproduce once more with the command above"
    echo "- [ ] If stable host crash / free-var / orch anomaly → open Aura issue"
    echo "- [ ] If denseness/driver only → keep in Aether; do not count known [host-residuals](host-residuals.md) as denseness fail"
    echo "- [ ] Link issue URL here when opened: _pending_"
  } >>"$ANOMALY_LOG"
}

classify_host_hints() {
  local text="$1"
  local hints=""
  if echo "$text" | grep -qi 'eval_flat: unsupported node type'; then
    hints+="- \`eval_flat: unsupported node type\` — known host residual class; check host-residuals.md / multi-bind / free-var after rebind"$'\n'
  fi
  if echo "$text" | grep -qi 'unbound variable'; then
    hints+="- unbound variable after rebind — free-var / packaging residual"$'\n'
  fi
  if echo "$text" | grep -qiE 'fiber|parallel-yield|orch:'; then
    hints+="- orch/fiber path — dual-mode fanout residual; note fanout mode from WAVE lines"$'\n'
  fi
  if echo "$text" | grep -qiE 'rate-limit|429|quota|insufficient'; then
    hints+="- provider rate/quota — not an Aura denseness failure; raise SLEEP or lower MAX_PROPOSES"$'\n'
  fi
  if echo "$text" | grep -qi 'schema-invalid\|refuse'; then
    hints+="- schema refuse — may be good denseness behavior unless unexpected on stub path"$'\n'
  fi
  echo "$hints"
}

session_header | tee -a "$RUN_LOG"

# Also stamp anomaly log with session open
{
  echo
  echo "## Session open \`$SESSION_ID\` ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
  echo
  echo "- Aether \`$AETHER_SHA\` / Aura \`$AURA_SHA\`"
  echo "- Mode \`$AETHER_LLM_PROPOSE\` hard_stop: $stop_reason"
  echo "- Inv dir: \`$INV_DIR\` run log: \`$RUN_LOG\`"
} >>"$ANOMALY_LOG"

while true; do
  now=$(date +%s)
  if (( now >= deadline )); then
    echo "overnight-mutate: stop — $stop_reason" | tee -a "$RUN_LOG"
    break
  fi
  if (( invocations >= MAX_PROPOSES )); then
    echo "overnight-mutate: stop — invocation budget ($MAX_PROPOSES)" | tee -a "$RUN_LOG"
    break
  fi

  invocations=$((invocations + 1))
  rem_m=$(( (deadline - now) / 60 ))
  inv_tag=$(printf '%s-inv%04d' "$SESSION_ID" "$invocations")
  inv_file="$INV_DIR/${inv_tag}.log"
  inv_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  {
    echo "======== INVOCATION $invocations / $MAX_PROPOSES  session=$SESSION_ID  utc=$inv_ts  ~${rem_m}m left ========"
    echo "AETHER_SHA=$AETHER_SHA AURA_SHA=$AURA_SHA MODE=$AETHER_LLM_PROPOSE AGENTS=$AETHER_OVERNIGHT_AGENTS"
  } | tee -a "$RUN_LOG"

  set +e
  out=$(./scripts/run-aura.sh "$DRIVER" 2>&1)
  rc=$?
  set -e

  # Full per-invocation log (issue attachment)
  {
    echo "# overnight invocation $invocations"
    echo "session_id=$SESSION_ID"
    echo "utc=$inv_ts"
    echo "rc=$rc"
    echo "aether_sha=$AETHER_SHA"
    echo "aura_sha=$AURA_SHA"
    echo "mode=$AETHER_LLM_PROPOSE"
    echo "driver=$DRIVER"
    echo "aura_bin=$AURA_BIN"
    echo "---- stdout+stderr ----"
    echo "$out"
  } >"$inv_file"

  # Tail to console + run log
  echo "$out" | tee -a "$RUN_LOG" | tail -n 20

  result_line=$(echo "$out" | grep '^RESULT ' | tail -n 1 || true)
  wave_lines=$(echo "$out" | grep -E '^WAVE |^W[0-9] ' | tail -n 12 || true)
  error_lines=$(echo "$out" | grep -iE 'error:|internal error|unbound|panic|segfault|FATAL' | tail -n 15 || true)
  host_hints=$(classify_host_hints "$out")

  status="unknown"
  if (( rc != 0 )); then
    status="crash"
    crash_n=$((crash_n + 1))
    excerpt=$(printf '%s\n%s\n%s' "$error_lines" "$wave_lines" "$(echo "$out" | tail -n 40)")
    append_anomaly "runner-nonzero-exit" "crash" "$invocations" "$inv_file" \
      "run-aura exit rc=$rc (host crash / panic / nonzero). Full log: \`$inv_file\`." \
      "$excerpt" "$result_line" "$host_hints"
    echo "WARN: CRASH rc=$rc → anomaly logged (inv log: $inv_file)" | tee -a "$RUN_LOG"
  elif echo "$out" | grep -q '^PASS:'; then
    status="pass"
    pass_n=$((pass_n + 1))
    echo "OK: PASS inv=$invocations result=${result_line:-"(no RESULT)"}" | tee -a "$RUN_LOG"
  else
    status="fail"
    fail_n=$((fail_n + 1))
    excerpt=$(printf '%s\n%s\n%s' "$error_lines" "$wave_lines" "$(echo "$out" | tail -n 50)")
    append_anomaly "driver-FAIL" "fail" "$invocations" "$inv_file" \
      "Driver finished without PASS line (rc=0). RESULT=\`${result_line:-none}\`. Full log: \`$inv_file\`." \
      "$excerpt" "$result_line" "$host_hints"
    echo "WARN: FAIL (no PASS) → anomaly logged (inv log: $inv_file)" | tee -a "$RUN_LOG"
  fi

  if echo "$out" | grep -qiE 'rate-limit|429|quota|insufficient'; then
    quota_n=$((quota_n + 1))
    excerpt=$(echo "$out" | grep -iE 'rate-limit|429|quota|insufficient' | tail -n 10)
    append_anomaly "provider-quota-or-rate-limit" "quota" "$invocations" "$inv_file" \
      "Provider rate/quota signal in driver output (not denseness core)." \
      "$excerpt" "$result_line" "$(classify_host_hints "$out")"
    echo "WARN: provider quota/rate signal (inv=$invocations)" | tee -a "$RUN_LOG"
  fi

  # Machine line for grepping run log
  echo "INV_STATUS session=$SESSION_ID inv=$invocations status=$status rc=$rc result=${result_line// /_}" | tee -a "$RUN_LOG"

  now=$(date +%s)
  if (( invocations < MAX_PROPOSES && now < deadline )); then
    left=$((deadline - now))
    if (( left <= 0 )); then break; fi
    if (( SLEEP_SEC < left )); then sleep "$SLEEP_SEC"; else sleep "$left"; fi
  fi
done

end_ts=$(date +%s)
elapsed=$((end_ts - start_ts))
est_live=$((invocations * LIVE_CALLS_PER_INV))

{
  echo
  echo "## Session close \`$SESSION_ID\` ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
  echo
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Invocations | $invocations / $MAX_PROPOSES |"
  echo "| PASS | $pass_n |"
  echo "| FAIL | $fail_n |"
  echo "| CRASH | $crash_n |"
  echo "| Quota signals | $quota_n |"
  echo "| Elapsed_sec | $elapsed |"
  echo "| Est live LLM calls | ~$est_live |"
  echo "| Mode | $AETHER_LLM_PROPOSE |"
  echo "| Hard stop | $stop_reason |"
  echo "| Aether / Aura | \`$AETHER_SHA\` / \`$AURA_SHA\` |"
  echo "| Run log | \`$RUN_LOG\` |"
  echo "| Inv dir | \`$INV_DIR\` |"
  echo
  if (( crash_n == 0 && fail_n == 0 )); then
    echo "**No driver FAIL/CRASH this session** — no Aura issue required unless quota-only notes above."
  else
    echo "**Action:** open issues from anomaly entries above (each has repro + excerpt)."
    echo "Prefer one Aura issue per stable host symptom; attach \`notes/overnight-invocations/*\` files."
  fi
} >>"$ANOMALY_LOG"

{
  echo
  echo "================================================================================"
  echo "OVERNIGHT DONE session=$SESSION_ID"
  echo "  inv=$invocations pass=$pass_n fail=$fail_n crash=$crash_n quota=$quota_n elapsed_sec=$elapsed"
  echo "  est_live_calls≈$est_live"
  echo "  run_log=$RUN_LOG"
  echo "  anomaly_log=$ANOMALY_LOG"
  echo "  inv_dir=$INV_DIR"
  echo "  tip: grep INV_STATUS $RUN_LOG | tail"
  echo "  tip: ls $INV_DIR | tail"
  echo "================================================================================"
} | tee -a "$RUN_LOG"

if (( crash_n > 0 )); then exit 2; fi
if (( pass_n == 0 )); then exit 1; fi
exit 0

# Aura anomaly log (overnight / long-run mining)

Overnight harness appends **session open/close** and **per-anomaly** entries here.
Use them to open [Aura issues](https://github.com/cybrid-systems/aura/issues) or Aether
follow-ups when symptoms are stable.

Do **not** re-log known packaging residuals already in
[host-residuals.md](host-residuals.md) as denseness failures.

---

## How to file an issue from logs

1. Open the anomaly entry under **Sessions** (table + excerpt + repro).
2. Open the per-invocation file: `notes/overnight-invocations/<session>-invNNNN.log`.
3. Grep machine lines:
   ```bash
   grep -E '^(WAVE |RESULT |DIAG |LOG_|INV_STATUS|error:)' notes/overnight-invocations/* | tail -50
   grep INV_STATUS notes/.overnight-run.log | tail -20
   ```
4. Paste into the issue:
   - **Title** from “Suggested issue title”
   - **Repro** bash block (already in anomaly entry)
   - **WAVE / RESULT / DIAG** lines
   - Attach the `invNNNN.log` file if large
5. Classify:
   | Symptom | Where to file |
   |---------|----------------|
   | `eval_flat`, unbound after rebind, fiber/orch panic | **Aura** host residual |
   | schema refuse / rollback on intentional poison | usually **OK denseness** |
   | provider 429 / quota | **not Aura** — rate/budget |
   | driver FAIL without host error | **Aether** denseness/driver |

---

## Template (manual)

```
## [YYYY-MM-DDThh:mm:ssZ] Short title
- Severity: crash | fail | quota | warn
- Location: example / harness inv=
- Detail: what happened
- RESULT: ...
- WAVE: ...
- Repro: (command + env)
- Host: aura_sha / aether_sha / AURA_BIN
- Action: Aura issue link or “needs more runs”
```

---

## Sessions

Harness appends below via `scripts/overnight-mutate.sh`.

## Session open `20260803T230901+0800` (2026-08-03T15:09:01Z)

- Aether `af0cb85` / Aura `e94d3da2`
- Mode `stub` hard_stop: duration MAX_MINUTES=1
- Inv dir: `/home/dev/code/grok-dev/aether/notes/overnight-invocations` run log: `/home/dev/code/grok-dev/aether/notes/.overnight-run.log`

## Session close `20260803T230901+0800` (2026-08-03T15:09:04Z)

| Metric | Value |
|--------|-------|
| Invocations | 1 / 1 |
| PASS | 1 |
| FAIL | 0 |
| CRASH | 0 |
| Quota signals | 0 |
| Elapsed_sec | 3 |
| Est live LLM calls | ~36 |
| Mode | stub |
| Hard stop | duration MAX_MINUTES=1 |
| Aether / Aura | `af0cb85` / `e94d3da2` |
| Run log | `/home/dev/code/grok-dev/aether/notes/.overnight-run.log` |
| Inv dir | `/home/dev/code/grok-dev/aether/notes/overnight-invocations` |

**No driver FAIL/CRASH this session** — no Aura issue required unless quota-only notes above.

## Session open `20260803T232512+0800` (2026-08-03T15:25:12Z)

- Aether `ed20261` / Aura `ac4de9a2`
- Mode `stub` hard_stop: duration MAX_MINUTES=1
- Inv dir: `/home/dev/code/grok-dev/aether/notes/overnight-invocations` run log: `/home/dev/code/grok-dev/aether/notes/.overnight-run.log`

## Session open `20260803T232641+0800` (2026-08-03T15:26:41Z)

- Aether `a10b640` / Aura `ac4de9a2`
- Mode `live` hard_stop: clock window end (2026-08-04 08:00 CST)
- Inv dir: `/home/dev/code/grok-dev/aether/notes/overnight-invocations` run log: `/home/dev/code/grok-dev/aether/notes/.overnight-run.log`

## [20260803T232641+0800] 2026-08-03T15:46:00Z `driver-FAIL`

| Field | Value |
|-------|-------|
| Severity | `fail` |
| Session | `20260803T232641+0800` |
| Invocation | `1` / `9999` |
| Driver | `examples/22-overnight-mutate/main.aura` |
| Mode | `live` |
| Fanout / agents | multi-agent stress (`60`) |
| Aether SHA | `a10b640` |
| Aura SHA | `ac4de9a2` |
| AURA_BIN | `/home/dev/code/grok-dev/aether/../aura-grok/build/aura` |
| TZ | `Asia/Shanghai` |
| Inv log | `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260803T232641+0800-inv0001.log` |
| RESULT | `RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=0 refuses=7 escapes=0 mode=sequential-yield live=#t` |

### Detail

Driver finished without PASS line (rc=0). agents=60 RESULT=`RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=0 refuses=7 escapes=0 mode=sequential-yield live=#t`. Full log: `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260803T232641+0800-inv0001.log`.

### Host residual hints

- orch/fiber path — dual-mode fanout residual; note fanout mode from WAVE lines
- schema refuse — may be good denseness behavior unless unexpected on stub path

### Log excerpt

```
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
Faulting IP: _ZSt12construct_atIN4aura3astW4auraW4coreW3ast7NodeTagEJRKS5_EQaant20is_unbounded_array_vIT_ErqXgsnwcvPvLi0E_S8_pispcl7declvalIT0_EEEEEPS8_SB_DpOSA_+64 in /home/dev/code/grok-dev/aether/../aura-grok/build/aura
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
Faulting IP: _ZSt12construct_atIN4aura3astW4auraW4coreW3ast7NodeTagEJRKS5_EQaant20is_unbounded_array_vIT_ErqXgsnwcvPvLi0E_S8_pispcl7declvalIT0_EEEEEPS8_SB_DpOSA_+64 in /home/dev/code/grok-dev/aether/../aura-grok/build/aura
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
WAVE id=4 kind=heal agents=60 mode=parallel-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
W0 kind=stress mode=sequential-yield n=60 esc+240 decision=refuse fails=7
WAVE id=0 kind=stress agents=60 mode=sequential-yield n=60 yields=120 esc_delta=240 decision=refuse fails=7 picked=#f
W0 kind=stress mode=sequential-yield n=60 esc+0 decision=refuse fails=7
WAVE id=0 kind=stress agents=60 mode=sequential-yield n=60 yields=120 esc_delta=0 decision=refuse fails=7 picked=("skip" "" "" "no-safe-candidate" "arbiter")
WAVE id=1 kind=healthy agents=60 mode=parallel-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=2 kind=stress agents=60 mode=parallel-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3 kind=poison-mix agents=60 mode=sequential-yield n=60 esc_delta=0 decision= picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3b kind=poison-force decision= fails=7
WAVE id=4 kind=heal agents=60 mode=sequential-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
load_module_file: cannot resolve ''
W0 kind=stress mode=sequential-yield n=60 esc+0 decision=refuse fails=7
WAVE id=0 kind=stress agents=60 mode=sequential-yield n=60 yields=120 esc_delta=0 decision=refuse fails=7 picked=("skip" "" "" "no-safe-candidate" "arbiter")
WAVE id=1 kind=healthy agents=60 mode=parallel-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=2 kind=stress agents=60 mode=parallel-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3 kind=poison-mix agents=60 mode=sequential-yield n=60 esc_delta=0 decision= picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3b kind=poison-force decision= fails=7
WAVE id=4 kind=heal agents=60 mode=sequential-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
summary commits=0 skips=0 rollbacks=0 refuses=7 anomalies=0 fan-rounds=6 total-props=360 agents=60 fanout-mode=sequential-yield
stats (("" . 0) ("commits" . 0) ("rollbacks" . 0) ("verify-fail" . 0) ("observe-calls" . 0) ("decide-mutate" . 0) ("decide-skip" . 0) ("escapes" . 0))
final-batch=(3 7)
FAIL: overnight multi-agent fanout stress
RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=0 refuses=7 escapes=0 mode=sequential-yield live=#t
DIAG batch=(3 7) stats=(("" . 0) ("commits" . 0) ("rollbacks" . 0) ("verify-fail" . 0) ("observe-calls" . 0) ("decide-mutate" . 0) ("decide-skip" . 0) ("escapes" . 0))
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
JOB_EXIT job=16 rc=0
```

### Repro (paste into Aura/Aether issue)

```bash
cd /home/dev/code/grok-dev/aether
export TZ=Asia/Shanghai
export AETHER_LLM_PROPOSE=live
export AETHER_OVERNIGHT_AGENTS=60
export AURA_BIN=/home/dev/code/grok-dev/aether/../aura-grok/build/aura
# optional: source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# or full harness:
# AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=10 \
#   AETHER_OVERNIGHT_MAX_PROPOSES=3 ./scripts/overnight-mutate.sh
```

### Suggested issue title

> overnight `driver-FAIL` inv=1 aether=a10b640 aura=ac4de9a2

### Action

- [ ] Reproduce once more with the command above
- [ ] If stable host crash / free-var / orch anomaly → open Aura issue
- [ ] If denseness/driver only → keep in Aether; do not count known [host-residuals](host-residuals.md) as denseness fail
- [ ] Link issue URL here when opened: _pending_

## [20260803T232641+0800] 2026-08-03T15:46:00Z `provider-or-llm-pressure`

| Field | Value |
|-------|-------|
| Severity | `quota` |
| Session | `20260803T232641+0800` |
| Invocation | `1` / `9999` |
| Driver | `examples/22-overnight-mutate/main.aura` |
| Mode | `live` |
| Fanout / agents | multi-agent stress (`60`) |
| Aether SHA | `a10b640` |
| Aura SHA | `ac4de9a2` |
| AURA_BIN | `/home/dev/code/grok-dev/aether/../aura-grok/build/aura` |
| TZ | `Asia/Shanghai` |
| Inv log | `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260803T232641+0800-inv0001.log` |
| RESULT | `RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=0 refuses=7 escapes=0 mode=sequential-yield live=#t` |

### Detail

LLM/provider pressure at agents=60 (rate-limit/quota/fallback/low escapes). Backing off.

### Host residual hints

- orch/fiber path — dual-mode fanout residual; note fanout mode from WAVE lines
- provider rate/quota — not an Aura denseness failure; raise SLEEP or lower MAX_PROPOSES

### Log excerpt

```
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
```

### Repro (paste into Aura/Aether issue)

```bash
cd /home/dev/code/grok-dev/aether
export TZ=Asia/Shanghai
export AETHER_LLM_PROPOSE=live
export AETHER_OVERNIGHT_AGENTS=60
export AURA_BIN=/home/dev/code/grok-dev/aether/../aura-grok/build/aura
# optional: source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# or full harness:
# AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=10 \
#   AETHER_OVERNIGHT_MAX_PROPOSES=3 ./scripts/overnight-mutate.sh
```

### Suggested issue title

> overnight `provider-or-llm-pressure` inv=1 aether=a10b640 aura=ac4de9a2

### Action

- [ ] Reproduce once more with the command above
- [ ] If stable host crash / free-var / orch anomaly → open Aura issue
- [ ] If denseness/driver only → keep in Aether; do not count known [host-residuals](host-residuals.md) as denseness fail
- [ ] Link issue URL here when opened: _pending_

## Session open `20260804T071958+0800` (2026-08-03T23:19:58Z)

- Aether `a10b640` / Aura `aebb9a41`
- Mode `stub` hard_stop: duration MAX_MINUTES=1
- Inv dir: `/home/dev/code/grok-dev/aether/notes/overnight-invocations` run log: `/home/dev/code/grok-dev/aether/notes/.overnight-run.log`

## Session open `20260804T214445+0800` (2026-08-04T13:44:45Z)

- Aether `e08ea52` / Aura `ecea342f`
- Mode `live` hard_stop: clock window end (2026-08-05 08:00 CST)
- Inv dir: `/home/dev/code/grok-dev/aether/notes/overnight-invocations` run log: `/home/dev/code/grok-dev/aether/notes/.overnight-run.log`

## [20260804T214445+0800] 2026-08-04T13:51:45Z `driver-FAIL`

| Field | Value |
|-------|-------|
| Severity | `fail` |
| Session | `20260804T214445+0800` |
| Invocation | `1` / `9999` |
| Driver | `examples/22-overnight-mutate/main.aura` |
| Mode | `live` |
| Fanout / agents | multi-agent stress (`60`) |
| Aether SHA | `e08ea52` |
| Aura SHA | `ecea342f` |
| AURA_BIN | `/home/dev/code/grok-dev/aether/../aura-grok/build/aura` |
| TZ | `Asia/Shanghai` |
| Inv log | `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260804T214445+0800-inv0001.log` |
| RESULT | `RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=1 refuses=6 escapes=570 mode=sequential-yield live=#t` |

### Detail

Driver finished without PASS line (rc=0). agents=60 RESULT=`RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=1 refuses=6 escapes=570 mode=sequential-yield live=#t`. Full log: `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260804T214445+0800-inv0001.log`.

### Log excerpt

```
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
WAVE id=3 kind=poison-mix agents=60 mode=sequential-yield n=60 esc_delta=0 decision= picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3b kind=poison-force decision= fails=7
WAVE id=4 kind=heal agents=60 mode=parallel-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
W0 kind=stress mode=sequential-yield n=60 esc+240 decision=refuse fails=7
WAVE id=0 kind=stress agents=60 mode=sequential-yield n=60 yields=120 esc_delta=240 decision=refuse fails=7 picked=#f
WAVE id=1 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=221 decision=refuse fails=7 picked=#f
WAVE id=2 kind=stress agents=60 mode=sequential-yield n=60 esc_delta=222 decision=refuse fails=7 picked=#f
WAVE id=3 kind=poison-mix agents=60 mode=sequential-yield n=60 esc_delta=-563 decision=refuse picked=#f
WAVE id=3b kind=poison-force decision=rollback fails=7
WAVE id=4 kind=heal agents=60 mode=sequential-yield n=60 esc_delta=227 decision=refuse fails=7 picked=#f
WAVE id=5 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=223 decision=refuse fails=7 picked=#f
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. '
load_module_file: cannot resolve 'You are a denseness propose-edge agent for Aether on Aura Unify. Your ONLY job is one structured wire line. No tools. No markdown fences. Wire: MUTATE|gate|(lambda (x) (< x N))|short-summary  OR  SKIP|gate||short-summary. N integer 1-10. Body may only reference x and numeric literals. budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; Invalid bodies are refused by schema before rebind.
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. '
error: internal error: recursion depth exceeded (>700)
WAVE id=1 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=221 decision=refuse fails=7 picked=#f
load_module_file: cannot resolve 'ion; reply w'
error: internal error: recursion depth exceeded (>700)
WAVE id=2 kind=stress agents=60 mode=sequential-yield n=60 esc_delta=222 decision=refuse fails=7 picked=#f
error: internal error: recursion depth exceeded (>700)
WAVE id=3 kind=poison-mix agents=60 mode=sequential-yield n=60 esc_delta=-563 decision=refuse picked=#f
WAVE id=3b kind=poison-force decision=rollback fails=7
load_module_file: cannot resolve '16384'
error: internal error: recursion depth exceeded (>700)
WAVE id=4 kind=heal agents=60 mode=sequential-yield n=60 esc_delta=227 decision=refuse fails=7 picked=#f
error: internal error: recursion depth exceeded (>700)
WAVE id=5 kind=healthy agents=60 mode=sequential-yield n=60 esc_delta=223 decision=refuse fails=7 picked=#f
summary commits=0 skips=0 rollbacks=1 refuses=6 anomalies=0 fan-rounds=6 total-props=360 agents=60 fanout-mode=sequential-yield
stats (("rounds" . 1) ("commits" . 0) ("rollbacks" . 1) ("verify-fail" . 1) ("observe-calls" . 1) ("decide-mutate" . 1) ("decide-skip" . 0) ("escapes" . 570))
final-batch=(3 7)
FAIL: overnight multi-agent fanout stress
RESULT fail example=22-overnight-mutate agents=60 anomalies=0 safety=#t fan-rounds=6 props=360 commits=0 skips=0 rollbacks=1 refuses=6 escapes=570 mode=sequential-yield live=#t
DIAG batch=(3 7) stats=(("rounds" . 1) ("commits" . 0) ("rollbacks" . 1) ("verify-fail" . 1) ("observe-calls" . 1) ("decide-mutate" . 1) ("decide-skip" . 0) ("escapes" . 570))
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG

=== AURA CRASH: SIGSEGV (signal 11) si_addr=0xffffffff00000018 si_code=1 ip=0x2433994 sp=0xfffff6832060 ===
Faulting IP: _ZNSt3pmr15memory_resource10deallocateEPvmm+36 in /home/dev/code/grok-dev/aether/../aura-grok/build/aura
si_addr 0xffffffff00000018 is outside any loaded module (use-after-free or uninit ptr?)
Resolve with: addr2line -e aura -f -C <ip> <si_addr>
=== END CRASH ===
./scripts/overnight-mutate.sh: line 398: 367108 Segmentation fault         ./scripts/run-aura.sh "$DRIVER" 2>&1
JOB_EXIT job=64 rc=139
```

### Repro (paste into Aura/Aether issue)

```bash
cd /home/dev/code/grok-dev/aether
export TZ=Asia/Shanghai
export AETHER_LLM_PROPOSE=live
export AETHER_OVERNIGHT_AGENTS=60
export AURA_BIN=/home/dev/code/grok-dev/aether/../aura-grok/build/aura
# optional: source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# or full harness:
# AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=10 \
#   AETHER_OVERNIGHT_MAX_PROPOSES=3 ./scripts/overnight-mutate.sh
```

### Suggested issue title

> overnight `driver-FAIL` inv=1 aether=e08ea52 aura=ecea342f

### Action

- [x] Filed Aura Phase 5 residual tracker + children (2026-08-04)
- [x] Link issue URLs:
  - Tracker: https://github.com/cybrid-systems/aura/issues/2649
  - H9 P0 SIGSEGV PMR/AST: https://github.com/cybrid-systems/aura/issues/2651
  - H10 load_module_file string UAF: https://github.com/cybrid-systems/aura/issues/2653
  - H11 recursion depth: https://github.com/cybrid-systems/aura/issues/2650
  - H12 symbol/string corruption: https://github.com/cybrid-systems/aura/issues/2652
- [ ] Do not count known [host-residuals](host-residuals.md) H9–H12 as denseness fail

## [20260804T214445+0800] 2026-08-04T13:55:49Z `driver-FAIL`

| Field | Value |
|-------|-------|
| Severity | `fail` |
| Session | `20260804T214445+0800` |
| Invocation | `2` / `9999` |
| Driver | `examples/22-overnight-mutate/main.aura` |
| Mode | `live` |
| Fanout / agents | multi-agent stress (`52`) |
| Aether SHA | `e08ea52` |
| Aura SHA | `ecea342f` |
| AURA_BIN | `/home/dev/code/grok-dev/aether/../aura-grok/build/aura` |
| TZ | `Asia/Shanghai` |
| Inv log | `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260804T214445+0800-inv0002.log` |
| RESULT | `RESULT fail example=22-overnight-mutate agents=52 anomalies=0 safety=#t fan-rounds=6 props=312 commits=0 skips=1 rollbacks=0 refuses=6 escapes=0 mode=sequential-yield live=#t` |

### Detail

Driver finished without PASS line (rc=0). agents=52 RESULT=`RESULT fail example=22-overnight-mutate agents=52 anomalies=0 safety=#t fan-rounds=6 props=312 commits=0 skips=1 rollbacks=0 refuses=6 escapes=0 mode=sequential-yield live=#t`. Full log: `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260804T214445+0800-inv0002.log`.

### Log excerpt

```
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
Faulting IP: _ZSt12construct_atIN4aura3astW4auraW4coreW3ast7NodeTagEJRKS5_EQaant20is_unbounded_array_vIT_ErqXgsnwcvPvLi0E_S8_pispcl7declvalIT0_EEEEEPS8_SB_DpOSA_+64 in /home/dev/code/grok-dev/aether/../aura-grok/build/aura
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
error: internal error: recursion depth exceeded (>700)
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
WAVE id=3 kind=poison-mix agents=52 mode=parallel-yield n=52 esc_delta=0 decision= picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3b kind=poison-force decision= fails=7
WAVE id=4 kind=heal agents=52 mode=sequential-yield n=52 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=52 mode=parallel-yield n=52 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
W0 kind=stress mode=sequential-yield n=52 esc+208 decision=refuse fails=7
WAVE id=0 kind=stress agents=52 mode=sequential-yield n=52 yields=104 esc_delta=208 decision=refuse fails=7 picked=#f
WAVE id=1 kind=healthy agents=52 mode=parallel-yield n=52 esc_delta=75 decision= fails=7 picked=("" "gate" "" "Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; " ") (< x N))|s")
WAVE id=2 kind=stress agents=52 mode=sequential-yield n=52 esc_delta=-283 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3 kind=poison-mix agents=52 mode=parallel-yield n=52 esc_delta=0 decision= picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3b kind=poison-force decision= fails=7
WAVE id=4 kind=heal agents=52 mode=parallel-yield n=52 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=52 mode=sequential-yield n=52 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. '
load_module_file: cannot resolve 'You are a denseness propose-edge agent for Aether on Aura Unify. Your ONLY job is one structured wire line. No tools. No markdown fences. Wire: MUTATE|gate|(lambda (x) (< x N))|short-summary  OR  SKIP|gate||short-summary. N integer 1-10. Body may only reference x and numeric literals. Widen when fail-count exceeds max-fails; otherwise SKIP is preferred. Invalid bodies are refused by schema before rebind.
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. === densenesbudget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. E@�0��EE��0��EEbudget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; budget fails<=4. Prefer widen (lambda (x) (< x 7)) when over budget; SKIP when healthy. Never emit gate/set!/define/require/eval in body. 
[ctx] S_Aether denseness: Observe→Decide→SafeMutation→Verify→Rollback. Pure Aura core; LLM only on propose edge. Gate policy on x in 1..10; ness observaSKIP when healthy. Never emit gate/set!/define/require/eval in body. '
WAVE id=2 kind=stress agents=52 mode=sequential-yield n=52 esc_delta=-283 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3 kind=poison-mix agents=52 mode=parallel-yield n=52 esc_delta=0 decision= picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=3b kind=poison-force decision= fails=7
WAVE id=4 kind=heal agents=52 mode=parallel-yield n=52 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
WAVE id=5 kind=healthy agents=52 mode=sequential-yield n=52 esc_delta=0 decision= fails=7 picked=("" "" "" "no-safe-candidate" "arbiter")
summary commits=0 skips=1 rollbacks=0 refuses=6 anomalies=0 fan-rounds=6 total-props=312 agents=52 fanout-mode=sequential-yield
stats (("" . 0) ("commits" . 0) ("rollbacks" . 0) ("verify-fail" . 0) ("observe-calls" . 0) ("decide-mutate" . 0) ("decide-skip" . 0) ("escapes" . 0))
final-batch=(3 7)
FAIL: overnight multi-agent fanout stress
RESULT fail example=22-overnight-mutate agents=52 anomalies=0 safety=#t fan-rounds=6 props=312 commits=0 skips=1 rollbacks=0 refuses=6 escapes=0 mode=sequential-yield live=#t
DIAG batch=(3 7) stats=(("" . 0) ("commits" . 0) ("rollbacks" . 0) ("verify-fail" . 0) ("observe-calls" . 0) ("decide-mutate" . 0) ("decide-skip" . 0) ("escapes" . 0))
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
JOB_EXIT job=63 rc=1
==== 20260804T214445+0800-inv0002.log.job64 ====
# overnight inv=2 job=64/64 agents=52
session_id=20260804T214445+0800 utc=2026-08-04T13:51:45Z
=== Aether 22-overnight-mutate: multi-agent fanout stress ===
LOG_META example=22-overnight-mutate role=overnight-driver denseness=phase5
n-agents=52 propose-mode=live live?=#t fanout-mode(pre)=sequential-yield
LOG_CFG agents=52 live=#t propose_mode=live
R0 batch=(3 7) fails=7

=== AURA CRASH: SIGSEGV (signal 11) si_addr=(nil) si_code=1 ip=0x24339d0 sp=0xffff9dda7190 ===
Faulting IP: _ZNSt3pmr15memory_resource8allocateEmm+24 in /home/dev/code/grok-dev/aether/../aura-grok/build/aura
Resolve with: addr2line -e aura -f -C <ip> <si_addr>
=== END CRASH ===
./scripts/overnight-mutate.sh: line 398: 450178 Segmentation fault         ./scripts/run-aura.sh "$DRIVER" 2>&1
JOB_EXIT job=64 rc=139
```

### Repro (paste into Aura/Aether issue)

```bash
cd /home/dev/code/grok-dev/aether
export TZ=Asia/Shanghai
export AETHER_LLM_PROPOSE=live
export AETHER_OVERNIGHT_AGENTS=52
export AURA_BIN=/home/dev/code/grok-dev/aether/../aura-grok/build/aura
# optional: source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# or full harness:
# AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=10 \
#   AETHER_OVERNIGHT_MAX_PROPOSES=3 ./scripts/overnight-mutate.sh
```

### Suggested issue title

> overnight `driver-FAIL` inv=2 aether=e08ea52 aura=ecea342f

### Action

- [x] Same Phase 5 residual cluster as inv=1 (H9–H12)
- [x] Tracker: https://github.com/cybrid-systems/aura/issues/2649
  - H9 https://github.com/cybrid-systems/aura/issues/2651 · H10 https://github.com/cybrid-systems/aura/issues/2653
  - H11 https://github.com/cybrid-systems/aura/issues/2650 · H12 https://github.com/cybrid-systems/aura/issues/2652
- [ ] Do not count known [host-residuals](host-residuals.md) H9–H12 as denseness fail

## [20260804T214445+0800] 2026-08-04T13:55:49Z `provider-or-llm-pressure`

| Field | Value |
|-------|-------|
| Severity | `quota` |
| Session | `20260804T214445+0800` |
| Invocation | `2` / `9999` |
| Driver | `examples/22-overnight-mutate/main.aura` |
| Mode | `live` |
| Fanout / agents | multi-agent stress (`52`) |
| Aether SHA | `e08ea52` |
| Aura SHA | `ecea342f` |
| AURA_BIN | `/home/dev/code/grok-dev/aether/../aura-grok/build/aura` |
| TZ | `Asia/Shanghai` |
| Inv log | `/home/dev/code/grok-dev/aether/notes/overnight-invocations/20260804T214445+0800-inv0002.log` |
| RESULT | `RESULT fail example=22-overnight-mutate agents=52 anomalies=0 safety=#t fan-rounds=6 props=312 commits=0 skips=1 rollbacks=0 refuses=6 escapes=0 mode=sequential-yield live=#t` |

### Detail

LLM/provider pressure at agents=52 (rate-limit/quota/fallback/low escapes). Backing off.

### Log excerpt

```
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
ISSUE_HINT: if error: eval_flat/unbound → Aura host residual; if LLM rate-limit → harness backoff; attach WAVE+RESULT+DIAG
```

### Repro (paste into Aura/Aether issue)

```bash
cd /home/dev/code/grok-dev/aether
export TZ=Asia/Shanghai
export AETHER_LLM_PROPOSE=live
export AETHER_OVERNIGHT_AGENTS=52
export AURA_BIN=/home/dev/code/grok-dev/aether/../aura-grok/build/aura
# optional: source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# or full harness:
# AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=10 \
#   AETHER_OVERNIGHT_MAX_PROPOSES=3 ./scripts/overnight-mutate.sh
```

### Suggested issue title

> overnight `provider-or-llm-pressure` inv=2 aether=e08ea52 aura=ecea342f

### Action

- [ ] Harness backoff only if true provider 429/quota (not host crash)
- [x] Note: inv2 also shows host SIGSEGV + empty stats — primary track is Aura #2649 (H9–H12), not denseness
- [ ] Do not open separate Aura issue for quota-only signals

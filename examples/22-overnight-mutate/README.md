# 22 — Overnight multi-agent fanout stress (Phase 5)

**Aether issue #4.** Budget-bounded continuous mutation under **multi-agent
sandbox propose fanout**. Mutates denseness domain `gate` only (not mainline
`lib/aether-*`). Long runs: `scripts/overnight-mutate.sh`.

## Pressure shape (adaptive multi-agent)

Each driver invocation (agent count **N** from env / harness):

```
N agents ──aether:fanout──► (parallel-yield when live) ──► pure-Aura arbiter
                                                         ──► single executor
× 6 waves  (+ forced poison rollback)
≈ N×6 short llm:chat when live
```

**Harness default = maximum pressure** (`./scripts/overnight-mutate.sh` alone):

```
sleep=0
agents=60 (host-stable max; 64 arbiter returns #f)
parallel_jobs=16 concurrent aura processes (live)
  each: 60 fiber agents × 6 waves (orch:parallel-with-yield preferred)
  ≈ 16 × 60 × 6 = 5760 short LLM calls per batch

on hard fail only → brief agent trim, re-ramp to max; sleep stays 0
until clock stop (next 08:00)
```

| Mode | Propose pressure |
|------|------------------|
| **live** | max multi-process × multi-fiber, continuous |
| **stub/offline** | single job; suite uses `AETHER_OVERNIGHT_AGENTS=6` |

Invariants (unchanged denseness shape):

- LLM only on **propose edge**
- **Single mutator** after collect (no concurrent rebind)
- Schema/wire + verify/rollback still gate bad proposals
- Prefer `parallel-yield`; host residual → `sequential-yield`

## MiniMax clock stop (default)

Hard stop = **next 08:00** `Asia/Shanghai` (window 00:00–08:00).

```
now ──► 00:00 reset ──► 08:00 STOP
```

```bash
./scripts/overnight-mutate.sh
```

## Smoke (offline, in `run-all`)

```bash
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# expect: fan_rounds=6 props=36 mode=parallel-yield (or sequential-yield)
```

## Env

| Env | Default | Meaning |
|-----|---------|---------|
| `AETHER_OVERNIGHT_SCHEDULE` | `minimax-0-5` | or `duration` |
| `AETHER_OVERNIGHT_TZ` | `Asia/Shanghai` | clock TZ |
| `AETHER_OVERNIGHT_WINDOW_HOURS` | `8` | stop at 08:00 |
| `AETHER_OVERNIGHT_MAX_PROPOSES` | **`9999`** | essentially unbounded batches |
| `AETHER_OVERNIGHT_SLEEP_SEC` | **`0`** | no cooldown |
| `AETHER_OVERNIGHT_SLEEP_MAX` | **`0`** | never add sleep on backoff |
| `AETHER_OVERNIGHT_PARALLEL_JOBS` | **`16` live / `1` stub** | concurrent aura processes |
| `AETHER_OVERNIGHT_ADAPTIVE` | `1` | trim only on hard fail, re-ramp |
| `AETHER_OVERNIGHT_AGENTS` | **`60`** | start at max |
| `AETHER_OVERNIGHT_AGENTS_MIN` | `16` | floor after backoff |
| `AETHER_OVERNIGHT_AGENTS_MAX` | **`60`** | ceiling (host-stable) |
| `AETHER_OVERNIGHT_AGENTS_STEP_UP` | `8` | re-ramp step |
| `AETHER_OVERNIGHT_AGENTS_STEP_DOWN` | `8` | −N on hard fail |
| `AETHER_LLM_PROPOSE` | live if key | `live` / `stub` / `rule` |

Rough live per batch: `16 × 60 × 6 ≈ 5760` short one-shots.

Log lines: `PRESSURE agents=… jobs=…` / `PRESSURE_NEXT` / `WAVE mode=parallel-yield`.

### Context (1M)

Each call is still a **fresh one-shot** (system + user, hundreds of tokens).
No multi-turn history; 1M window is not accumulated.

## Logs (for filing issues)

| Artifact | Path | Use |
|----------|------|-----|
| Session stream | `notes/.overnight-run.log` | full overnight console |
| Per invocation | `notes/overnight-invocations/<session>-invNNNN.log` | **attach to Aura issue** |
| Anomaly + repro | `notes/aura-anomaly-log.md` | FAIL/CRASH tables + paste-ready repro |

Machine lines (grep-friendly):

| Line | Meaning |
|------|---------|
| `LOG_META` / `LOG_CFG` | driver identity + agents/live |
| `WAVE id=…` | per-wave mode, n, decision, picked |
| `RESULT pass\|fail …` | suite-style outcome |
| `DIAG batch=… stats=…` | denseness counters |
| `ISSUE_HINT: …` | on FAIL only |
| `INV_STATUS …` | harness per-inv status |

```bash
grep -E '^(WAVE |RESULT |DIAG |INV_STATUS|error:)' notes/overnight-invocations/* | tail -40
```

How to open issues: [aura-anomaly-log.md](../../notes/aura-anomaly-log.md).

## Safety

- Failed proposes never leave unverified rebinds.
- Anomalies → `notes/aura-anomaly-log.md` with **repro block + log excerpt**.
- Does **not** auto-push mutated mainline libraries.

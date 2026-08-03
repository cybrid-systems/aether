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

**Harness default (continuous full-blast)**:

```
sleep=0 (no cooldown)
start agents=MAX (default 32)
parallel_jobs=4 concurrent aura processes (live)
  each process: N fiber agents × 6 waves via orch:parallel-with-yield
  ≈ jobs × agents × 6 concurrent-ish LLM calls per invocation batch

on LLM fail / 429 / CRASH → agents −= step (floor MIN=8), re-ramp when healthy
keep hammering until clock stop (next 08:00)
```

| Mode | Propose pressure |
|------|------------------|
| **live** | multi-process × multi-fiber agents, continuous, no sleep |
| **stub/offline** | single job; suite uses fixed `AETHER_OVERNIGHT_AGENTS=6` |

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
| `AETHER_OVERNIGHT_MAX_PROPOSES` | `200` | max invocation batches |
| `AETHER_OVERNIGHT_SLEEP_SEC` | **`0`** | no cooldown (continuous) |
| `AETHER_OVERNIGHT_PARALLEL_JOBS` | **`4` live / `1` stub** | concurrent aura processes |
| `AETHER_OVERNIGHT_ADAPTIVE` | `1` | back off only on failure |
| `AETHER_OVERNIGHT_AGENTS` | **MAX** | start full (default 32) |
| `AETHER_OVERNIGHT_AGENTS_MIN` | `8` | floor after backoff |
| `AETHER_OVERNIGHT_AGENTS_MAX` | `32` | ceiling |
| `AETHER_OVERNIGHT_AGENTS_STEP_UP` | `4` | re-ramp step |
| `AETHER_OVERNIGHT_AGENTS_STEP_DOWN` | `4` | −N on LLM fail |
| `AETHER_LLM_PROPOSE` | live if key | `live` / `stub` / `rule` |

Rough live concurrency per batch: `jobs × agents × 6` short one-shots  
(e.g. `4 × 32 × 6 = 768` calls/batch if every agent every wave hits live).

Log lines: `PRESSURE agents=… jobs=…` / `PRESSURE_NEXT action=…` / `WAVE mode=parallel-yield`.

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

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

**Harness adaptive loop** (default):

```
start agents=2
  PASS + healthy LLM  → agents += 2 (up to 24), sleep slightly ↓
  LLM fail / 429 / quota / low escapes / FAIL / CRASH
                      → agents -= 4 (floor 2), sleep ↑
  keep pressing until clock stop (next 08:00)
```

| Mode | Propose pressure |
|------|------------------|
| **live** | ramps e.g. 2→4→…→peak then back off and sustain |
| **stub/offline** | same ramp topology (suite default N=6 fixed per single run) |

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
| `AETHER_OVERNIGHT_MAX_PROPOSES` | `80` | max driver restarts |
| `AETHER_OVERNIGHT_SLEEP_SEC` | `20` | base cooldown (adaptive) |
| `AETHER_OVERNIGHT_ADAPTIVE` | `1` | `0` = freeze agent count |
| `AETHER_OVERNIGHT_AGENTS` | start | initial N (default min=2 when adaptive) |
| `AETHER_OVERNIGHT_AGENTS_MIN` | `2` | floor after backoff |
| `AETHER_OVERNIGHT_AGENTS_MAX` | `24` | ceiling when ramping |
| `AETHER_OVERNIGHT_AGENTS_STEP_UP` | `2` | +N on healthy PASS |
| `AETHER_OVERNIGHT_AGENTS_STEP_DOWN` | `4` | −N on LLM fail |
| `AETHER_LLM_PROPOSE` | live if key | `live` / `stub` / `rule` |

Log lines: `PRESSURE agents=…` / `PRESSURE_NEXT action=ramp|backoff_llm|…`.

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

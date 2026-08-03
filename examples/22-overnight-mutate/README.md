# 22 — Overnight multi-agent fanout stress (Phase 5)

**Aether issue #4.** Budget-bounded continuous mutation under **multi-agent
sandbox propose fanout**. Mutates denseness domain `gate` only (not mainline
`lib/aether-*`). Long runs: `scripts/overnight-mutate.sh`.

## Pressure shape (why this is denser than a single LLM call)

Each driver invocation:

```
6 agents ──aether:fanout──► (parallel-yield preferred) ──► pure-Aura arbiter
                                                          ──► single executor
× 6 waves  (+ forced poison rollback)
```

| Mode | Propose pressure per invocation |
|------|----------------------------------|
| **live** | ≈ **36** short `llm:chat` one-shots (6 agents × 6 waves) |
| **stub/offline** | same topology; stub markers meter `escapes` (no network) |

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
| `AETHER_OVERNIGHT_SLEEP_SEC` | `20` | cooldown between invocations |
| `AETHER_OVERNIGHT_AGENTS` | `6` | (reserved; driver uses 6-agent waves) |
| `AETHER_LLM_PROPOSE` | live if key | `live` / `stub` / `rule` |

Rough live upper bound overnight: `80 × 36 ≈ 2880` short one-shots if every
invocation is live and the clock allows — usually less (latency + early stop).

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

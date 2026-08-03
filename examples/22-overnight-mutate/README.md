# 22 — Overnight continuous mutation harness (Phase 5)

**Aether issue #4.** Budget-bounded closed-loop mutation under stub or live LLM
propose. Mutates the denseness **domain gate** only (not mainline `lib/aether-*`
promotion). Long runs use `scripts/overnight-mutate.sh`.

## MiniMax time model (clock-aligned stop)

Plan counting starts at **local 00:00** (default TZ `Asia/Shanghai`).  
Default hard stop is the **next 08:00** (not a rolling “N minutes from now”).

### Typical overnight (e.g. start ~22:50)

```
now ──► 00:00 reset ──► 08:00 hard stop  STOP
 ~1h residual          through morning
```

```bash
./scripts/overnight-mutate.sh
# → hard stop at next 08:00 (Asia/Shanghai)
```

Only after midnight (sleep until 00:00 if you start after 08:00):

```bash
AETHER_OVERNIGHT_PEAK_ONLY=1 ./scripts/overnight-mutate.sh
```

Fixed duration (smoke / ignore clock):

```bash
AETHER_OVERNIGHT_SCHEDULE=duration AETHER_OVERNIGHT_MAX_MINUTES=3 \
  AETHER_OVERNIGHT_MAX_PROPOSES=4 AETHER_OVERNIGHT_SLEEP_SEC=5 \
  ./scripts/overnight-mutate.sh
```

### Caps

| Cap | Default | Meaning |
|-----|---------|---------|
| Schedule hard stop | next **08:00** local | `WINDOW_HOURS=8` from 00:00 |
| Invocations | 120 | max driver process restarts |
| Cooldown | 30s | sleep between invocations |
| Optional `MAX_MINUTES` | unset | extra ceiling from start (whichever first) |
| TZ | `Asia/Shanghai` | `AETHER_OVERNIGHT_TZ` |

Provider 429 / empty / parse fail → soft rule fallback; loop may continue until
a local cap hits.

### Context window (1M)

Not a problem here:

- Each call is a **fresh one-shot** (`llm:chat` system + user only).
- Prompts are tiny (wire format + fail counts).
- Each shell invocation is a **new Aura process** — no cross-run history.

## Smoke (offline, in `run-all`)

Driver runs **5 fixed closed-loop steps** per process (widen / skip / poison-rollback / heal).

```bash
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
```

## Env reference

| Env | Default | Meaning |
|-----|---------|---------|
| `AETHER_OVERNIGHT_SCHEDULE` | `minimax-0-5` | or `duration` |
| `AETHER_OVERNIGHT_TZ` | `Asia/Shanghai` | plan reset timezone |
| `AETHER_OVERNIGHT_RESET_HOUR` | `0` | window start hour |
| `AETHER_OVERNIGHT_WINDOW_HOURS` | `8` | window length → stop **08:00** |
| `AETHER_OVERNIGHT_PEAK_ONLY` | `0` | `1` = sleep until window, then run |
| `AETHER_OVERNIGHT_MAX_PROPOSES` | `120` | max driver restarts |
| `AETHER_OVERNIGHT_SLEEP_SEC` | `30` | cooldown |
| `AETHER_OVERNIGHT_MAX_MINUTES` | unset | optional extra wall cap |
| `AETHER_LLM_PROPOSE` | live if key else stub | propose edge |

## Safety

- Failed proposes never leave unverified rebinds.
- Anomalies → `notes/aura-anomaly-log.md`.
- Does **not** auto-push mutated mainline libraries.

## Aura bug mining

Crashes / verify false-negatives / rollback failures →
[`notes/aura-anomaly-log.md`](../../notes/aura-anomaly-log.md).

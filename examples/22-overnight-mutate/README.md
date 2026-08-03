# 22 — Overnight continuous mutation harness (Phase 5)

**Aether issue #4.** Budget-bounded closed-loop mutation under stub or live LLM
propose. Mutates the denseness **domain gate** only (not mainline `lib/aether-*`
promotion). Long runs use `scripts/overnight-mutate.sh`.

## Smoke (offline, in `run-all`)

Driver runs **5 fixed closed-loop steps** per process (widen / skip / poison-rollback / heal).

```bash
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
```

## Overnight / multi-minute live

Shell re-invokes the driver under wall-clock + invocation budgets.

```bash
# defaults: MiniMax-M3 from ~/code/keys/minimax, budget stop, rate limit
./scripts/overnight-mutate.sh

# short local test (~few minutes)
AETHER_OVERNIGHT_MAX_MINUTES=3 AETHER_OVERNIGHT_MAX_PROPOSES=4 \
  AETHER_OVERNIGHT_SLEEP_SEC=5 \
  ./scripts/overnight-mutate.sh
```

| Env | Default | Meaning |
|-----|---------|---------|
| `AETHER_OVERNIGHT_MAX_MINUTES` | 480 | wall-clock stop |
| `AETHER_OVERNIGHT_MAX_PROPOSES` | 200 | total driver invocations |
| `AETHER_OVERNIGHT_SLEEP_SEC` | 15 | cooldown between invocations |
| `AETHER_LLM_PROPOSE` | live if key else stub | propose edge mode |

## Safety

- Failed proposes never leave unverified rebinds (execute path + verify).
- Anomalies append to `notes/aura-anomaly-log.md` via the shell wrapper.
- Does **not** auto-push mutated mainline libraries.
- Main denseness suite stays green; this probe is offline-smoke safe.

## Aura bug mining

Crashes, verify false-negatives, rollback failures →
[`notes/aura-anomaly-log.md`](../../notes/aura-anomaly-log.md) then Aura issues
when reproducible.

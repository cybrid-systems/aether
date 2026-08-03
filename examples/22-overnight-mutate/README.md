# 22 — Overnight continuous mutation harness (Phase 5)

**Aether issue #4.** Budget-bounded closed-loop mutation under stub or live LLM
propose. Mutates the denseness **domain gate** only (not mainline `lib/aether-*`
promotion). Long runs use `scripts/overnight-mutate.sh`.

## What “default budget” means

The shell harness only enforces **local** stop conditions — it is **not** your
MiniMax account quota / token balance:

| Cap | Default | Meaning |
|-----|---------|---------|
| Wall-clock | **300 min (5h)** | process loop stops at deadline |
| Invocations | **60** | max times the driver process is re-run |
| Cooldown | **30s** | sleep between invocations (rate throttle) |

Whichever hits first ends the session. Provider 429 / empty / parse fail → soft
fallback to rule propose; the loop may keep going until a local cap hits.

**Rough spend (live):** driver does **~4** short `llm:chat` calls per invocation
→ upper bound ≈ `60 × 4 = 240` API calls over 5h (often less if each call is
slow). Tighten with env if your plan is tighter.

### Context window (1M)

Not a problem for this harness:

- Each call is a **fresh one-shot** (`llm:chat` system + user only; no multi-turn
  history, no growing conversation).
- Prompts are tiny (wire format + fail counts — hundreds of tokens, not MB).
- Each shell invocation is a **new Aura process** — no cross-run context carry.

Do **not** paste large codebases into the propose edge; denseness design keeps
LLM on the thin propose wire only.

## Smoke (offline, in `run-all`)

Driver runs **5 fixed closed-loop steps** per process (widen / skip / poison-rollback / heal).

```bash
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
```

## Overnight / multi-minute live

```bash
# defaults: 5h wall + 60 inv + 30s sleep; MiniMax-M3 from ~/code/keys/minimax
./scripts/overnight-mutate.sh

# short local test (~few minutes)
AETHER_OVERNIGHT_MAX_MINUTES=3 AETHER_OVERNIGHT_MAX_PROPOSES=4 \
  AETHER_OVERNIGHT_SLEEP_SEC=5 \
  ./scripts/overnight-mutate.sh

# stricter (e.g. half the plan window, fewer calls)
AETHER_OVERNIGHT_MAX_MINUTES=120 AETHER_OVERNIGHT_MAX_PROPOSES=20 \
  AETHER_OVERNIGHT_SLEEP_SEC=60 \
  ./scripts/overnight-mutate.sh
```

| Env | Default | Meaning |
|-----|---------|---------|
| `AETHER_OVERNIGHT_MAX_MINUTES` | 300 | wall-clock stop (~5h plan) |
| `AETHER_OVERNIGHT_MAX_PROPOSES` | 60 | total driver process restarts |
| `AETHER_OVERNIGHT_SLEEP_SEC` | 30 | cooldown between invocations |
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

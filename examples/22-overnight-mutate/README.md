# 22 — Overnight multi-agent fanout stress (Phase 5)

**Aether issue #4.** Continuous max-pressure propose-edge stress under live LLM.
Mutates denseness domain `gate` only (not mainline `lib/aether-*`).

## Default = maximum pressure

```bash
./scripts/overnight-mutate.sh
```

| Knob | Default (live) | Meaning |
|------|----------------|---------|
| sleep | **0** | continuous, no cooldown |
| agents / process | **60** | fiber fanout per aura process (host-stable max) |
| parallel_jobs | **64** | concurrent aura processes |
| **logical agents** | **≈ 3840** | `64 × 60` concurrent proposers / wave |
| context | **16384 chars** | long one-shot system+user pad on propose edge |
| waves / process | 6 | denseness O→D→M waves + poison rollback |
| est LLM calls / batch | **≈ 23040** | `64 × 60 × 6` if every agent live-calls |
| hard stop | next **08:00** Asia/Shanghai | plan window |

Per-process agent fanout is capped ~60 (arbitrate returns `#f` at 64). **Thousands
of agents** are achieved by multi-process shell fanout × per-process fiber agents.

```
64 aura processes ──each──► 60 fiber agents ──parallel-yield──► pure-Aura arbiter
                             × 6 waves                          ──► single executor
≈ 3840 concurrent propose agents / wave; long context per llm:chat
```

## Long context

Env `AETHER_LLM_CONTEXT_CHARS` (default **16384** for live overnight):

- Pads system + user prompts with denseness policy context (still **one-shot**,
  no multi-turn history — does not fill MiniMax 1M accidentally).
- Wire line still required at end: `MUTATE|…` / `SKIP|…`.
- Offline suite forces `0` (short prompts).

Raise further if desired:

```bash
AETHER_LLM_CONTEXT_CHARS=48000 ./scripts/overnight-mutate.sh
```

## Smoke (offline, in `run-all`)

```bash
./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
# default agents=6, short context, no parallel jobs
```

## Throttle (only if you want gentler)

```bash
AETHER_OVERNIGHT_PARALLEL_JOBS=4 AETHER_OVERNIGHT_AGENTS=16 \
  AETHER_LLM_CONTEXT_CHARS=2000 AETHER_OVERNIGHT_SLEEP_SEC=5 \
  ./scripts/overnight-mutate.sh
```

## Logs (filing issues)

| Artifact | Path |
|----------|------|
| Session | `notes/.overnight-run.log` |
| Per inv | `notes/overnight-invocations/<session>-invNNNN.log` |
| Anomalies | `notes/aura-anomaly-log.md` |

```bash
grep -E 'PRESSURE|WAVE |RESULT |INV_STATUS' notes/.overnight-run.log | tail -40
```

## Safety

- Single mutator after arbiter (no concurrent rebind of core).
- Schema/wire + verify/rollback still gate bad proposals.
- Does not auto-mainline `lib/aether-*`.

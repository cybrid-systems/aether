# 10 — Long-N denseness stress (Phase 3)

Multi-round stress beyond example 05’s N=10. Proves O→D→M→V→R + poison/heal
stays within business budget and safety/quota health for **N=50** with zero
evolvable-core escapes.

## What it runs

| Round | Action |
|-------|--------|
| 0 | Deploy widen gate (budget ok) |
| `i % 10 == 0` | Poison deny-all → guarded heal to last-good |
| else | Skip (observe + decide no-mutate) |

## Run

```bash
./scripts/run-aura.sh examples/10-long-n-stress/main.aura
```

Expected:

```text
PASS: long-N denseness stress (N=50, poison-heal cadence)
RESULT pass example=10-long-n-stress N=50 escapes=0 ...
```

## Escapes

None on the PASS path (pure Aura + `aether-min` + `aether-domain`).

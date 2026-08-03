# 17 — True parallel fanout (Axis C / host residual #1)

Uses `aether:fanout` → **`orch:parallel-with-yield`** for multi-propose.
PASS requires `mode=parallel-yield` (not sequential fallback).

Workers only return proposal lists; **arbiter + single executor** mutate.

## Run

```bash
./scripts/run-aura.sh examples/17-true-parallel/main.aura
```

## Relation to 12

| Probe | Mode |
|-------|------|
| 12 | Always sequential-yield (stable denseness baseline) |
| 17 | Requires true parallel-yield (host orch/fiber healthy) |

## Escapes

None on PASS path (pure Aura + std/orchestrator).

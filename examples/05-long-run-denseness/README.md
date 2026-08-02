# 05 — Long-run denseness harness

Multi-round smoke across deploy / skip / poison+heal under a fixed business
budget. Feeds the Phase 2 denseness write-up.

## What it runs

`N = 10` rounds on the gate workload (fails ≤ 4):

| Condition | Action |
|-----------|--------|
| Over budget | hot-deploy widen gate |
| `round % 4 == 3` and healthy | poison then **self-heal** |
| Else healthy | skip |

## Run

```bash
./scripts/run-aura.sh examples/05-long-run-denseness/main.aura
```

Expected:

```text
PASS: long-run denseness harness (N=10, deploy/skip/poison-heal)
```

## Escapes

None on the PASS path.

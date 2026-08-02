# 12 — Parallel + yield topology (Axis C residual)

Multi-propose **fanout** with `mutate:safe-yield` barriers, then pure-Aura
**arbiter** + single **executor**. Workers never mutate.

## Why sequential-yield

Host CLI measurements:

| Path | Observation |
|------|-------------|
| `fiber:spawn` multi-worker | Closure mis-capture (workers can all see last lambda) |
| `orch:parallel` after rebind | Free-var breaks inside `std/orchestrator` (`orch-yield-safe`) |
| `aether:fanout-with-yield` | Stable: yield before/after each proposer; order-independent propose |

Denseness claim: the **topology** (multi propose · yield · arbitrate · single
mutate) lives in pure Aura. True OS-level parallel is a host scheduling detail
when fibers are reliable; cooperative sequential-yield is the isomorphic
expression under MutationBoundary + safe-yield.

## Scenarios

| Case | What |
|------|------|
| A over budget | 2× widen fanout → arb widen → commit |
| B healthy after rebind | fanout still works → arb skip |
| C deny worker | deny filtered → skip |

## Run

```bash
./scripts/run-aura.sh examples/12-parallel-yield/main.aura
```

## Escapes

None on the PASS path.

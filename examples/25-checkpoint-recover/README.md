# 25 — checkpoint-recover

**Interruptible continuous time**: after a healthy commit, checkpoint, simulate
crash mutation, restore, and resume O→D→M→V→R (skip + reject still work).

## Axes

- **A** Loop completeness — multi-step with recover mid-life  
- **D** Temporal adaptation — restore prior consistent state  
- **F** Metrology — commits / skip / rollbacks / escapes=0  

## Why not `std/persist` on PASS path

On current host, `persist:save` after rebind then `persist:load` may no-op
(score stays poisoned). Denseness path uses **`aether:snapshot` /
`aether:restore`** (Aura basis). Persist residual is host packaging, not a
core \(E\) of the evolvable loop.

## Run

```bash
./scripts/run-aura.sh examples/25-checkpoint-recover/main.aura
```

## PASS criteria

| Step | Claim |
|------|--------|
| A | Commit double → triple |
| B | Checkpoint id ≥ 0 |
| C | Poison mutates away from goal |
| D | Restore → score triple; skip + reject still work; safety-ok |

## Escapes

None.

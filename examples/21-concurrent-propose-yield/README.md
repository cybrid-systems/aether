# 21 — Concurrent propose fanout + yield + single mutator (Phase 5)

**Aether issue #2.** Fanout multiple propose edges under yield discipline; only
one executor mutates. Complements [20-multi-live-propose](../20-multi-live-propose/).

```
fanout(propose_A, propose_B, …) ──yield──► collect ──► arbiter ──► single mutator
```

## Offline

Uses `aether:fanout-with-yield` (cooperative sequential-yield — host fiber
parallel is residual; dual-mode `aether:fanout` still preferred elsewhere).

```bash
./scripts/run-aura.sh examples/21-concurrent-propose-yield/main.aura
```

## Live (opt-in)

```bash
AETHER_LLM_PROPOSE=live ./scripts/run-aura.sh examples/21-concurrent-propose-yield/main.aura
```

## Invariants

| Invariant | Check |
|-----------|--------|
| Single mutator | Only `aether:execute-proposal` after collect |
| Yield barriers | `yields >= 2 * N` on fanout path |
| Safety | `aether:safety-ok?` after rounds |
| Poison path | Deny/invalid never leaves core rebind committed |
| Core \(E\) | 0 on decide/verify/rollback |

Included in offline `run-all.sh` / `report.sh`.

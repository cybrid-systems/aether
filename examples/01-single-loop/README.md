# 01 — Single-loop denseness probe

Minimal **self-evolving Agent closed-loop** with no LLM.

## What it proves

| Round | Step | Behavior |
|-------|------|----------|
| R1 | Observe → Decide → Mutate → Verify → **Commit** | `score` double→triple via `mutate:rebind` |
| R2 | Observe → Decide → **Skip** | already correct (`score(7)=21`) |
| R3 | Mutate → Verify fail → **Rollback** | bad `*99` body; `ast:restore` restores triple |

Axes: **A** loop · **B** mutation under engine Guard · **F** counter stats.

## Run

From aether repo root (requires local Aura host, e.g. `../aura-grok`):

```bash
./scripts/run-aura.sh examples/01-single-loop/main.aura
```

Expected ending:

```text
PASS: O→D→M→V→R closed loop (commit + skip + rollback)
escapes: 0 in evolvable core (pure Aura on host stdlib)
```

## Host notes (aura-grok CLI)

These shaped the example layout; they are host constraints, not Aether escapes:

| Constraint | Mitigation in this example |
|------------|----------------------------|
| `AURA_SANDBOX=off` needed for CLI rebind | set by `scripts/run-aura.sh` |
| `set-code` invalidates prior closures | seed workspace before logic |
| hash tables unreliable across rebind | list-box counters (`set-car!`) |
| `eq?` on symbols unreliable | string decisions (`"commit"` / `"skip"` / `"rollback"`) |
| catch error var unbound if referenced | `(catch (e) #f)` only |

Reusable packaging (`lib/aether-min.aura`, split axis modules) is staged for when host module free-var wiring across mutation is solid; **this example is intentionally linear** so denseness evidence stays reproducible.

## Escapes

**None** in the evolvable core. Runtime is Aura (C++ basis).  
`AURA_SANDBOX=off` is host configuration for demos, not a business-logic escape.

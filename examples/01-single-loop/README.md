# 01 — Single-loop denseness probe

Minimal **self-evolving Agent closed-loop** with no LLM, built on `aether-min`.

## What it proves

| Round | Step | Behavior |
|-------|------|----------|
| R1 | Observe → Decide → Mutate → Verify → **Commit** | `score` double→triple via guarded rebind |
| R2 | Observe → Decide → **Skip** | already correct (`score(7)=21`) |
| R3 | Mutate → Verify fail → **Rollback** | bad `*99` body; snapshot restore |

Axes: **A** loop · **B** mutation policy · **F** stats.

## Run

```bash
./scripts/run-aura.sh examples/01-single-loop/main.aura
```

Expected ending:

```text
PASS: O→D→M→V→R closed loop (commit + skip + rollback)
escapes: 0 in evolvable core (pure Aura + aether-min)
```

## Layout

- `main.aura` — thin scenario (require + three rounds + assertions)
- `lib/aether-min.aura` — reusable O→D→M→V→R surface

Requires host Aura with module/mutation fixes (#2566–#2570).

## Escapes

**None** in the evolvable core. Runtime is Aura (C++ basis).  
`AURA_SANDBOX=off` is host configuration for CLI mutation demos.

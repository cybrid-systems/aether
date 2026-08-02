# 02 — Business-signal closed loop

Denseness probe: **Decide from domain metrics** (batch fail count), not only
engine mutation counters.

## Scenario

| Piece | Value |
|-------|--------|
| Workload | integers `1..10` |
| Policy | `gate` — admit when `(gate x)` |
| Initial | `(lambda (x) (< x 4))` → 3 ok / **7 fails** |
| Budget | fails ≤ 4 (40%) |
| Good mut | `(lambda (x) (< x 7))` → 6 ok / **4 fails** |
| Bad mut | `(lambda (x) #f)` → 10 fails → **rollback** |

## Rounds

1. **Commit** — over budget → widen gate → within budget  
2. **Skip** — still within budget  
3. **Rollback** — deny-all proposal fails verify  

## Run

```bash
./scripts/run-aura.sh examples/02-business-signal/main.aura
```

Expected:

```text
PASS: business-signal loop (fail-rate decide + commit/skip/rollback)
```

## Axes

- **A** full O→D→M→V→R via `aether-min`  
- **B** mutate policy under guards  
- **F** loop stats; business fail-count drives Decide/Verify  

## Escapes

None in evolvable core.

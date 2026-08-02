# 07 — Proposal schema gate

Untrusted proposals are **data**. Before any mutation:

1. **Schema validate** (`aether:proposal-valid?`)  
2. Only then `aether:loop-once` / rebind  
3. Business verify may still **rollback** schema-valid but harmful bodies  

## Cases

| ID | Proposal | Expected |
|----|----------|----------|
| A | Valid rule widen | **commit** |
| B | `kind=explode` | **refuse** `schema-invalid`, fails unchanged |
| C | body = SQL-ish garbage | **refuse** (not `(lambda…)`) |
| D | valid `(lambda (x) #f)` | **rollback** (budget verify) |

## Run

```bash
./scripts/run-aura.sh examples/07-proposal-schema/main.aura
```

## Escapes

None — schema is pure Aura on the executor path.

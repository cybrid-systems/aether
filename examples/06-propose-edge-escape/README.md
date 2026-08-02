# 06 — Propose-edge escape metering

Shows that **\(E\) can be confined to the researcher propose edge** while the
executor core stays pure and still rejects bad proposals.

## Scenarios

| ID | Propose source | Expected escapes | Executor |
|----|----------------|------------------|----------|
| A | `rule` | **0** | commit widen |
| B | `llm-stub` | **≥1** | commit widen (proposal still structured) |
| C | `llm-stub` deny-all | **≥1** | **rollback** — core not poisoned |

`llm-stub` does **not** call the network; it only marks an escape for denseness
metering. Live LLM (`AETHER_LLM_PROPOSE=live`) is supported in
`lib/aether-propose.aura` but not required for PASS.

## Run

```bash
./scripts/run-aura.sh examples/06-propose-edge-escape/main.aura
```

## Escapes

- **Core:** none (verify/rollback still pure Aura).  
- **Propose edge (B/C):** intentional stub escape for measurement.

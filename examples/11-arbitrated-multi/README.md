# 11 — Arbitrated multi-agent (Axis C)

Beyond dual-role (example 03): **two researchers propose**, a **pure-Aura
arbiter** selects one safe proposal, and a single **executor** mutates under
`aether-min` / schema guards.

## Topology

```
researcher-conservative ──┐
                          ├──► aether:arbitrate ──► execute-proposal
researcher-aggressive  ───┘         │
                                    │ filters: schema-invalid, deny-all
                                    │ prefers: widen > healthy-skip > other
```

## Scenarios

| Case | Proposals | Arbiter | Executor |
|------|-----------|---------|----------|
| A over budget | both widen | pick widen | commit |
| B healthy | both skip | skip | skip |
| C conflict | skip + deny | drop deny → skip | skip |
| D force | deny + widen | pick conservative widen | commit |

## Run

```bash
./scripts/run-aura.sh examples/11-arbitrated-multi/main.aura
```

## Escapes

None on the PASS path (arbiter and executor stay in pure Aura).

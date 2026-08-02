# 16 — Drift freeze (Axis D)

When business health **drifts** (gate over budget), the control plane **freezes**
further policy mutation. Frozen mutate attempts return `decision=freeze` without
rebind. An explicit heal path (widen under guards) restores budget and unfreezes.

## Claim

Drift freeze is a pure-Aura control semantics for temporal adaptation — not an
escape from \(V_A\).

## Run

```bash
./scripts/run-aura.sh examples/16-drift-freeze/main.aura
```

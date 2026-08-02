# Aether denseness probes

Each example is a **runnable denseness probe**. Convention:

1. Print human `PASS: …` or `FAIL…`
2. Print machine line: `RESULT pass|fail example=… key=val…`
3. Prefer `aether-min` / `aether-domain` / `aether-propose` over copy-paste

## Offline suite (`./scripts/run-all.sh`)

| Dir | Claim |
|-----|--------|
| `01-single-loop` | O→D→M→V→R baseline |
| `02-business-signal` | Business fail-rate decide |
| `03-researcher-executor` | Dual-role propose/exec |
| `04-hot-strategy-heal` | Hot deploy + self-heal |
| `05-long-run-denseness` | Multi-round harness |
| `06-propose-edge-escape` | Meter \(E\) on propose edge |
| `07-proposal-schema` | Schema before rebind |
| `08-parse-proposal-wire` | Wire parse → schema → exec |
| `10-long-n-stress` | N=50 poison/heal denseness stress |

## Live (not in run-all)

| Dir | Claim |
|-----|--------|
| `09-live-minimax` | MiniMax-M3 live propose (`source ../scripts/env-minimax.sh`) |

## Add a probe

```bash
cp -r examples/_template examples/10-my-probe
# edit main.aura + README.md
./scripts/run-aura.sh examples/10-my-probe/main.aura
# add path to scripts/run-all.sh if offline
```

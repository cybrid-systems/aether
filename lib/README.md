# Aether libraries

| Module | Axis | Role |
|--------|------|------|
| `aether-min` | A+B+F facade | Thin re-export; `aether:min-version` 3 |
| `aether-measure` | **F** | Stats + `alist-ref` (authoritative) |
| `aether-mutate-policy` | **B** | install / safety / snapshot / rebind |
| `aether-loop` | **A** | observe / decide / verify |
| `aether-loop-once` | **A** | `loop-once` only (sole large export) |
| `aether-domain` | domain | Shared admit-gate workload |
| `aether-propose` | E | Schema, wire, rule/stub/live propose |
| `aether-orch` | C | Arbitrate + fanout (parallel preferred) |
| `aether-region` | multi-tenant | Dual named gates + per-region batch |

## Packaging discipline (host H3)

- **Large** public bodies must be the **only** export of their module (`aether-loop-once`).
- Multi-export modules keep **small** defines only (`aether-loop` O/D/V).
- Prefer `(require "aether-min" all:)` in probes unless composing a single axis.

## Host residuals

See [notes/host-residuals.md](../notes/host-residuals.md). H4 (cross-module stats) improved; H3 still requires sole-export for `loop-once`.

# Aether libraries

| Module | Axis | Role |
|--------|------|------|
| `aether-min` | A+B+F facade | **Default** closed-loop surface. Embeds metrology + `loop-once`; re-exports mutate-policy. |
| `aether-mutate-policy` | B | `install-source`, safety, snapshot/restore, `rebind-safe` |
| `aether-measure` | F | Stats helpers for **pre-rebind** / tooling only (see file note) |
| `aether-loop` | A | `observe` / `decide` / `verify` helpers (narrow) |
| `aether-domain` | domain | Shared admit-gate workload (probes 02–12) |
| `aether-propose` | E | Schema, wire parse, rule/stub/live propose |
| `aether-orch` | C | Arbitrate + fanout (parallel-yield preferred, sequential fallback) |
| `aether-region` | multi-tenant | Dual named gates (`gate-a`/`gate-b`) + per-region batch |

## Host packaging discipline

Workspace `set-code` / rebind can break **cross-module free-vars** and private
module cells. Denseness PASS path therefore:

1. Keeps **stats + `loop-once` same-module** inside `aether-min`
2. Inlines public entries in `aether-propose` / `aether-orch`
3. Treats `aether-measure` as axis-shaped import, not the live loop metrology owner

Prefer `(require "aether-min" all:)` in probes unless you intentionally compose
a single axis before any mutation.

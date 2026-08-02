# \(S_{\mathrm{Aether}}\) denseness report (Phase 1–2)

**Date:** 2026-08-02  
**Host:** Aura (local `aura-grok` build) with fixes #2566–#2570  
**Surface:** `lib/aether-min` + `aether-domain` + `aether-propose` + `aether-orch` + examples 01–11  
**Last offline suite:** `notes/last-run-report.md`

## Claim under test

On \(S_{\mathrm{Aether}}\) (long-running self-modifying agent systems), the
evolvable core can stay in pure Aura (\(V_A\)) with controlled, metered
escapes \(E\) on the world/propose edge only.

## Constructive evidence

| Probe | Axes | Result | Evolvable-core escapes |
|-------|------|--------|-------------------------|
| [01-single-loop](../examples/01-single-loop/) | A B F | PASS commit/skip/rollback | 0 |
| [02-business-signal](../examples/02-business-signal/) | A B F | PASS fail-rate decide (`aether-domain`) | 0 |
| [03-researcher-executor](../examples/03-researcher-executor/) | A B C E | PASS dual-role; propose pure-Aura | 0 (LLM not required) |
| [04-hot-strategy-heal](../examples/04-hot-strategy-heal/) | A B D F | PASS hot deploy + self-heal | 0 |
| [05-long-run-denseness](../examples/05-long-run-denseness/) | all smoke | PASS N=10 deploy/skip/poison-heal | 0 |
| [06-propose-edge-escape](../examples/06-propose-edge-escape/) | E | PASS rule E=0; stub E≥1; core still rolls back bad | 0 core / ≥1 propose-edge (intentional) |
| [07-proposal-schema](../examples/07-proposal-schema/) | E | PASS schema refuse + semantic rollback | 0 |
| [08-parse-proposal-wire](../examples/08-parse-proposal-wire/) | E | PASS wire parse from prose; garbage/illegal refuse | 0 core / ≥1 sim-escape |
| [09-live-minimax](../examples/09-live-minimax/) | E | PASS MiniMax-M3 live propose (manual; needs key) | 0 core / ≥1 live HTTPS |
| [10-long-n-stress](../examples/10-long-n-stress/) | A B D F | PASS N=50 poison/heal cadence; safety-ok | 0 |
| [11-arbitrated-multi](../examples/11-arbitrated-multi/) | C E | PASS multi-propose + arbiter filters deny / prefers skip|widen | 0 |

## Metrics (practical denseness criteria)

| Metric | Target | Observed on PASS paths |
|--------|--------|-------------------------|
| Business-logic escape rate | &lt; 10–15% | **~0%** of evolvable core |
| Escape on decide/verify/rollback hot path | No | **None** |
| Safe-path rollback reliability | ≈100% | Bad proposals / poison recovered via snapshot or last-good |
| Per-round observability | Full | `aether:stats-alist` + example logs |
| Multi-round boundary health | N≥10 | Example 05 N=10; example 10 N=50; `aether:safety-ok?` at end |

## Escape inventory

See [escape-log.md](escape-log.md).

- Host config (`AURA_SANDBOX=off`, pipeline strict) is **not** counted as
  business-logic escape.
- Example 06 meters propose-edge \(E\): rule path keeps `escapes=0`; `llm-stub`
  increments `escapes` while executor verify/rollback stays pure Aura.
- Example 07 enforces a **structured proposal schema** before rebind: invalid
  kinds/bodies never touch the workspace; schema-valid harmful bodies still
  roll back via business verify.
- Live LLM (`AETHER_LLM_PROPOSE=live`) calls `llm:chat` with a strict wire
  prompt, then `aether:parse-proposal-text` + schema; invalid parse falls back
  to rule proposal (escape still counted). Wire format:
  `MUTATE|name|body|summary` / `SKIP|name||summary`.

## Gaps / residual host constraints

Workarounds remain for CLI ergonomics (not denseness failures of the claim):

- Prefer sequential `let`; multi-binding `let` can mis-bind.
- Prefer `(eq? x #t)` for verify success.
- Large module `define` bodies / multiline param lists can fail to export.
- `std/orchestrator` agent callbacks did not close over `aether-min` module
  state; dual-role uses function roles instead.
- `std/hot-update` is AOT `.so` oriented; example 04 uses strategy rebind as
  the Aura-native hot path.

## Judgment

**For the claimed subspace \(S_{\mathrm{Aether}}\) and the five constructive
probes above, \(V_A\) is practically dense on the evolvable core:** business
observe/decide/mutate/verify/rollback/hot-heal run in pure Aura with zero
core escapes and recoverable failure paths.

This does **not** claim denseness over all of \(S_{\mathrm{practical}}\)
(numerical hot paths, hard realtime, drivers, etc.).

## Library factoring (post Phase 1–2)

- **`aether-domain`** — shared admit-gate workload (1..10, fails≤4) used by probes 02–03, 05–09 so examples no longer copy-paste batch/fail helpers.
- **`aether-propose`** — schema + wire parse + rule/stub/live propose; string/schema helpers **inlined** into public entry points so free-vars survive workspace rebind (host free-var breakage across mutate).
- **`aether-orch`** — multi-proposer filter + score + pick (`aether:arbitrate`); deny-all dropped; healthy prefers skip; unhealthy prefers widen. Fully inlined public entry (same rebind free-var discipline).

## Next measurements

- Axis C residual: parallel+yield multi-agent (orch:parallel-with-yield) if host closure capture is stable enough.
- N=100+ optional if product needs longer soak; multi-tenant region isolation if needed.
- Split `aether-min` into axis modules once host module packaging is fully stable.

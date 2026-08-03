# \(S_{\mathrm{Aether}}\) denseness report (Phase 1–5)

**Date:** 2026-08-03  
**Host:** Aura (local `aura-grok`) with fixes #2566–#2570  
**Surface:** `aether-min` · `aether-mutate-policy` · `aether-domain` · `aether-propose` · `aether-orch` · `aether-region`  
**Last offline suite:** [last-run-report.md](last-run-report.md)  
**Live:** example 09 MiniMax-M3; Phase 5 multi/concurrent opt-in; overnight harness  
**CI:** structure always; denseness when Aura binary available (`.github/workflows/denseness.yml`)

---

## Claim under test

On \(S_{\mathrm{Aether}}\) (long-running self-modifying agent systems), the
**evolvable core** can stay in pure Aura (\(V_A\)) with controlled, metered
escapes \(E\) confined to the world / propose edge.

\[
P \approx A \oplus E,\quad A \in V_A
\]

Aether does **not** claim denseness over all of \(S_{\mathrm{practical}}\).

---

## Axis coverage

| Axis | Question | Evidence (probes) |
|------|----------|-------------------|
| **A** Loop completeness | Multi-round O→D→M→V→R | 01, 02, 05, 10 |
| **B** Mutation surface | Named rebind stays safe | 01–05, 10, 13 |
| **C** Orch topology | Dual → arbitrate → yield / true parallel / multi-LLM | 03, 11, 12, **17**, **20**, **21** |
| **D** Temporal adaptation | Hot deploy, poison, heal, version, freeze | 04, 05, 10, 13, **15**, **16** |
| **E** World boundary | Schema / wire / stub / live LLM multi | 03, 06–09, **20**, **21**, **22** |
| **F** Metrology | Stats, report, escape log, overnight | all + `scripts/report.sh` + overnight |

---

## Constructive evidence

| Probe | Axes | Result | Core \(E\) |
|-------|------|--------|------------|
| [01-single-loop](../examples/01-single-loop/) | A B F | PASS commit/skip/rollback | 0 |
| [02-business-signal](../examples/02-business-signal/) | A B F | PASS fail-rate decide | 0 |
| [03-researcher-executor](../examples/03-researcher-executor/) | A B C E | PASS dual-role pure-Aura propose | 0 |
| [04-hot-strategy-heal](../examples/04-hot-strategy-heal/) | A B D F | PASS hot deploy + self-heal | 0 |
| [05-long-run-denseness](../examples/05-long-run-denseness/) | smoke | PASS N=10 deploy/skip/poison-heal | 0 |
| [06-propose-edge-escape](../examples/06-propose-edge-escape/) | E | PASS rule E=0; stub E≥1; core guarded | 0 core |
| [07-proposal-schema](../examples/07-proposal-schema/) | E | PASS schema refuse + semantic rollback | 0 |
| [08-parse-proposal-wire](../examples/08-parse-proposal-wire/) | E | PASS wire parse; garbage/illegal refuse | 0 core |
| [09-live-minimax](../examples/09-live-minimax/) | E | PASS MiniMax-M3 live propose (manual) | 0 core / ≥1 HTTPS |
| [10-long-n-stress](../examples/10-long-n-stress/) | A B D F | PASS N=50 poison/heal; safety-ok | 0 |
| [11-arbitrated-multi](../examples/11-arbitrated-multi/) | C E | PASS multi-propose + arbiter | 0 |
| [12-parallel-yield](../examples/12-parallel-yield/) | C | PASS fanout + yield + single executor | 0 |
| [13-multi-tenant-region](../examples/13-multi-tenant-region/) | B D | PASS name-isolated multi-tenant rebind | 0 |
| [14-long-n-100](../examples/14-long-n-100/) | A B D F | PASS N=100 poison/heal soak; safety-ok | 0 |
| [15-version-coexist](../examples/15-version-coexist/) | D B | PASS active+golden coexist; poison active only | 0 |
| [16-drift-freeze](../examples/16-drift-freeze/) | D A | PASS freeze on drift; heal unfreezes | 0 |
| [17-true-parallel](../examples/17-true-parallel/) | C | PASS orch `parallel-yield` fanout after rebind | 0 |
| [18-multi-bind-let](../examples/18-multi-bind-let/) | A B | PASS multi-bind `let` unpack after rebind (H1) | 0 |
| [19-hot-strategy](../examples/19-hot-strategy/) | D | PASS `std/hot-strategy` swap + heal (not AOT) | 0 |
| [20-multi-live-propose](../examples/20-multi-live-propose/) | C E | PASS multi stub/live propose + pure-Aura arbiter | 0 core / ≥3 propose \(E\) |
| [21-concurrent-propose-yield](../examples/21-concurrent-propose-yield/) | C E | PASS fanout+yield+single mutator; poison rollback | 0 core / ≥3 propose \(E\) |
| [22-overnight-mutate](../examples/22-overnight-mutate/) | A E F | PASS budget-bounded continuous mutate driver | 0 core |

Offline automation covers **01–08, 10–22**. Live **09** and live modes of **20/21** are opt-in (MiniMax-M3 when key present). Overnight: `scripts/overnight-mutate.sh`.

---

## Metrics (practical denseness criteria)

| Metric | Target | Observed on PASS paths |
|--------|--------|-------------------------|
| Business-logic escape rate | &lt; 10–15% | **~0%** of evolvable core |
| Escape on decide/verify/rollback | No | **None** |
| Safe-path rollback reliability | ≈100% | Bad proposals / poison recovered via snapshot or last-good |
| Per-round observability | Full | `aether:stats-alist` + `RESULT` lines |
| Multi-round boundary health | N≥10 | N=10 (05), N=50 (10), **N=100** (14); `aether:safety-ok?` |
| Multi-tenant isolation | No cross-talk | 13: mutate A leaves B metrics unchanged |
| Orch without external queue | In \(V_A\) | 11–12 pure-Aura arbiter + yield fanout |

---

## Escape inventory

See [escape-log.md](escape-log.md).

| Class | Where | Counted as core \(E\)? |
|-------|--------|-------------------------|
| Host CLI (`AURA_SANDBOX=off`, pipeline strict) | runner | **No** |
| Propose-edge stub / live LLM | 06, 09 | Propose-edge only; metered |
| Schema / wire refuse | 07, 08 | Prevents unstructured rebind |
| Fiber / `orch:parallel` residual | host | **No** — PASS uses sequential-yield |

Wire format (live/stub): `MUTATE|name|body|summary` or `SKIP|name||summary`.

---

## Libraries (factored surface)

| Lib | Role |
|-----|------|
| `aether-min` | Thin facade re-export (`min-version` 3) |
| `aether-measure` | Axis F stats (authoritative) |
| `aether-mutate-policy` | Axis B install / safety / rebind |
| `aether-loop` | Axis A observe/decide/verify |
| `aether-loop-once` | Axis A `loop-once` (sole large export) |
| `aether-domain` | Shared admit-gate workload |
| `aether-propose` | Schema, wire, rule/stub/live propose |
| `aether-orch` | Arbitrate + dual-mode fanout |
| `aether-region` | Multi-tenant named gates |

Details: [lib/README.md](../lib/README.md).

---

## Host residuals (not denseness failures)

Workarounds for CLI / packaging — claim is about \(S_{\mathrm{Aether}}\) semantics, not host polish.
Actionable table + Aura issues: [host-residuals.md](host-residuals.md)
(tracker [#2578](https://github.com/cybrid-systems/aura/issues/2578); children #2579–#2582).

1. Multi-binding `let` OK for independent bindings after seed (probe 18); avoid multi-bind *before* install-source (module free-var quirk).  
2. Verify with `(eq? x #t)`.  
3. Large trailing `define` in multi-export modules may fail → sole-export `aether-loop-once`.  
4. Cross-module stats (H4) improved — `aether-measure` survives rebind (2026-08-03).  
5. Fiber residual → dual-mode `aether:fanout` (17 requires parallel).  
6. `std/hot-update` AOT-oriented → strategy rebind (04).

---

## Judgment (Phase 1–3)

**On the claimed subspace \(S_{\mathrm{Aether}}\) and the constructive probe suite
(offline suite incl. N=100 + 1 live), \(V_A\) is practically dense on the evolvable core.**

Supporting facts:

- O→D→M→V→R, business decide, hot heal, N=50/100 soak, multi-tenant isolation,
  multi-propose arbitration, and yield-disciplined fanout all run in pure Aura
  with **zero core escapes** on PASS paths.  
- World I/O (\(E\)) is confined to the **propose edge**, schema-gated, and
  metered; invalid proposals never rebind; bad semantics still roll back.  
- Axis C is covered without an external queue: dual-role → arbiter → yield fanout.  
- Host packaging limits are documented and bypassed with isomorphic pure-Aura
  shapes (same-module stats, sequential-yield), not with FFI escapes.

This **strengthens** the Aura Unify thesis at Dim 1+2. It does **not** prove
denseness for numerical kernels, hard realtime, drivers, or arbitrary product domains.

---

## Phase map

| Phase | Scope | Status |
|-------|--------|--------|
| 1 | Minimal loop, business signal, dual-role | **Landed** |
| 2 | Hot heal, long-run N=10, first report | **Landed** |
| 3 | Propose E, schema/wire/live, N=50–100, orch, yield, axis split, multi-tenant, CI | **Landed** |
| 4 | Version coexist (15); drift freeze (16); true parallel (17); multi-bind (18); hot-strategy (19); A+F axis extract (min facade v3) | **Landed** |
| **5** | Multi live/stub propose + arbiter (**20**); concurrent fanout+yield (**21**); overnight harness (**22** + `overnight-mutate.sh`); **no new span** for concurrent LLM agents | **Landed** |
| Upstream-blocked | Remaining host polish (see residuals) | [host-residuals.md](host-residuals.md) |

**Phase 5 decision (issue #3):** concurrent LLM multi-agent verification stays in
**Aether** denseness probes. Do not open a separate Unify span / product EDSL
repo for this theme.

---

## How to reproduce

```bash
./scripts/check-structure.sh        # no Aura binary required
./scripts/report.sh                 # offline suite → notes/last-run-report.md
./scripts/run-all.sh                # same suite
source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/09-live-minimax/main.aura
```

---

## Remaining outside denseness bar

- Upstream host fixes (H1–H8) then optional Aether follow-ups listed in host-residuals.  
- Broader Unify spans outside \(S_{\mathrm{Aether}}\) (not Aether’s sole job).  
- Product systems that *use* Aether shapes (real policies, multi-session) — separate programs.

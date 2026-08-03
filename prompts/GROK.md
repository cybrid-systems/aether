# Grok Prompt — Aether

You are helping build **Aether**, the first concrete **span / denseness probe** of Aura Unify.

- Repository: https://github.com/cybrid-systems/aether  
- Parent language / runtime: https://github.com/cybrid-systems/aura  
- Local host often: `../aura-grok` (binary + `lib/std`)  
- License: Apache 2.0  

This file is living. Keep it aligned with `README.md` when scope or phase changes.

---

## Mission (locked)

Prove, with runnable systems and measured escapes, that Aura’s space \(V_A\) is
**dense on** \(S_{\mathrm{Aether}}\):

> Long-running, self-modifying Agent systems whose primary object is their own
> logic — under Observe → Decide → Safe Mutation → Verify → Rollback — with
> safety and observability as first-class semantics, and world I/O confined to a
> thin, audited escape set \(E\).

Focus dimensions only:

1. **Reflection & Safe Mutation**  
2. **Agent & Orchestration**  

You are **not** proving denseness over all practical software. You are not
filling arbitrary domains (KV, hard realtime, drivers, ML kernels) unless they
directly serve the agent closed-loop.

---

## What Aether is / is not

| Is | Is not |
|----|--------|
| Span project for Dim 1+2 | General app framework |
| Composer of Aura stdlib + metrology | Fork / reimplementation of Aura engine |
| Closed-loop systems + escape accounting | One-shot scripts without measure |
| Evidence that \(P \approx A \oplus E\) on agent systems | Mathematical denseness of all of \(S\) |

**Aura** = basis vectors (runtime, primitives, thin stdlib).  
**Aether** = linear combinations that fill \(S_{\mathrm{Aether}}\) and produce denseness evidence.

Prefer existing surfaces:

`std/agent`, `std/mutate`, `std/orchestrator`, `std/query`, `std/workspace`,
`std/hot-update*`, `std/safe-refactor`, `std/heal`, `std/stats`, `std/llm`,
`std/persist`, `std/capability`, …

---

## Canonical loop

```
Observe → Decide → Safe Mutation → Verify → Rollback (if needed) → Observe
```

Hard requirements on every implementation:

1. Prefer pure Aura + existing stdlib.  
2. Every mutation goes through safety guards (`mutate:boundary-safe?`,
   `mutate:atomic-batch-safe`, snapshots / `safe-refactor` / workspace rollback
   as appropriate).  
3. Full observability: operator, target, decision, success/failure; support rollback.  
4. Minimize escapes. Any escape → immediate entry in `notes/escape-log.md`.  
5. Modular code, discoverable names, ready to grow into multi-agent orch.  
6. When measuring, advance `lib/measure/` and denseness notes — demos without
   metrology are incomplete for the mission.

---

## Axes to span (inside \(S_{\mathrm{Aether}}\) only)

| Axis | Span target |
|------|-------------|
| **A. Loop completeness** | Multi-round O→D→M→V→R without boundary leak |
| **B. Mutation surface** | Safe mut of decide / router / verifier / topology |
| **C. Orch topology** | Single → researcher/executor → arbitrated multi → parallel+yield |
| **D. Temporal adaptation** | Hot strategy, versions, heal, drift freeze |
| **E. World boundary** | LLM/tools/IO as capability-gated \(E\) on the *propose* edge when possible |
| **F. Metrology** | Escape rate/cost, loop stats, denseness report |

### Suggested layout

```
lib/loop/            # A
lib/mutate-policy/   # B
lib/orch/            # C
lib/adapt/           # D
lib/boundary/        # E
lib/measure/         # F
examples/01-…        # ordered denseness probes
notes/escape-log.md
notes/denseness-report.md
```

---

## Phase plan

### Phase 1–3 (landed — denseness bar met)

**Offline:** `01`–`08`, `10`–`14` via `./scripts/report.sh`.  
**Live:** `09` MiniMax-M3 — `source ./scripts/env-minimax.sh` then run-aura.  
**Libs:** `aether-min`, `aether-mutate-policy`, `aether-domain`, `aether-propose`,
`aether-orch`, `aether-region` (+ narrow measure/loop).  
**Key:** `~/code/keys/minimax`; base `https://api.minimaxi.com/v1`; model `MiniMax-M3`.  
**Host:** Aura #2566–#2570.  
**CI:** `.github/workflows/denseness.yml` (structure always; suite when Aura binary available).

Success bar: evolvable core in pure Aura; full observe/rollback; honest escape log;
business-logic escape rate ≪ 10–15%. **Met** — see `notes/denseness-report.md` judgment.

Phase highlights:

| Phase | Landed |
|-------|--------|
| 1 | 01–03 loop / business / dual-role |
| 2 | 04–05 hot heal + N=10 + first report |
| 3 | 06–09 propose \(E\); 10–14 N-stress; 11–12 orch; axis split; 13 multi-tenant; CI; final report |
| 4 | 15 version coexist; 16 drift freeze; 17 true parallel fanout |

### Upstream-blocked (see `notes/host-residuals.md`)

- True fiber parallel when H5/H6 fixed  
- Extract A+F from `aether-min` when H3/H4 fixed  

### Not Aether’s job alone

Concurrency stress, numerical hot paths, hardware/OS extremes — only if required
by a closed-loop case; otherwise leave to broader Unify span work.

---

## Escape & denseness discipline

**Escape** = any leave from pure Aura for required semantics or performance
(FFI, external service, C++ prim, shell, etc.).

For each escape, log in `notes/escape-log.md`:

```
## [Date] Short title
- Location: file / function
- Reason: why pure Aura was insufficient
- Escape mechanism: FFI / external service / C++ primitive / other
- Impact: business logic vs performance-critical path
- Mitigation: capability boundary, isolation, future plan
```

Treat escapes on decide / verify / rollback hot paths as **high severity**
against the denseness claim unless isolated and justified.

Practical denseness targets (tunable; see README):

- Business-logic escape rate low (guideline &lt; 10–15%)  
- Safe-path rollback ≈ reliable  
- Per-round observability complete  
- Multi-round (N≥10) boundary/quota health  

Pre-declared failure modes:

- Decide/verify *requires* external services  
- Unguarded string-patch mutation as the only path  
- Multi-agent only via external orchestrator/queue  

---

## Style guidelines

- Match Aura / existing `.aura` style (Lisp-like, clear `export`, `try`/`catch`).  
- Prefer `(require "std/xxx" all:)`.  
- Name modules so agents and humans can discover them.  
- Comment safety invariants at mutation sites.  
- Prefer small, testable increments over large incomplete systems.  
- Do not invent primitives that already exist in Aura stdlib/engine without checking.  

---

## When generating code

1. Put reusable modules under `lib/<axis>/`; demos under `examples/NN-name/`.  
2. Keep each file focused.  
3. Any non-Aura dependency or FFI → update `notes/escape-log.md` in the same change.  
4. Prefer offline / no-LLM paths for core correctness demos; LLM is optional on propose edge.  
5. After generating, briefly state:  
   - Which axes (A–F) this advances  
   - What part of O→D→M→V→R it implements  
   - Escapes remaining and open safety questions  
   - How to run against local Aura (e.g. `../aura-grok/build/aura`) when known  

### Runtime note

Host binary is typically:

```bash
../aura-grok/build/aura
```

Compose with Aura’s `lib/std`; do not vendor engine sources into Aether.

---

## Success metric (near-term)

A **runnable** example where an agent modifies a piece of its own decision or
processing logic under mutation guards, observes the outcome, rolls back on
verify failure, and leaves an honest escape + loop-stats trail — with the
**evolvable core** expressed in pure Aura.

Longer-term success is a denseness report for \(S_{\mathrm{Aether}}\), not a
collection of unrelated demos.

---

Update this prompt when architecture, phase, or denseness thresholds evolve.

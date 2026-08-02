# Aether

**Self-evolving Agent closed-loops on Aura — the first denseness probe of Aura Unify.**

Aether is not a general-purpose app framework and not a reimplementation of the Aura
stdlib. It is the first **concrete span project** of [Aura Unify](https://github.com/cybrid-systems/aura):
an empirical test of whether Aura’s native space \(V_A\) can densely cover the
highest-leverage semantic region for AI-native software:

- **Dimension 1 — Reflection & Safe Mutation**
- **Dimension 2 — Agent & Orchestration**

> Aura supplies a machine-friendly basis.  
> Aether asks whether that basis is dense enough for long-running, self-modifying
> Agent systems — with measurable escape rates.

## The subspace Aether claims: \(S_{\mathrm{Aether}}\)

Aether does **not** try to prove \(V_A \approx S_{\mathrm{practical}}\) (all practical software).
That is the long-horizon Unify program.

Aether claims only:

\[
S_{\mathrm{Aether}} \subset S_{\mathrm{practical}}
\]

**Long-running systems whose primary computational object is their own logic**,
under observation, decision, safe mutation, verification, and rollback.

A system is in \(S_{\mathrm{Aether}}\) when it simultaneously has:

1. **Code / strategy as first-class object** — AST, rules, policies, decision functions  
2. **Closed-loop control** — Observe → Decide → Safe Mutation → Verify → Rollback  
3. **Continuous time** — multi-round, interruptible, recoverable (not one-shot scripts)  
4. **Safety & observability as semantics** — boundary, quota, rollback, metrics are not afterthoughts  
5. **Boundary-able world interface** — LLM, tools, and IO live in a controlled escape set \(E\)

### Denseness proposition (defensible form)

> On \(S_{\mathrm{Aether}}\), \(V_A\) is dense for the **evolvable core**:  
> closed-loop business logic stays almost entirely in pure Aura; necessary escapes
> \(E\) are rare, metered, capability-isolated, and do not break post-mutation
> verification or rollback.

If this subspace cannot achieve low escape rates, the broader Unify thesis is
weakened at its most leveraged point.

### Explicitly out of scope (Aether Phase 1–3)

| Out of scope | Why |
|--------------|-----|
| Numerical / ML hot paths, hard realtime, MMIO, drivers | Global Unify pressure tests later |
| Rebuilding Aura stdlib | Aura already provides the basis vectors |
| Proving mathematical denseness of all software | No agreed complete basis; Aether does constructive measurement only |
| Generic domain fill (KV, ETL-as-product, …) | Only when they *serve* the agent closed-loop |

## Canonical closed loop

```
Observe  →  Decide  →  Safe Mutation  →  Verify  →  Rollback (if needed)  →  Observe
```

Invariants we care about:

- Mutation only through typed / boundary-guarded paths  
- Full observability (operator, target, decision, outcome)  
- Atomic batch + safe yield  
- Rollback to a consistent prior state  
- Evolvable core stays in pure Aura; world I/O is thin, audited \(E\)

## Orthogonal axes inside \(S_{\mathrm{Aether}}\)

Aether spans **this** space — not the whole software stack:

| Axis | Question |
|------|----------|
| **A. Loop completeness** | Can O→D→M→V→R run fully and stably for many rounds? |
| **B. Mutation surface** | Decision fns, tool routers, verifiers, orch topology — still safe? |
| **C. Orchestration topology** | Single agent → dual role → arbitrated multi-agent → parallel + yield |
| **D. Temporal adaptation** | Hot strategy swap, version coexistence, self-heal, drift freeze |
| **E. World boundary** | LLM / tools / IO as low-dimensional, capability-gated \(E\) |
| **F. Metrology** | Escape rate, escape cost, rollback coverage, denseness report |

## Relationship to Aura

| Layer | Owner | Role |
|-------|--------|------|
| Runtime, primitives, typed mutation, boundary | Aura | Basis |
| Thin stdlib surfaces (`std/agent`, `mutate`, `orchestrator`, `query`, `hot-update`, `workspace`, `stats`, …) | Aura | Callable operators |
| **Composed closed systems + escape accounting + denseness evidence** | **Aether** | Linear span / coverage proof for Dim 1+2 |

**Local development** is expected against a checkout such as `../aura-grok` (or upstream Aura):

```bash
./scripts/run-aura.sh examples/01-single-loop/main.aura
# expects: PASS: O→D→M→V→R closed loop (commit + skip + rollback)
```

`scripts/run-aura.sh` sets `AURA_PATH` (Aura `lib/` + Aether `lib/`), `AURA_SANDBOX=off` (CLI mutation demos), and `AURA_PIPELINE_STRICT=0` when needed.

Aether should **compose** Aura surfaces, not fork engine code.

## Practical denseness criteria (tunable)

For a target system \(P \in S_{\mathrm{Aether}}\):

\[
P \approx A \oplus E, \quad A \in V_A
\]

| Metric | Suggested threshold | Meaning |
|--------|---------------------|---------|
| Business-logic escape rate | &lt; 10–15% | By module or critical path |
| Escape on hot decide/verify/rollback path | No (LLM only on propose edge) | Core loop stays in \(V_A\) |
| Safe-path rollback reliability | ≈ 100% | Verify failure restores consistent state |
| Per-round observability | Full fields | operator / target / decision / outcome |
| Multi-round boundary health | N≥10 baseline | No hold/quota leak across rounds |

**Failure modes** (pre-declared):

- Decide / verify *requires* external services → narrative damaged  
- Mutation only via unguarded string patches → isomorphism failure  
- Multi-agent only via external queue/orchestrator → axis C uncovered  

## Project structure

```
aether/
├── README.md
├── LICENSE
├── scripts/
│   └── run-aura.sh          # Host Aura runner (AURA_PATH, sandbox)
├── prompts/
│   └── GROK.md              # Living prompt for continued generation
├── lib/
│   ├── aether-min.aura         # A+B+F closed-loop facade (embeds A+F)
│   ├── aether-mutate-policy.aura  # Axis B
│   ├── aether-measure.aura     # Axis F (narrow / pre-rebind)
│   ├── aether-loop.aura        # Axis A O/D/V helpers
│   ├── aether-propose.aura     # Propose edge (rule / stub / live)
│   ├── aether-domain.aura      # Shared gate workload
│   ├── aether-orch.aura        # Multi-propose arbiter + yield fanout (C)
│   ├── aether-region.aura      # Multi-tenant named regions
│   └── README.md               # Lib map + host packaging notes
├── examples/
│   ├── _template/              # Copy to add a new probe
│   ├── README.md               # Probe index + conventions
│   ├── 01–09 denseness + live MiniMax
│   ├── 10-long-n-stress/ … 14-long-n-100/
│   └── 13-multi-tenant-region/
├── .github/workflows/denseness.yml
└── notes/
    ├── escape-log.md
    ├── host-residuals.md
    └── denseness-report.md
```

## Span order (execution path)

| Phase | Probes | Milestone |
|-------|--------|-----------|
| **1** | 01–03 | Minimal loop, business decide, dual-role; core \(E\)=0 |
| **2** | 04–05 | Hot heal + N=10 harness; first denseness write-up |
| **3** | 06–14 | Propose \(E\), schema/wire/live LLM, N=50–100, arbiter, yield, multi-tenant, CI |
| **4** | 15–16 | Version coexistence + drift freeze (Axis D residual) |

| # | Probe | Axes | Answers |
|---|-------|------|---------|
| 01 | Single closed loop | A B F | Pure Aura O→…→R? |
| 02 | Business fail-rate | A B F | Decide beyond engine counters? |
| 03 | Researcher + executor | A B C E | Dual-role; \(E\) on propose only? |
| 04 | Hot strategy + heal | A B D F | Temporal adaptation isomorphic? |
| 05 | Long-run N=10 | smoke | Multi-round boundary health? |
| 06 | Propose-edge \(E\) meter | E | Stub \(E\) isolated from core? |
| 07 | Proposal schema | E | Invalid never rebinds? |
| 08 | Wire parse | E | LLM-shaped text → schema → exec? |
| 09 | Live MiniMax-M3 | E | Real HTTPS propose edge? *(manual)* |
| 10 | Long-N N=50 | A B D F | Stress still pure + safety-ok? |
| 11 | Arbitrated multi | C E | Multi-propose without external queue? |
| 12 | Parallel + yield | C | Fanout + yield + single mutator? |
| 13 | Multi-tenant region | B D | Name-isolated rebind? |
| 14 | Long-N N=100 | A B D F | Longer soak still pure + safety-ok? |

## Escape discipline

Every leave from pure Aura (\(V_A\)) must be recorded in [`notes/escape-log.md`](notes/escape-log.md):

- Location, reason, mechanism (FFI / external service / C++ prim / other)  
- Impact (business logic vs performance path)  
- Mitigation (capability, isolation, future plan)  

Escapes on the evolvable core are treated as **evidence against** denseness until justified and isolated.

## License

Apache License 2.0 (same as Aura)

## Status — Phase 1–3 complete

**Judgment:** on \(S_{\mathrm{Aether}}\), \(V_A\) is **practically dense** on the
evolvable core (offline suite incl. N=100; live 09 opt-in). Full write-up:
[`notes/denseness-report.md`](notes/denseness-report.md).

```bash
./scripts/check-structure.sh        # no Aura binary required (also CI)
./scripts/report.sh                 # offline denseness suite → notes/last-run-report.md
./scripts/run-all.sh
source ./scripts/env-minimax.sh
./scripts/run-aura.sh examples/09-live-minimax/main.aura
```

| Example | Proves |
|---------|--------|
| **01** | O→D→M→V→R baseline (commit / skip / rollback) |
| **02** | Decide from **business fail-rate** |
| **03** | Dual-role propose edge + executor guards |
| **04** | Hot strategy deploy + **self-heal** |
| **05** | Multi-round denseness harness (N=10) |
| **06** | Propose-edge **\(E\) metering** (rule / stub) |
| **07** | **Schema gate** — invalid refuse; bad semantics rollback |
| **08** | **Wire parse** — prose/garbage/illegal → structured proposal |
| **09** | **Live MiniMax-M3** propose edge |
| **10** | **N=50** poison/heal denseness stress |
| **11** | **Arbitrated** multi-propose (pure Aura) |
| **12** | **Yield fanout** multi-propose + single executor |
| **13** | **Multi-tenant** name-isolated rebind |
| **14** | **N=100** denseness soak |
| **15** | **Version coexistence** (active + golden peer) |
| **16** | **Drift freeze** (refuse mutate while drifted) |

New probe: copy `examples/_template` → `examples/NN-name`, add to `run-all.sh` / `report.sh` if offline.

Host residual tracker: [`notes/host-residuals.md`](notes/host-residuals.md).  
See [`examples/README.md`](examples/README.md), [`lib/README.md`](lib/README.md), [`prompts/GROK.md`](prompts/GROK.md).

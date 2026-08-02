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

### Explicitly out of scope (for Aether Phase 1–2)

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
# example once examples exist
echo '(load "examples/01-single-loop/main.aura")' | ../aura-grok/build/aura
```

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

## Project structure (planned)

```
aether/
├── README.md
├── LICENSE
├── prompts/
│   └── GROK.md              # Living prompt for continued generation
├── lib/
│   ├── loop/                # Axis A — standard closed-loop skeleton
│   ├── mutate-policy/       # Axis B — what may mutate, how to batch/verify
│   ├── orch/                # Axis C — roles, arbitration, shared mut policy
│   ├── adapt/               # Axis D — hot strategy, versions, heal, freeze
│   ├── boundary/            # Axis E — LLM/tool/IO + escape accounting
│   └── measure/             # Axis F — rates, loop stats, denseness report
├── examples/
│   ├── 01-single-loop/      # Minimal pure-Aura closed loop (no LLM required)
│   ├── 02-researcher-executor/
│   ├── 03-hot-strategy-heal/
│   └── 04-long-run-denseness/
└── notes/
    ├── escape-log.md        # Every necessary escape
    └── denseness-report.md  # Aggregated θ, ρ, conclusions
```

## Span order (execution path)

| # | Example | Axes | Answers |
|---|---------|------|---------|
| 1 | Minimal self-evolving loop (no LLM) | A+B+F | Can pure Aura finish O→…→R? |
| 2 | Business-signal decisions (error rate / latency thresholds) | A+B | Decision beyond engine counters? |
| 3 | Researcher + executor (LLM may propose) | C+E | Can \(E\) stay on the propose edge? |
| 4 | Hot strategy + self-heal | D | Does temporal adaptation stay isomorphic? |
| 5 | Long-run denseness harness + report | all | Defensible coverage conclusion? |

Phase 1 success: examples 1–3 with low business escape and full observe/rollback.  
Phase 2 success: examples 4–5 and a first `notes/denseness-report.md` for \(S_{\mathrm{Aether}}\).

## Escape discipline

Every leave from pure Aura (\(V_A\)) must be recorded in [`notes/escape-log.md`](notes/escape-log.md):

- Location, reason, mechanism (FFI / external service / C++ prim / other)  
- Impact (business logic vs performance path)  
- Mitigation (capability, isolation, future plan)  

Escapes on the evolvable core are treated as **evidence against** denseness until justified and isolated.

## License

Apache License 2.0 (same as Aura)

## Status

Early construction — scope and denseness criteria locked; implementation skeleton pending.

First concrete deliverable: **example 01** — a minimal self-evolving Agent closed-loop
that can observe, decide, mutate under guards, verify, and roll back, mostly in pure Aura.

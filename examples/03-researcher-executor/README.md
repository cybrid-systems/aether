# 03 — Researcher + Executor

Denseness probe for **Axes C + E**: dual-role topology with the propose edge
separated from the evolvable mutation core.

## Roles

| Role | Responsibility | May leave \(V_A\)? |
|------|----------------|--------------------|
| **researcher** | Business signal → **proposal** `(kind name body summary)` | Only here (optional LLM later) |
| **executor** | `aether:loop-once` + business verify | **No** — pure Aura + aether-min |

The executor never treats a proposal as authority: every mutate goes through
snapshot → rebind → verify → rollback on failure.

## Scenario

Same gate workload as example 02 (budget fails ≤ 4 on `1..10`):

1. Researcher auto-proposes **widen** → executor **commit**  
2. Researcher auto-proposes **skip** → executor **skip**  
3. Researcher proposes **deny-all** → executor **rollback**  

## Run

```bash
./scripts/run-aura.sh examples/03-researcher-executor/main.aura
```

Expected:

```text
PASS: dual-role loop (researcher propose + executor guard)
escapes: 0 core; propose edge pure-Aura (LLM optional, not required)
```

## Design notes

- Roles are plain functions (not `std/orchestrator` mailboxes): orch callbacks
  currently cannot close over `aether-min` module state (`*aether-stats*`).
  Function roles still demonstrate propose/execute separation for denseness.
- Result cells use `set!` after calls (more reliable than `define` from large RHS
  on the CLI host).
- LLM is **not** required for PASS. A future flag can fill the researcher only;
  executor stays unchanged so \(E\) stays on the propose edge.

## Escapes

- **PASS path:** none in evolvable core; propose edge is pure Aura rules.  
- **If LLM enabled later:** log in `notes/escape-log.md` as propose-edge only.

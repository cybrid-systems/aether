# 20 — Multi live/stub propose + pure-Aura arbiter (Phase 5)

**Aether issue #1.** Multiple agents each propose on the world edge; arbitration,
decide, mutate, verify, and rollback stay in pure Aura.

```
Agent A ──propose──┐
Agent B ──propose──┼── pure-Aura arbiter ── single executor ── M/V/R
Agent C ──propose──┘
```

## Offline (CI / `run-all`)

Default path uses **stub** multi-propose (no network). Each agent bumps
`escapes` once (propose-edge \(E\)); arbiter filters deny; single executor commits.

```bash
./scripts/run-aura.sh examples/20-multi-live-propose/main.aura
```

## Live (opt-in)

Same topology; each agent calls `aether:propose` with `AETHER_LLM_PROPOSE=live`.
`run-aura.sh` auto-loads MiniMax-M3 from `~/code/keys/minimax` when present.

```bash
AETHER_LLM_PROPOSE=live ./scripts/run-aura.sh examples/20-multi-live-propose/main.aura
# or: source ./scripts/env-minimax.sh  (also sets live)
```

| Layer | Behavior |
|-------|----------|
| Propose | 3 agents (stub or live LLM) → wire/schema |
| Arbiter | pure Aura (`aether:arbitrate`) — filters deny, prefers widen/skip |
| Executor | single mutator; garbage → `refuse`, never rebinds |
| Core \(E\) | 0 on decide/verify/rollback |

## Not a new span

Concurrent LLM agents remain **Aether denseness probes** (axes C+E), not a
product multi-agent EDSL or a new Unify span.

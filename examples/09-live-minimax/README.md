# 09 — Live MiniMax-M3 propose edge

Uses **MiniMax-M3** (OpenAI-compatible) only on the researcher **propose edge**.
The executor still schema-validates and business-verifies every proposal.

## Setup

Key file (raw token): `~/code/keys/minimax`

```bash
source ./scripts/env-minimax.sh
# sets LLM_API_KEY from ~/code/keys/minimax
#     LLM_BASE_URL=https://api.minimaxi.com/v1
#     LLM_MODEL=MiniMax-M3
#     AETHER_LLM_PROPOSE=live

./scripts/run-aura.sh examples/09-live-minimax/main.aura
```

## What is measured

| Layer | Behavior |
|-------|----------|
| Propose | `llm:chat` → wire parse → schema |
| Escape | `aether:stats` `escapes` ≥ 1 |
| Executor | unchanged pure `aether-min` path |

If the model returns non-wire prose, parse fails and we fall back to a rule
proposal while still counting the escape (fail-soft denseness).

## Not in `run-all.sh`

Needs network + secret key. CI stays offline with examples 01–08.

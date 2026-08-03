# Aura anomaly log (overnight / long-run mining)

Overnight harness appends **session open/close** and **per-anomaly** entries here.
Use them to open [Aura issues](https://github.com/cybrid-systems/aura/issues) or Aether
follow-ups when symptoms are stable.

Do **not** re-log known packaging residuals already in
[host-residuals.md](host-residuals.md) as denseness failures.

---

## How to file an issue from logs

1. Open the anomaly entry under **Sessions** (table + excerpt + repro).
2. Open the per-invocation file: `notes/overnight-invocations/<session>-invNNNN.log`.
3. Grep machine lines:
   ```bash
   grep -E '^(WAVE |RESULT |DIAG |LOG_|INV_STATUS|error:)' notes/overnight-invocations/* | tail -50
   grep INV_STATUS notes/.overnight-run.log | tail -20
   ```
4. Paste into the issue:
   - **Title** from “Suggested issue title”
   - **Repro** bash block (already in anomaly entry)
   - **WAVE / RESULT / DIAG** lines
   - Attach the `invNNNN.log` file if large
5. Classify:
   | Symptom | Where to file |
   |---------|----------------|
   | `eval_flat`, unbound after rebind, fiber/orch panic | **Aura** host residual |
   | schema refuse / rollback on intentional poison | usually **OK denseness** |
   | provider 429 / quota | **not Aura** — rate/budget |
   | driver FAIL without host error | **Aether** denseness/driver |

---

## Template (manual)

```
## [YYYY-MM-DDThh:mm:ssZ] Short title
- Severity: crash | fail | quota | warn
- Location: example / harness inv=
- Detail: what happened
- RESULT: ...
- WAVE: ...
- Repro: (command + env)
- Host: aura_sha / aether_sha / AURA_BIN
- Action: Aura issue link or “needs more runs”
```

---

## Sessions

Harness appends below via `scripts/overnight-mutate.sh`.

## Session open `20260803T230901+0800` (2026-08-03T15:09:01Z)

- Aether `af0cb85` / Aura `e94d3da2`
- Mode `stub` hard_stop: duration MAX_MINUTES=1
- Inv dir: `/home/dev/code/grok-dev/aether/notes/overnight-invocations` run log: `/home/dev/code/grok-dev/aether/notes/.overnight-run.log`

## Session close `20260803T230901+0800` (2026-08-03T15:09:04Z)

| Metric | Value |
|--------|-------|
| Invocations | 1 / 1 |
| PASS | 1 |
| FAIL | 0 |
| CRASH | 0 |
| Quota signals | 0 |
| Elapsed_sec | 3 |
| Est live LLM calls | ~36 |
| Mode | stub |
| Hard stop | duration MAX_MINUTES=1 |
| Aether / Aura | `af0cb85` / `e94d3da2` |
| Run log | `/home/dev/code/grok-dev/aether/notes/.overnight-run.log` |
| Inv dir | `/home/dev/code/grok-dev/aether/notes/overnight-invocations` |

**No driver FAIL/CRASH this session** — no Aura issue required unless quota-only notes above.

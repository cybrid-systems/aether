# Aura anomaly log (overnight / long-run mining)

Capture host crashes, verify false-negatives, rollback failures, free-var
breakage, orch/fiber anomalies, and non-deterministic PASS/FAIL under the same
seed. Promote stable cases to [Aura issues](https://github.com/cybrid-systems/aura/issues).

Do **not** re-log known packaging residuals already in
[host-residuals.md](host-residuals.md) as denseness failures.

## Template

```
## [YYYY-MM-DDThh:mm:ssZ] Short title
- Location: example / lib / harness step
- Detail: what happened
- Repro: exact command + env
- Host: aura binary / commit if known
- Action: Aura issue link or “needs more runs”
```

---

## Sessions

Harness appends session summaries via `scripts/overnight-mutate.sh`.

## [2026-08-03T14:48:31Z] overnight session summary
- Invocations: 2
- PASS: 2 FAIL: 0 crash/runner: 0
- Elapsed_sec: 188
- Mode: live (MiniMax-M3)
- Aura issues opened: **none required** (no new anomalies this multi-minute session)
- Note: budget stop at `AETHER_OVERNIGHT_MAX_MINUTES=3`; full overnight uses default 480m

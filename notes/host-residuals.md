# Host residuals (actionable)

These are **Aura host / packaging** limits observed while building Aether denseness
probes. They are **not** failures of the \(S_{\mathrm{Aether}}\) denseness claim;
PASS paths use pure-Aura workarounds. Track here until fixed upstream.

| ID | Symptom | Aether workaround | Upstream target |
|----|---------|-------------------|-----------------|
| H1 | Multi-binding `let` mis-binds | Sequential `let` only | Aura CLI / evaluator |
| H2 | Verify needs `(eq? x #t)` | Documented convention | Consistency of truthiness |
| H3 | Large trailing `define` fails to export | Keep `loop-once` on `aether-min` facade | Module export packaging |
| H4 | Cross-module free-vars / private cells die after `set-code`+rebind | Embed stats+loop in `aether-min`; inline public entries in propose/orch | Module env across mutate |
| H5 | `fiber:spawn` workers mis-capture closures | `aether:fanout-with-yield` sequential-yield | Fiber capture correctness |
| H6 | `orch:parallel` free-var after rebind (`orch-yield-safe`) | Do not use orch parallel on PASS path | std/orchestrator + rebind |
| H7 | `std/hot-update` AOT `.so` oriented | Strategy rebind (example 04) | Native hot path story |
| H8 | `define` after mutate flaky | Pre-define cells; `set!` after | Workspace rematerialize |

## When fixed, Aether follow-ups

1. **H5+H6** → re-enable true parallel probe (replace or dual-mode fanout).  
2. **H4+H3** → extract A+F fully into `aether-measure` / `aether-loop`.  
3. **H1** → simplify probe style (multi-bind `let` allowed).

## Reproduce (local)

```bash
# H5 smoke (may show identical worker results)
./scripts/run-aura.sh examples/12-parallel-yield/main.aura   # PASS via sequential-yield

# H4 regression guard: full suite must stay green after lib split attempts
./scripts/report.sh
```

## Status

- Documented in denseness-report + escape-log (12 residual).  
- No open Aether code blockers for Phase 1–3 denseness bar.  
- File Aura issues against this table when filing upstream (copy H-ids).

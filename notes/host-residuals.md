# Host residuals (actionable)

These are **Aura host / packaging** limits observed while building Aether denseness
probes. They are **not** failures of the \(S_{\mathrm{Aether}}\) denseness claim;
PASS paths use pure-Aura workarounds.

## Upstream issues (cybrid-systems/aura)

| Aether ID | Aura issue | Title |
|-----------|------------|--------|
| tracker | [#2578](https://github.com/cybrid-systems/aura/issues/2578) | Host residual tracker (Phase 3 H1–H8) |
| H1 | [#2580](https://github.com/cybrid-systems/aura/issues/2580) | Multi-binding `let` mis-binds |
| H3/H4/H8 | [#2579](https://github.com/cybrid-systems/aura/issues/2579) | Module free-vars / export / define-after-mutate residual |
| H5/H6 | [#2581](https://github.com/cybrid-systems/aura/issues/2581) | fiber:spawn mis-capture; orch:parallel free-var after rebind |
| H7 | [#2582](https://github.com/cybrid-systems/aura/issues/2582) | hot-update AOT vs pure-Aura hot strategy |
| H2 | — | Prefer `(eq? x #t)` — convention only (no issue) |

Earlier wave (closed, partial fix): [#2566](https://github.com/cybrid-systems/aura/issues/2566)–[#2570](https://github.com/cybrid-systems/aura/issues/2570).

## Residual table

| ID | Symptom | Aether workaround | Upstream target |
|----|---------|-------------------|-----------------|
| H1 | Multi-binding `let` mis-binds | Sequential `let` only | #2580 |
| H2 | Verify needs `(eq? x #t)` | Documented convention | docs |
| H3 | Large trailing `define` fails to export | Keep `loop-once` on `aether-min` facade | #2579 |
| H4 | Cross-module free-vars / private cells die after `set-code`+rebind | Embed stats+loop in `aether-min`; inline public entries | #2579 |
| H5 | `fiber:spawn` workers mis-capture closures | sequential fallback; **17** uses orch when healthy | #2581 |
| H6 | `orch:parallel` free-var after rebind (`orch-yield-safe`) | `aether:fanout` tries parallel then sequential; **17** requires parallel | #2581 |
| H7 | `std/hot-update` AOT `.so` oriented | Strategy rebind (example 04) | #2582 |
| H8 | `define` after mutate flaky | Pre-define cells; `set!` after | #2579 |

## When fixed, Aether follow-ups

1. **#2581 (H5+H6)** → re-enable true parallel probe (replace or dual-mode fanout).  
2. **#2579 (H3+H4+H8)** → extract A+F fully into `aether-measure` / `aether-loop`.  
3. **#2580 (H1)** → simplify probe style (multi-bind `let` allowed).  
4. **#2582 (H7)** → optional official hot-strategy surface in example 04.

## Reproduce (local)

```bash
./scripts/run-aura.sh examples/12-parallel-yield/main.aura   # PASS via sequential-yield
./scripts/report.sh                                          # full denseness suite
```

## Status

- Filed on Aura 2026-08-02: #2578–#2582.  
- No open Aether code blockers for Phase 1–3 denseness bar.

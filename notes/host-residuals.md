# Host residuals (actionable)

These are **Aura host / packaging** limits observed while building Aether denseness
probes. They are **not** failures of the \(S_{\mathrm{Aether}}\) denseness claim;
PASS paths use pure-Aura workarounds.

## Upstream issues (cybrid-systems/aura)

| Aether ID | Aura issue | Title |
|-----------|------------|--------|
| tracker | [#2578](https://github.com/cybrid-systems/aura/issues/2578) | Host residual tracker (Phase 3 H1–H8) — open |
| H1 | [#2580](https://github.com/cybrid-systems/aura/issues/2580) | Multi-binding `let` — **closed**; Aether 18 + simplified loop-once |
| H3/H4/H8 | [#2579](https://github.com/cybrid-systems/aura/issues/2579) | Module free-vars / export — **closed** (Aether A+F extract + sole-export rule) |
| H5/H6 | [#2581](https://github.com/cybrid-systems/aura/issues/2581) | fiber/orch parallel — **closed** (Aether 17 dual-mode fanout) |
| H7 | [#2582](https://github.com/cybrid-systems/aura/issues/2582) | hot-update AOT vs pure-Aura — **closed** (`std/hot-strategy` + Aether 19) |
| H2 | — | Prefer `(eq? x #t)` — convention only (no issue) |

Earlier wave (closed, partial fix): [#2566](https://github.com/cybrid-systems/aura/issues/2566)–[#2570](https://github.com/cybrid-systems/aura/issues/2570).

## Residual table

| ID | Symptom | Aether workaround | Upstream target |
|----|---------|-------------------|-----------------|
| H1 | Multi-binding `let` mis-binds | Independent multi-bind OK (18); sequential still fine | #2580 closed |
| H2 | Verify needs `(eq? x #t)` | Documented convention | docs |
| H3 | Large trailing `define` fails to export | `aether-loop-once` sole export (not multi-export) | #2579 |
| H4 | Cross-module free-vars / private cells die after `set-code`+rebind | Improved: stats in `aether-measure` survive rebind (2026-08-03) | #2579 |
| H5 | `fiber:spawn` workers mis-capture closures | sequential fallback; **17** uses orch when healthy | #2581 |
| H6 | `orch:parallel` free-var after rebind (`orch-yield-safe`) | `aether:fanout` tries parallel then sequential; **17** requires parallel | #2581 |
| H7 | `std/hot-update` AOT `.so` oriented | `std/hot-strategy` + example **19** (04 still ad-hoc) | #2582 closed |
| H8 | `define` after mutate flaky | Pre-define cells; `set!` after | #2579 |

## When fixed, Aether follow-ups

1. **#2581 (H5+H6)** → Aether **17** landed.  
2. **#2579 (H3+H4+H8)** → A+F extract landed; H3 sole-export rule remains.  
3. **#2580 (H1)** → multi-bind OK; **18** regression + simplified `loop-once` unpack.  
4. **#2582 (H7)** → `std/hot-strategy` + Aether **19** landed.

## Reproduce (local)

```bash
./scripts/run-aura.sh examples/12-parallel-yield/main.aura   # PASS via sequential-yield
./scripts/report.sh                                          # full denseness suite
```

## Status

- Filed on Aura 2026-08-02: #2578–#2582.  
- **Closed:** #2579, #2581, #2580, #2582 (hot-strategy).  
- Tracker #2578 can close when no open children.  
- Denseness offline suite through probe **19**.

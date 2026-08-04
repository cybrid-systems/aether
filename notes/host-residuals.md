# Host residuals (actionable)

These are **Aura host / packaging** limits observed while building Aether denseness
probes. They are **not** failures of the \(S_{\mathrm{Aether}}\) denseness claim;
PASS paths use pure-Aura workarounds.

## Upstream issues (cybrid-systems/aura)

### Phase 3 (H1–H8) — closed

| Aether ID | Aura issue | Title |
|-----------|------------|--------|
| tracker | [#2578](https://github.com/cybrid-systems/aura/issues/2578) | Host residual tracker (Phase 3 H1–H8) — **closed** |
| H1 | [#2580](https://github.com/cybrid-systems/aura/issues/2580) | Multi-binding `let` — **closed**; Aether 18 + simplified loop-once |
| H3/H4/H8 | [#2579](https://github.com/cybrid-systems/aura/issues/2579) | Module free-vars / export — **closed** (Aether A+F extract + sole-export rule) |
| H5/H6 | [#2581](https://github.com/cybrid-systems/aura/issues/2581) | fiber/orch parallel — **closed** (Aether 17 dual-mode fanout) |
| H7 | [#2582](https://github.com/cybrid-systems/aura/issues/2582) | hot-update AOT vs pure-Aura — **closed** (`std/hot-strategy` + Aether 19) |
| H2 | — | Prefer `(eq? x #t)` — convention only (no issue) |

Earlier wave (closed, partial fix): [#2566](https://github.com/cybrid-systems/aura/issues/2566)–[#2570](https://github.com/cybrid-systems/aura/issues/2570).

### Phase 5 overnight multi-agent stress (H9–H12) — open

| Aether ID | Aura issue | Title |
|-----------|------------|--------|
| tracker | [#2649](https://github.com/cybrid-systems/aura/issues/2649) | Overnight multi-agent stress host residuals (Phase 5) — **open** |
| H9 | [#2651](https://github.com/cybrid-systems/aura/issues/2651) | **P0** SIGSEGV in `pmr::memory_resource` / AST `construct_at` under fanout + long context |
| H10 | [#2653](https://github.com/cybrid-systems/aura/issues/2653) | **P1** `load_module_file` resolves LLM prompts / empty / `16384` as module path |
| H11 | [#2650](https://github.com/cybrid-systems/aura/issues/2650) | **P1** `recursion depth exceeded (>700)` under multi-agent yield fanout |
| H12 | [#2652](https://github.com/cybrid-systems/aura/issues/2652) | **P1** Symbol/string heap corruption (empty stats keys, NUL bytes, WAVE pollution) |

Session evidence: `20260804T214445+0800`, Aura `ecea342f`, Aether `e08ea52`,
`AETHER_LLM_CONTEXT_CHARS=16384`, agents 52–60 × 64 jobs. See `notes/aura-anomaly-log.md`.

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
| H9 | SIGSEGV in PMR allocate/deallocate / AST construct under overnight fanout | Adaptive backoff agents; do not count as denseness fail | **#2651 open** |
| H10 | `load_module_file` sees LLM prompt / `16384` / empty path | Same; log for Aura; not a guest `require` bug | **#2653 open** |
| H11 | `recursion depth exceeded (>700)` mid-wave | Optional: iterative pad; host must fix per-fiber depth | **#2650 open** |
| H12 | Empty stats keys / NUL in stdout / WAVE field pollution | Treat metrics as suspect under host crash; file Aura | **#2652 open** |

## When fixed, Aether follow-ups

1. **#2581 (H5+H6)** → Aether **17** landed.  
2. **#2579 (H3+H4+H8)** → A+F extract landed; H3 sole-export rule remains.  
3. **#2580 (H1)** → multi-bind OK; **18** regression + simplified `loop-once` unpack.  
4. **#2582 (H7)** → `std/hot-strategy` + Aether **19** landed.  
5. **#2649 (H9–H12)** → re-run overnight at agents=60 × jobs=8 × ctx=16384; expect no SIGSEGV / no path-as-prompt; restore full pressure defaults when green.

## Reproduce (local)

```bash
# Phase 3 dual-mode fanout baseline
./scripts/run-aura.sh examples/12-parallel-yield/main.aura   # PASS via sequential-yield
./scripts/report.sh                                          # full denseness suite

# Phase 5 overnight pressure (needs live LLM for full H9–H12 surface)
AETHER_LLM_PROPOSE=live AETHER_OVERNIGHT_AGENTS=60 AETHER_LLM_CONTEXT_CHARS=16384 \
  ./scripts/run-aura.sh examples/22-overnight-mutate/main.aura
```

## Status

- Filed on Aura 2026-08-02: #2578–#2582 (Phase 3).  
- **Closed:** #2579, #2581, #2580, #2582, tracker #2578.  
- Filed on Aura 2026-08-04: #2649–#2653 (Phase 5 overnight).  
- Denseness offline suite through probe **19**; overnight live stress is **separate** residual track.

# Escape Log

Record every place where Aether must leave pure Aura (`V_A`) to achieve the desired semantics or performance.

Format for each entry:

```
## [Date] Short title
- Location: file / function
- Reason: why pure Aura was insufficient
- Escape mechanism: FFI / external service / C++ primitive / other
- Impact: business logic vs performance-critical path
- Mitigation: capability boundary, isolation, future plan
```

---

Host configuration used for demos (not counted as \(V_A\) escapes of the evolvable core):

- `AURA_SANDBOX=off` — CLI must allow workspace mutation; production isolation remains Aura’s responsibility.
- `AURA_PIPELINE_STRICT=0` — some host builds forbid tree-walker fallback; demo scripts relax this for reproducibility.

### Examples 01–05 PASS paths

No business-logic escapes on evolvable core.

### Example 06 — intentional propose-edge escape (metering)

## [2026-08-02] LLM-stub propose edge (scenario B/C)

- Location: `examples/06-propose-edge-escape/main.aura`, `lib/aether-propose.aura`
- Reason: demonstrate that \(E\) can be confined to the researcher propose edge
  while the executor still verifies and rolls back bad proposals
- Escape mechanism: **logical** propose-edge marker (`llm-stub`); no network on
  the default PASS path. Live mode (`AETHER_LLM_PROPOSE=live`) may call `std/llm`
  / external HTTP when `LLM_API_KEY` is set
- Impact: **propose edge only** — never decide/verify/rollback authority
- Mitigation: executor ignores proposal authority; `aether:stats` key `escapes`
  counts propose-edge events; bad stub proposals still rollback

## [2026-08-02] Live MiniMax-M3 propose (example 09)

- Location: `examples/09-live-minimax/main.aura`, `aether-propose-live`
- Reason: real LLM on researcher propose edge for denseness of \(E\) isolation
- Escape mechanism: HTTPS `LLM_BASE_URL/chat/completions` via `std/llm` /
  `http-post` (OpenAI-compatible MiniMax)
- Config: `~/code/keys/minimax` → `LLM_API_KEY`;
  `LLM_BASE_URL=https://api.minimaxi.com/v1`; `LLM_MODEL=MiniMax-M3`
  (note: `api.minimax.io` returns 2049 invalid key for this credential)
- Impact: **propose edge only**; executor schema + business verify unchanged
- Mitigation: wire parse + body banlist; invalid LLM bodies refuse/rebind-fail;
  fallback rule proposal still schema-valid


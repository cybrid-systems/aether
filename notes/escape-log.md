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

(No business-logic escapes recorded for examples 01–03 PASS paths.)

Host configuration used for demos (not counted as \(V_A\) escapes of the evolvable core):

- `AURA_SANDBOX=off` — CLI must allow workspace mutation; production isolation remains Aura’s responsibility.
- `AURA_PIPELINE_STRICT=0` — some host builds forbid tree-walker fallback; demo scripts relax this for reproducibility.

### Example 03 note (not an escape on PASS path)

- Researcher propose edge is pure Aura rule table today.
- Optional future LLM propose is **allowed only** in `researcher-propose` / propose-edge hook; executor must stay pure `aether-min`. Log any live LLM use here when enabled.


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

(No escapes recorded yet — initial skeleton stage.)

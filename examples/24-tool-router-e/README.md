# 24 — tool-router-e

**Tool router** is a rebindable mutation surface; **tool-edge \(E\)** is metered
on an intentional stub path only (no network).

## Axes

- **B** Mutation surface — named `router` rebind under guards  
- **E** World boundary — `http-stub` tool-edge escape (logical marker)  
- **A** Commit / rollback on router health  
- **F** `escapes` stat + tool_escapes counter  

## Run

```bash
./scripts/run-aura.sh examples/24-tool-router-e/main.aura
```

## PASS criteria

| Step | Claim |
|------|--------|
| A | Baseline echo ok / count deny |
| B | Rebind admits count → commit |
| C | Deny-all poison → rollback; echo still ok |
| D | Stub edge bumps `escapes`; pure tools do not |
| E | Heal removes stub; `safety-ok?` |

## Escapes

**Tool-edge only** (logical `http-stub` marker). Not decide/verify/rollback
authority. No HTTPS on the default PASS path.

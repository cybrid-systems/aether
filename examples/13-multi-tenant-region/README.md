# 13 — Multi-tenant region isolation

Two policy bindings (`gate-a`, `gate-b`) share one Aura workspace. Mutation of
one **region** must not change the other’s business metrics.

## Claim

On \(S_{\mathrm{Aether}}\), multi-tenant isolation can stay in pure Aura via
**name-targeted rebind** + per-region observe/verify — no process or OS
sandbox required for the denseness claim.

## Scenarios

| Case | Action | Expect |
|------|--------|--------|
| A seed | both strict | fails_a=7, fails_b=7 |
| B | widen `gate-a` only | fails_a=4, fails_b=7 |
| C | poison+heal `gate-a` | b stays 7 throughout |
| D | widen `gate-b` | both 4 / within budget |

## Run

```bash
./scripts/run-aura.sh examples/13-multi-tenant-region/main.aura
```

## Escapes

None on the PASS path.

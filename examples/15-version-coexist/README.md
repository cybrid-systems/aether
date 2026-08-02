# 15 — Strategy version coexistence (Axis D)

**Active** `strategy` and immutable peer **golden** coexist. Active can be
promoted / poisoned / healed from the golden body string; golden never rebounds
and remains the reference version.

## Claim

Temporal version coexistence stays in pure Aura (named bindings + guarded
rebind). Golden is a live peer, not only a string archive.

## Host note

Rebind of a *second* multi-define arithmetic binding is flaky on current host;
golden is installed second and left immutable; active is rebound.

## Run

```bash
./scripts/run-aura.sh examples/15-version-coexist/main.aura
```

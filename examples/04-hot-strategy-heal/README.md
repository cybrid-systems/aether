# 04 — Hot strategy + self-heal

Phase 2 denseness probe for **Axis D** (temporal adaptation), built on A+B+F.

## Meaning of “hot”

Runtime **strategy body** replacement under mutation guards (`aether:rebind-safe` /
`aether:loop-once`), not AOT `.so` reload (`std/hot-update`). That keeps the
evolvable core inside pure Aura while still exercising versioned hot deploy.

## Flow

| Step | Action | Expected |
|------|--------|----------|
| R1 | Hot-deploy triple strategy with health verify | **commit**, `last-good` updated, version=1 |
| R2 | Already healthy | **skip** |
| R3a | Poison strategy (`* 99`) without health gate | applied (simulates bad deploy) |
| R3b | **self-heal** rebinds `last-good` + verify | **commit**, `strategy(7)=21` |

Health: `(= (strategy 7) 21)`.

## Run

```bash
./scripts/run-aura.sh examples/04-hot-strategy-heal/main.aura
```

Expected:

```text
PASS: hot strategy deploy + self-heal to last-good
```

## Escapes

None in evolvable core on the PASS path.

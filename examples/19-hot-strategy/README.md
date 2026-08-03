# 19 — Pure-Aura hot strategy (H7 / Aura #2582)

Uses **`std/hot-strategy`** (not `std/hot-update` AOT `.so`):

1. `register!` last-good after seed  
2. `swap!` deploy triple  
3. `swap!` poison → `heal!` restores snapshot  

## Run

```bash
./scripts/run-aura.sh examples/19-hot-strategy/main.aura
```

## Escapes

None — pure Aura rebind + snapshot.

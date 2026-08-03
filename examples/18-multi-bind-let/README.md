# 18 — Multi-binding `let` (H1 regression)

Proves independent multi-binding `let` works after `install-source` /
`loop-once` rebind (Aura #2580 denseness follow-up).

**Order note:** multi-bind *before* seeding workspace can break module free-vars
to later bindings (e.g. `gate`); seed first, then multi-bind.

Also exercises simplified `aether:loop-once` multi-bind unpack of mut results.

## Run

```bash
./scripts/run-aura.sh examples/18-multi-bind-let/main.aura
```

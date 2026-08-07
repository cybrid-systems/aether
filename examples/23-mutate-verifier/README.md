# 23 — mutate-verifier

**Verifier is a first-class mutation surface** under `aether:loop-once` guards —
not only domain strategy / gate bodies.

## Axes

- **B** Mutation surface — rebind verify half of a single `kernel` binding  
- **A** O→D→M→V→R — promote verify → evolve score → poison → heal → reject  
- **F** Metrology — commits / rollbacks / escapes=0  

## Why one `kernel` name

Host multi-define rebind is flaky (second binding after rebind of first).  
Denseness isomorphism: score + verify encoded in one rebindable lambda:

```
(kernel "score" x)   → number
(kernel "verify" v)  → bool
```

## Run

```bash
./scripts/run-aura.sh examples/23-mutate-verifier/main.aura
```

## PASS criteria

| Step | Claim |
|------|--------|
| A | Promote verify to expect 21; score still double |
| B | Score → triple under new verify → commit |
| C | Poison verify always-true is itself a guarded rebind |
| D/E | Heal; bad score rejected → rollback; score stays triple |

## Escapes

None (pure Aura + `aether-min`).

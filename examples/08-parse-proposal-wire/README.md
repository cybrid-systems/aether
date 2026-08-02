# 08 — Parse proposal wire format

External / LLM text on the **propose edge** must collapse to a structured
wire line before the executor will touch the workspace.

## Wire format

```text
MUTATE|<name>|<lambda-body>|<summary>
SKIP|<name>||<summary>
```

- First non-empty line is parsed (`aether:parse-proposal-text`)
- Then **schema** (`aether:proposal-valid?`)
- Then **execute** (`aether:execute-proposal` → verify / rollback)

## Cases

| ID | Input | Expected |
|----|-------|----------|
| A | Prose + valid `MUTATE|…` line | parse + **commit** (escape bumped) |
| B | Free-form garbage | **parse-failed** refuse |
| C | `MUTATE|…|rm -rf /|…` | schema **refuse** |
| D | `SKIP|…` when healthy | **skip** |

## Run

```bash
./scripts/run-aura.sh examples/08-parse-proposal-wire/main.aura
```

No live API key required; canned “LLM” strings exercise the same path as live parse.

# Last denseness run

- **When:** 2026-08-07T14:31:42Z
- **Host:** `../aura-grok/build/aura` (via run-aura.sh)
- **Passed:** 24 / 24
- **Failed:** 0

| Example | Status | RESULT |
|---------|--------|--------|
| `01-single-loop` | pass | `RESULT pass example=01-single-loop escapes=0` |
| `02-business-signal` | pass | `RESULT pass example=02-business-signal escapes=0 commits=1 rollbacks=1` |
| `03-researcher-executor` | pass | `RESULT pass example=03-researcher-executor escapes=0` |
| `04-hot-strategy-heal` | pass | `RESULT pass example=04-hot-strategy-heal escapes=0` |
| `05-long-run-denseness` | pass | `RESULT pass example=05-long-run-denseness escapes=0` |
| `06-propose-edge-escape` | pass | `RESULT pass example=06-propose-edge-escape rule_escapes=0 stub_escapes=1` |
| `07-proposal-schema` | pass | `RESULT pass example=07-proposal-schema escapes=0` |
| `08-parse-proposal-wire` | pass | `RESULT pass example=08-parse-proposal-wire escapes=1` |
| `10-long-n-stress` | pass | `RESULT pass example=10-long-n-stress N=50 escapes=0 heals=4 poisons=4` |
| `11-arbitrated-multi` | pass | `RESULT pass example=11-arbitrated-multi escapes=0 commits=2` |
| `12-parallel-yield` | pass | `RESULT pass example=12-parallel-yield escapes=0 mode=sequential-yield` |
| `13-multi-tenant-region` | pass | `RESULT pass example=13-multi-tenant-region escapes=0 commits=3` |
| `14-long-n-100` | pass | `RESULT pass example=14-long-n-100 N=100 escapes=0 heals=9 poisons=9` |
| `15-version-coexist` | pass | `RESULT pass example=15-version-coexist escapes=0 commits=2` |
| `16-drift-freeze` | pass | `RESULT pass example=16-drift-freeze escapes=0 freezes=1` |
| `17-true-parallel` | pass | `RESULT pass example=17-true-parallel escapes=0 mode=parallel-yield` |
| `18-multi-bind-let` | pass | `RESULT pass example=18-multi-bind-let escapes=0` |
| `19-hot-strategy` | pass | `RESULT pass example=19-hot-strategy escapes=0 aot=0 ver=3` |
| `20-multi-live-propose` | pass | `RESULT pass example=20-multi-live-propose live=#f escapes=6 commits=1` |
| `21-concurrent-propose-yield` | pass | `RESULT pass example=21-concurrent-propose-yield live=#f mode=sequential-yield escapes=5` |
| `22-overnight-mutate` | pass | `RESULT pass example=22-overnight-mutate agents=6 fan_rounds=6 props=36 commits=1 skips=5 rollbacks=1 refuses=0 escapes=36 mode=sequential-yield live=#f safety=#t` |
| `23-mutate-verifier` | pass | `RESULT pass example=23-mutate-verifier escapes=0 commits=4 rollbacks=1` |
| `24-tool-router-e` | pass | `RESULT pass example=24-tool-router-e escapes=1 tool_escapes=1 commits=3` |
| `25-checkpoint-recover` | pass | `RESULT pass example=25-checkpoint-recover escapes=0 ckpt=1 commits=1 rollbacks=1` |

Full log: `notes/.last-run-raw.txt` (gitignored if desired).

**Suite: ALL PASSED**

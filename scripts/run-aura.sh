#!/usr/bin/env bash
# Run an Aether .aura file against a local Aura host binary.
#
# Usage (from aether repo root):
#   ./scripts/run-aura.sh examples/01-single-loop/main.aura
#
# Env overrides:
#   AURA_BIN   path to aura binary (default: ../aura-grok/build/aura)
#   AURA_LIB   path to Aura lib/ containing std/ (default: ../aura-grok/lib)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

AURA_BIN="${AURA_BIN:-$ROOT/../aura-grok/build/aura}"
AURA_LIB="${AURA_LIB:-$ROOT/../aura-grok/lib}"
AETHER_LIB="${AETHER_LIB:-$ROOT/lib}"

if [[ ! -x "$AURA_BIN" ]]; then
  echo "error: aura binary not found or not executable: $AURA_BIN" >&2
  echo "  build aura-grok or set AURA_BIN" >&2
  exit 1
fi

if [[ ! -d "$AURA_LIB/std" ]]; then
  echo "error: Aura stdlib not found under: $AURA_LIB/std" >&2
  echo "  set AURA_LIB to the directory that contains std/" >&2
  exit 1
fi

if [[ ! -d "$AETHER_LIB" ]]; then
  echo "error: Aether lib not found: $AETHER_LIB" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <file.aura> [args ignored]" >&2
  exit 1
fi

SRC="$1"
if [[ ! -f "$SRC" ]]; then
  echo "error: file not found: $SRC" >&2
  exit 1
fi

# CLI mutation demos need sandbox off; production hosts keep isolation.
# Pipeline strict can reject tree-walker fallback on some host builds.
# AURA_PATH: Aura stdlib first, then Aether lib/ (measure, loop, …).
export AURA_PATH="${AURA_PATH:-$AURA_LIB:$AETHER_LIB}"
export AURA_SANDBOX="${AURA_SANDBOX:-off}"
export AURA_PIPELINE_STRICT="${AURA_PIPELINE_STRICT:-0}"

# Default MiniMax-M3 credentials from ~/code/keys/minimax when present.
# Offline probes stay rule/stub; live example auto-enables AETHER_LLM_PROPOSE=live.
_KEY_FILE="${MINIMAX_KEY_FILE:-$HOME/code/keys/minimax}"
if [[ -z "${LLM_API_KEY:-}" && -f "$_KEY_FILE" ]]; then
  _raw="$(tr -d '\r\n' < "$_KEY_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [[ "$_raw" == *=* ]]; then
    export LLM_API_KEY="${_raw#*=}"
  else
    export LLM_API_KEY="$_raw"
  fi
  unset _raw
  export LLM_BASE_URL="${LLM_BASE_URL:-https://api.minimaxi.com/v1}"
  export LLM_MODEL="${LLM_MODEL:-MiniMax-M3}"
fi
# Only 09 auto-enables live when key present. Phase 5 (20/21/22) stays offline
# stub/rule unless caller sets AETHER_LLM_PROPOSE=live (or overnight-mutate.sh).
if [[ "$SRC" == *live-minimax* && -n "${LLM_API_KEY:-}" ]]; then
  export AETHER_LLM_PROPOSE="${AETHER_LLM_PROPOSE:-live}"
fi
unset _KEY_FILE

exec "$AURA_BIN" < "$SRC"

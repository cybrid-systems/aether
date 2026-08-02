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

exec "$AURA_BIN" < "$SRC"

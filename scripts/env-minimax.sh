#!/usr/bin/env bash
# Source MiniMax credentials for Aura LLM (OpenAI-compatible).
#
# Usage:
#   source ./scripts/env-minimax.sh
#   AETHER_LLM_PROPOSE=live ./scripts/run-aura.sh examples/09-live-minimax/main.aura
#
# Key file: ~/code/keys/minimax  (raw token, or KEY=value)
# Docs: https://platform.minimax.io/docs/api-reference/text-openai-api
#   BASE:  https://api.minimax.io/v1
#   MODEL: MiniMax-M3

set -euo pipefail

KEY_FILE="${MINIMAX_KEY_FILE:-$HOME/code/keys/minimax}"
if [[ ! -f "$KEY_FILE" ]]; then
  echo "error: MiniMax key file not found: $KEY_FILE" >&2
  return 1 2>/dev/null || exit 1
fi

# Support raw token or KEY=value line without printing secrets.
_raw="$(tr -d '\r\n' < "$KEY_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
if [[ "$_raw" == *=* ]]; then
  # shellcheck disable=SC2163
  export LLM_API_KEY="${_raw#*=}"
else
  export LLM_API_KEY="$_raw"
fi
unset _raw

# Global console api.minimax.io often rejects China-issued keys (2049).
# api.minimaxi.com is the working OpenAI-compatible endpoint for this key file.
export LLM_BASE_URL="${LLM_BASE_URL:-https://api.minimaxi.com/v1}"
export LLM_MODEL="${LLM_MODEL:-MiniMax-M3}"
export AETHER_LLM_PROPOSE="${AETHER_LLM_PROPOSE:-live}"

echo "env-minimax: LLM_MODEL=$LLM_MODEL LLM_BASE_URL=$LLM_BASE_URL AETHER_LLM_PROPOSE=$AETHER_LLM_PROPOSE key=set"

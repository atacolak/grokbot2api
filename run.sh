#!/usr/bin/env bash
# Grok Bot / Cursor Sand OpenAI-compatible bridge (grokbot2api).
#
# Auth: every credential stays in omp's resolved secrets file
#   ~/.omp/agent/secrets/grokbot.env  (SAND_INFERENCE_RENEWAL_CREDENTIAL, GROKBOT_MACHINE_ID)
# sand_inference.py reads it directly; nothing secret lives in this script or in the unit.
#
# The local API key is only a loopback guard so unrelated local processes cannot spend the
# Sand allowance: it is read from omp's agent env file (GROKBOT2API_KEY) and passed by NAME.
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMP_ENV_FILE="${GROKBOT_OMP_ENV_FILE:-/home/sf/.omp/agent/.env}"
TOKEN_CACHE="${GROKBOT_TOKEN_CACHE:-/home/sf/.omp/agent/cache/grokbot2api-token.json}"
LISTEN="${GROKBOT_LISTEN:-127.0.0.1}"
PORT="${GROKBOT_PORT:-8799}"
MODEL="${GROKBOT_MODEL:-grok-4.7}"

if [[ -r "$OMP_ENV_FILE" ]]; then
  key="$(sed -n 's/^GROKBOT2API_KEY=//p' "$OMP_ENV_FILE" | head -1)"
  if [[ -n "$key" ]]; then
    export GROKBOT2API_KEY="$key"
  fi
fi

mkdir -p "$(dirname "$TOKEN_CACHE")"

exec python3 "$APP_DIR/grokbot2api.py" \
  --listen "$LISTEN" \
  --port "$PORT" \
  --model "$MODEL" \
  --cache "$TOKEN_CACHE" \
  ${GROKBOT2API_KEY:+--api-key-env GROKBOT2API_KEY}

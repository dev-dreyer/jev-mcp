#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
set -a
# shellcheck disable=SC1091
source "$ROOT/.env"
set +a
cd "$ROOT"
# Self-heal after a /workspace restore (Riaan, 18 Oct 2026). Output goes to stderr so the MCP channel stays clean.
if [ ! -f "$ROOT/dist/index.js" ] || [ ! -d "$ROOT/node_modules" ]; then
  echo "jev: build missing, rebuilding $(date -Is)" >&2
  { npm ci --ignore-scripts && npm run build; } >>"$ROOT/rebuild.log" 2>&1
fi
LAB=/workspace/jev-usage-lab
if [ ! -x "$LAB/.venv/bin/python" ]; then
  echo "jev: usage-lab venv missing, rebuilding $(date -Is)" >&2
  { uv venv "$LAB/.venv" && uv pip install --python "$LAB/.venv/bin/python" -r "$LAB/requirements.txt"; } >>"$ROOT/rebuild.log" 2>&1
fi
exec node dist/index.js "$@"

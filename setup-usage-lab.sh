#!/usr/bin/env bash
# Manual bootstrap for /workspace/jev-usage-lab. Not used by run-mcp.sh.
# A missing lab must never block the MCP server; run this script yourself.
set -euo pipefail

# Package installation must not see the TypeSafe key, even if the caller exported it.
unset TYPESAFE_API_KEY || true

LAB=/workspace/jev-usage-lab
if [ -x "$LAB/.venv/bin/python" ]; then
  exit 0
fi
echo "jev: usage-lab venv missing, rebuilding $(date -Is)" >&2
env -u TYPESAFE_API_KEY uv venv "$LAB/.venv"
env -u TYPESAFE_API_KEY uv pip install --python "$LAB/.venv/bin/python" -r "$LAB/requirements.txt"

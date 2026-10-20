#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# --env-file arrived in Node 20.6. Older 20.x builds keep the host environment.
supports_env_file() {
  local raw major rest minor
  raw="$(node -v 2>/dev/null || true)"
  raw="${raw#v}"
  major="${raw%%.*}"
  rest="${raw#*.}"
  minor="${rest%%.*}"
  case "$major" in
    ''|*[!0-9]*) return 1 ;;
  esac
  case "$minor" in
    ''|*[!0-9]*) return 1 ;;
  esac
  if [ "$major" -gt 20 ]; then
    return 0
  fi
  [ "$major" -eq 20 ] && [ "$minor" -ge 6 ]
}

# Self-heal after a /workspace restore (Riaan, 18 Oct 2026). Output goes to stderr so the MCP channel stays clean.
# Package install and build must not see TYPESAFE_API_KEY.
if [ ! -f "$ROOT/dist/index.js" ] || [ ! -d "$ROOT/node_modules" ]; then
  echo "jev: build missing, rebuilding $(date -Is)" >&2
  {
    env -u TYPESAFE_API_KEY npm ci --ignore-scripts && env -u TYPESAFE_API_KEY npm run build
  } >>"$ROOT/rebuild.log" 2>&1
fi

if [ -f "$ROOT/.env" ] && supports_env_file; then
  exec node --env-file="$ROOT/.env" dist/index.js "$@"
fi
if [ -f "$ROOT/.env" ]; then
  echo "jev: Node $(node -v 2>/dev/null || echo unknown) does not support --env-file (requires 20.6+); using the process environment" >&2
fi
exec node dist/index.js "$@"

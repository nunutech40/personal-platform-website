#!/bin/bash
# Stop local development server for Personal Brand Platform
# Usage:
#   ./scripts/stop-local.sh
#   ./scripts/stop-local.sh --with-postgres

echo "=== Stopping Personal Brand Platform ==="

PID_FILE="personal_brand/tmp/local-server.pid"
STOP_POSTGRES=false

if [ "${1:-}" = "--with-postgres" ]; then
  STOP_POSTGRES=true
elif [ "${1:-}" != "" ]; then
  echo "Usage: ./scripts/stop-local.sh [--with-postgres]"
  exit 1
fi

PHX_PID=$(lsof -ti :4000 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)

if [ -z "$PHX_PID" ] && [ -f "$PID_FILE" ]; then
  FILE_PID=$(cat "$PID_FILE" 2>/dev/null || true)

  if [ -n "$FILE_PID" ] && kill -0 $FILE_PID 2>/dev/null; then
    PHX_PID="$FILE_PID"
  fi
fi

if [ -n "$PHX_PID" ]; then
  echo "Stopping Phoenix server (PID: $PHX_PID)..."
  kill $PHX_PID 2>/dev/null || true
  sleep 2

  # Force kill if still running
  PHX_PID=$(lsof -ti :4000 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)

  if [ -n "$PHX_PID" ]; then
    kill -9 $PHX_PID 2>/dev/null || true
  fi

  rm -f "$PID_FILE"
  echo "Phoenix: ✅ Stopped"
else
  echo "Phoenix: ❌ Not running"
fi

if [ "$STOP_POSTGRES" = true ]; then
  echo "Stopping PostgreSQL service..."
  brew services stop postgresql@16
  echo "PostgreSQL: ✅ Stop requested"
else
  echo "PostgreSQL: ℹ️  Left running. Use --with-postgres to stop it too."
fi

echo "=== Stopped ==="

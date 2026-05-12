#!/bin/bash
# Start local development server for Personal Brand Platform
# Usage:
#   ./scripts/start-local.sh
#   ./scripts/start-local.sh --daemon

set -e

echo "=== Starting Personal Brand Platform ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
POSTGRES_BIN="/opt/homebrew/opt/postgresql@16/bin"
POSTGRES_DATA="/opt/homebrew/var/postgresql@16"
APP_DIR="$ROOT_DIR/personal_brand"
PID_FILE="$APP_DIR/tmp/local-server.pid"
LOG_FILE="$APP_DIR/tmp/local-server.log"
DAEMON=false

if [ "${1:-}" = "--daemon" ] || [ "${1:-}" = "-d" ]; then
  DAEMON=true
fi

if [ "${1:-}" != "" ] && [ "$DAEMON" = false ]; then
  echo "Usage: ./scripts/start-local.sh [--daemon]"
  exit 1
fi

# Check if PostgreSQL is accepting connections.
if ! $POSTGRES_BIN/pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 3

  # If brew services says started but still can't connect, try pg_ctl
  if ! $POSTGRES_BIN/pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "PostgreSQL service not responding. Trying direct start..."
    # Remove stale PID if exists
    if [ -f "$POSTGRES_DATA/postmaster.pid" ]; then
      STALE_PID=$(head -1 "$POSTGRES_DATA/postmaster.pid" 2>/dev/null)
      if [ -n "$STALE_PID" ]; then
        echo "Removing stale PostgreSQL PID: $STALE_PID"
        kill -9 "$STALE_PID" 2>/dev/null || true
        rm -f "$POSTGRES_DATA/postmaster.pid"
      fi
    fi
    $POSTGRES_BIN/pg_ctl -D "$POSTGRES_DATA" start
    sleep 2
  fi
fi

echo "PostgreSQL: ✅ Running"

PHX_PID=$(lsof -tiTCP:4000 -sTCP:LISTEN 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)

if [ -n "$PHX_PID" ]; then
  HTTP_CODE=$(curl --max-time 3 -s -o /dev/null -w "%{http_code}" http://localhost:4000 2>/dev/null || true)

  if [ "$HTTP_CODE" = "200" ]; then
    echo "Phoenix: ✅ Already running at http://localhost:4000 (PID: $PHX_PID)"
    exit 0
  fi

  echo "Phoenix: ⚠️  Port 4000 is occupied but HTTP is unhealthy (code: ${HTTP_CODE:-000}). Restarting local Phoenix..."
  kill $PHX_PID 2>/dev/null || true
  sleep 2

  PHX_PID=$(lsof -tiTCP:4000 -sTCP:LISTEN 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)

  if [ -n "$PHX_PID" ]; then
    kill -9 $PHX_PID 2>/dev/null || true
    sleep 1
  fi

  rm -f "$PID_FILE"
fi

# Check if Phoenix project exists
if [ ! -d "$APP_DIR" ]; then
  echo "Error: Phoenix project not found. Run setup first."
  exit 1
fi

mkdir -p "$APP_DIR/tmp"
cd "$APP_DIR"

# Install dependencies if needed
if [ ! -d "deps" ]; then
  echo "Installing dependencies..."
  mix deps.get
fi

# Setup database if needed. Seed data is intentionally opt-in via reset-local-db.sh --seed.
echo "Setting up database..."
mix ecto.create 2>/dev/null || true
mix ecto.migrate 2>/dev/null || true

# Start Phoenix server
echo ""
echo "=== Starting Phoenix server at http://localhost:4000 ==="
echo "=== Public: http://localhost:4000 ==="
echo "=== Admin:  http://localhost:4000/admin ==="
echo "=== Login:  admin / admin123 ==="
echo ""

if [ "$DAEMON" = true ]; then
  echo "Starting Phoenix detached from this shell..."
  echo "Started detached Phoenix at $(date)" > "$LOG_FILE"
  elixir --erl "-detached" -S mix phx.server

  for _ in $(seq 1 30); do
    HTTP_CODE=$(curl --max-time 3 -s -o /dev/null -w "%{http_code}" http://localhost:4000 2>/dev/null || true)

    if [ "$HTTP_CODE" = "200" ]; then
      SERVER_PID=$(lsof -tiTCP:4000 -sTCP:LISTEN 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)
      echo "$SERVER_PID" > "$PID_FILE"
      echo "Phoenix: ✅ Running in background (PID: $SERVER_PID)"
      echo "Log: personal_brand/tmp/local-server.log"
      exit 0
    fi

    sleep 1
  done

  echo "Phoenix: ❌ Failed to respond at http://localhost:4000"
  echo "Last log lines:"
  tail -n 80 "$LOG_FILE" || true
  exit 1
fi

echo "Phoenix will run in the foreground. Press Ctrl+C to stop it."
mix phx.server

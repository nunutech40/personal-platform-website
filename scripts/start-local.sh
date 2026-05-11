#!/bin/bash
# Start local development server for Personal Brand Platform
# Usage: ./scripts/start-local.sh

set -e

echo "=== Starting Personal Brand Platform ==="

POSTGRES_BIN="/opt/homebrew/opt/postgresql@16/bin"
POSTGRES_DATA="/opt/homebrew/var/postgresql@16"

# Check if PostgreSQL is running by trying to connect
if ! $POSTGRES_BIN/psql -h localhost -U "$(whoami)" -d postgres -c "SELECT 1" > /dev/null 2>&1; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 3

  # If brew services says started but still can't connect, try pg_ctl
  if ! $POSTGRES_BIN/psql -h localhost -U "$(whoami)" -d postgres -c "SELECT 1" > /dev/null 2>&1; then
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

# Check if Phoenix project exists
if [ ! -d "personal_brand" ]; then
  echo "Error: Phoenix project not found. Run setup first."
  exit 1
fi

cd personal_brand

# Install dependencies if needed
if [ ! -d "deps" ]; then
  echo "Installing dependencies..."
  mix deps.get
fi

# Setup database if needed (skip seed because seeds.exs has compile errors)
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
mix phx.server

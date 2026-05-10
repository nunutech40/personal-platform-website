#!/bin/bash
# Start local development server for Personal Brand Platform
# Usage: ./scripts/start-local.sh

set -e

echo "=== Starting Personal Brand Platform ==="

# Check if PostgreSQL is running
if ! pg_isready -q 2>/dev/null; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 2
fi

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

# Setup database if needed
echo "Setting up database..."
mix ecto.setup 2>/dev/null || mix ecto.create 2>/dev/null || true

# Start Phoenix server
echo "=== Starting Phoenix server at http://localhost:4000 ==="
echo "=== Public: http://localhost:4000 ==="
echo "=== Admin:  http://localhost:4000/admin ==="
echo "=== Login:  admin / admin123 ==="
mix phx.server

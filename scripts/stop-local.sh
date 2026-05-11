#!/bin/bash
# Stop local development server for Personal Brand Platform
# Usage: ./scripts/stop-local.sh

echo "=== Stopping Personal Brand Platform ==="

# Kill Phoenix server (by port 4000)
PHX_PID=$(lsof -ti :4000 2>/dev/null || true)
if [ -n "$PHX_PID" ]; then
  echo "Stopping Phoenix server (PID: $PHX_PID)..."
  kill $PHX_PID 2>/dev/null || true
  sleep 2
  # Force kill if still running
  PHX_PID=$(lsof -ti :4000 2>/dev/null || true)
  if [ -n "$PHX_PID" ]; then
    kill -9 $PHX_PID 2>/dev/null || true
  fi
  echo "Phoenix: ✅ Stopped"
else
  echo "Phoenix: ❌ Not running"
fi

echo "=== Stopped ==="

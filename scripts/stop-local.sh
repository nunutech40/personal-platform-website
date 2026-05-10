#!/bin/bash
# Stop local development server for Personal Brand Platform
# Usage: ./scripts/stop-local.sh

echo "=== Stopping Personal Brand Platform ==="

# Kill Phoenix server
PIDS=$(pgrep -f "mix phx.server" 2>/dev/null || true)
if [ -n "$PIDS" ]; then
  echo "Stopping Phoenix server (PID: $PIDS)..."
  kill $PIDS 2>/dev/null || true
  sleep 1
fi

# Kill any remaining beam processes
BEAM_PIDS=$(pgrep -f "beam.smp" 2>/dev/null || true)
if [ -n "$BEAM_PIDS" ]; then
  echo "Stopping Erlang VM..."
  kill $BEAM_PIDS 2>/dev/null || true
fi

echo "=== Stopped ==="

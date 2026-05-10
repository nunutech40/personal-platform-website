#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$ROOT_DIR/tmp/local-server.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "No local server PID file found."
  exit 0
fi

PID="$(cat "$PID_FILE")"

if kill -0 "$PID" 2>/dev/null; then
  kill "$PID"
  rm -f "$PID_FILE"
  echo "Stopped local server. PID: $PID"
else
  rm -f "$PID_FILE"
  echo "Local server was not running. Removed stale PID file."
fi

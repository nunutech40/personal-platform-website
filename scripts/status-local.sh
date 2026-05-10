#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$ROOT_DIR/tmp/local-server.pid"
LOG_FILE="$ROOT_DIR/tmp/local-server.log"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-5173}"

if [ ! -f "$PID_FILE" ]; then
  echo "Local server is not running."
  exit 0
fi

PID="$(cat "$PID_FILE")"

if kill -0 "$PID" 2>/dev/null; then
  echo "Local server is running at http://$HOST:$PORT"
  echo "PID: $PID"
  echo "Log: $LOG_FILE"
else
  echo "Local server PID file exists, but process is not running."
  echo "Stale PID: $PID"
  rm -f "$PID_FILE"
  echo "Removed stale PID file."
fi

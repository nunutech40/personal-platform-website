#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$ROOT_DIR/tmp/local-server.pid"
LOG_FILE="$ROOT_DIR/tmp/local-server.log"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-5173}"

cd "$ROOT_DIR"
mkdir -p "$ROOT_DIR/tmp"

if [ -f "$PID_FILE" ]; then
  PID="$(cat "$PID_FILE")"
  if kill -0 "$PID" 2>/dev/null; then
    echo "Local server already running at http://$HOST:$PORT"
    echo "PID: $PID"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

nohup env HOST="$HOST" PORT="$PORT" node server.mjs >"$LOG_FILE" 2>&1 &
PID="$!"
echo "$PID" > "$PID_FILE"

sleep 1

if kill -0 "$PID" 2>/dev/null; then
  echo "Local server started at http://$HOST:$PORT"
  echo "PID: $PID"
  echo "Log: $LOG_FILE"
else
  rm -f "$PID_FILE"
  echo "Failed to start local server. Log:"
  cat "$LOG_FILE"
  exit 1
fi

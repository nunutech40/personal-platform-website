#!/bin/bash
# Check status of local development server for Personal Brand Platform
# Usage: ./scripts/status-local.sh

echo "=== Personal Brand Platform Status ==="

POSTGRES_BIN="/opt/homebrew/opt/postgresql@16/bin"
PID_FILE="personal_brand/tmp/local-server.pid"
LOG_FILE="personal_brand/tmp/local-server.log"

# Check PostgreSQL
if $POSTGRES_BIN/pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
  echo "PostgreSQL: ✅ Running"
else
  echo "PostgreSQL: ❌ Not running"
fi

# Check Phoenix server (by port 4000)
PHX_PID=$(lsof -ti :4000 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)
if [ -n "$PHX_PID" ]; then
  echo "Phoenix:    ✅ Running (PID: $PHX_PID)"

  if [ -f "$PID_FILE" ]; then
    echo "PID file:   $PID_FILE"
  fi

  if [ -f "$LOG_FILE" ]; then
    echo "Log file:   $LOG_FILE"
  fi

  # Check if responding
  HTTP_CODE=$(curl --max-time 3 -s -o /dev/null -w "%{http_code}" http://localhost:4000 2>/dev/null || true)

  if [ "$HTTP_CODE" = "200" ]; then
    echo "HTTP:       ✅ 200 OK at http://localhost:4000"
  else
    echo "HTTP:       ⚠️  Unhealthy at http://localhost:4000 (code: ${HTTP_CODE:-000})"
  fi
else
  echo "Phoenix:    ❌ Not running"
fi

# Check database
if $POSTGRES_BIN/psql -h localhost -U "$(whoami)" -d personal_brand_dev -c "SELECT 1" > /dev/null 2>&1; then
  echo "Database:   ✅ personal_brand_dev exists"
else
  echo "Database:   ❌ personal_brand_dev not found"
fi

echo "=== Done ==="

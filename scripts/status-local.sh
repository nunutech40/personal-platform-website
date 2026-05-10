#!/bin/bash
# Check status of local development server for Personal Brand Platform
# Usage: ./scripts/status-local.sh

echo "=== Personal Brand Platform Status ==="

# Check PostgreSQL
if pg_isready -q 2>/dev/null; then
  echo "PostgreSQL: ✅ Running"
else
  echo "PostgreSQL: ❌ Not running"
fi

# Check Phoenix server
PHX_PID=$(pgrep -f "mix phx.server" 2>/dev/null || true)
if [ -n "$PHX_PID" ]; then
  echo "Phoenix:    ✅ Running (PID: $PHX_PID)"
  # Check if responding
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:4000 2>/dev/null | grep -q "200"; then
    echo "HTTP:       ✅ 200 OK at http://localhost:4000"
  else
    echo "HTTP:       ⚠️  Not responding yet"
  fi
else
  echo "Phoenix:    ❌ Not running"
fi

# Check database
if psql -d personal_brand_dev -c "SELECT 1" 2>/dev/null | grep -q "1"; then
  echo "Database:   ✅ personal_brand_dev exists"
else
  echo "Database:   ❌ personal_brand_dev not found"
fi

echo "=== Done ==="

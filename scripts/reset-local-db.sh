#!/bin/bash
# Reset local development database for Personal Brand Platform.
# This script is intentionally scoped to MIX_ENV=dev and personal_brand_dev.
#
# Usage:
#   ./scripts/reset-local-db.sh --yes
#   ./scripts/reset-local-db.sh --yes --seed
#   ./scripts/reset-local-db.sh --yes --with-uploads
#   ./scripts/reset-local-db.sh --yes --no-restart

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
POSTGRES_BIN="/opt/homebrew/opt/postgresql@16/bin"
APP_DIR="$ROOT_DIR/personal_brand"
DB_NAME="personal_brand_dev"
RESET_UPLOADS=false
SEED=false
RESTART=true
CONFIRMED=false

usage() {
  cat <<EOF
Usage: ./scripts/reset-local-db.sh --yes [options]

Options:
  --yes           Required confirmation. This drops and recreates $DB_NAME.
  --seed          Run priv/repo/seeds.exs after migrations.
  --empty         Keep the database empty after migrations. This is the default.
  --with-uploads  Also delete local uploaded files under priv/static/uploads.
  --no-restart    Do not restart Phoenix after reset.
  -h, --help      Show this help.

Examples:
  ./scripts/reset-local-db.sh --yes
  ./scripts/reset-local-db.sh --yes --seed
  ./scripts/reset-local-db.sh --yes --with-uploads
  ./scripts/reset-local-db.sh --yes --empty --no-restart
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes)
      CONFIRMED=true
      ;;
    --empty)
      SEED=false
      ;;
    --seed)
      SEED=true
      ;;
    --with-uploads)
      RESET_UPLOADS=true
      ;;
    --no-restart)
      RESTART=false
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [ "$CONFIRMED" != true ]; then
  echo "Refusing to reset without explicit confirmation."
  echo ""
  usage
  exit 1
fi

if [ ! -d "$APP_DIR" ]; then
  echo "Error: Phoenix project not found. Run setup first."
  exit 1
fi

if [ "${MIX_ENV:-dev}" != "dev" ]; then
  echo "Error: this script only supports MIX_ENV=dev. Current MIX_ENV=${MIX_ENV:-dev}"
  exit 1
fi

echo "=== Resetting Personal Brand local database ==="
echo "Environment: dev"
echo "Database:    $DB_NAME"
echo "Seed data:   $SEED"
echo "Uploads:     $RESET_UPLOADS"
echo ""

if ! "$POSTGRES_BIN/pg_isready" -h localhost -p 5432 > /dev/null 2>&1; then
  echo "Starting PostgreSQL..."
  brew services start postgresql@16
  sleep 3
fi

if ! "$POSTGRES_BIN/pg_isready" -h localhost -p 5432 > /dev/null 2>&1; then
  echo "Error: PostgreSQL is not accepting connections on localhost:5432."
  exit 1
fi

PHX_WAS_RUNNING=false
PHX_PID=$(lsof -tiTCP:4000 -sTCP:LISTEN 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)

if [ -n "$PHX_PID" ]; then
  PHX_WAS_RUNNING=true
  echo "Stopping Phoenix before dropping database (PID: $PHX_PID)..."
  "$SCRIPT_DIR/stop-local.sh"
fi

cd "$APP_DIR"

echo "Dropping and recreating $DB_NAME..."
MIX_ENV=dev mix ecto.drop --force
MIX_ENV=dev mix ecto.create
MIX_ENV=dev mix ecto.migrate

if [ "$SEED" = true ]; then
  echo "Seeding baseline development data..."
  MIX_ENV=dev mix run priv/repo/seeds.exs
else
  echo "Skipping seed data. Database is migrated but empty."
fi

if [ "$RESET_UPLOADS" = true ]; then
  echo "Resetting local uploads while keeping git-tracked seed/demo assets..."
  mkdir -p priv/static/uploads

  while IFS= read -r file; do
    repo_file="personal_brand/$file"

    if git -C "$ROOT_DIR" ls-files --error-unmatch "$repo_file" > /dev/null 2>&1; then
      echo "Keeping tracked upload: $repo_file"
    else
      rm -f "$file"
    fi
  done < <(find priv/static/uploads -type f)

  find priv/static/uploads -type d -empty -delete
  mkdir -p priv/static/uploads
fi

cd "$ROOT_DIR"

if [ "$RESTART" = true ] && [ "$PHX_WAS_RUNNING" = true ]; then
  echo "Restarting Phoenix in daemon mode..."
  "$SCRIPT_DIR/start-local.sh" --daemon
elif [ "$RESTART" = true ]; then
  echo "Phoenix was not running before reset, leaving it stopped."
else
  echo "Phoenix restart skipped by --no-restart."
fi

echo "=== Local database reset complete ==="

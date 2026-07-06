#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env.production}"
COMPOSE_FILE="$ROOT_DIR/compose.production.yml"

backup_file="${1:-}"
if [[ -z "$backup_file" || "$backup_file" == "-h" || "$backup_file" == "--help" ]]; then
  echo "Usage: ALLOW_PRODUCTION_RESTORE=yes [DROP_EXISTING_DB=yes] scripts/restore-production-db.sh <backup.dump>"
  exit 1
fi

[[ -f "$backup_file" ]] || { echo "Backup file not found: $backup_file"; exit 1; }
[[ -f "$ENV_FILE" ]] || { echo "Missing env file: $ENV_FILE"; exit 1; }
[[ "${ALLOW_PRODUCTION_RESTORE:-}" == "yes" ]] || { echo "Refusing restore without ALLOW_PRODUCTION_RESTORE=yes"; exit 1; }

compose=(docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE")

"${compose[@]}" exec -T postgres pg_restore --list < "$backup_file" >/dev/null

if [[ "${DROP_EXISTING_DB:-}" == "yes" ]]; then
  "${compose[@]}" exec -T postgres psql -U personal_brand -d personal_brand_prod \
    -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO personal_brand; GRANT ALL ON SCHEMA public TO public;"
fi

"${compose[@]}" exec -T postgres pg_restore \
  -U personal_brand \
  -d personal_brand_prod \
  --no-owner \
  --role=personal_brand \
  < "$backup_file"

echo "Restore complete."

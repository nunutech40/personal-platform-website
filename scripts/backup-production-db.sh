#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env.production}"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
COMPOSE_FILE="$ROOT_DIR/compose.production.yml"

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
output="$BACKUP_DIR/personal-brand-$timestamp.dump"
temporary="$output.partial"
trap 'rm -f "$temporary"' EXIT

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" \
  exec -T postgres pg_dump -U personal_brand -d personal_brand_prod --format=custom > "$temporary"
[[ -s "$temporary" ]] || { echo "Backup is empty"; exit 1; }
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" \
  exec -T postgres pg_restore --list < "$temporary" >/dev/null
mv "$temporary" "$output"
chmod 600 "$output"
find "$BACKUP_DIR" -type f -name 'personal-brand-*.dump' -mtime "+$RETENTION_DAYS" -delete
echo "Backup created: $output"

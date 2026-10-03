#!/usr/bin/env bash
# LOCAL ONLY — OpenMetadata spike. Do not use for production deploy.
# Stops the local OM docker-compose stack.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PURGE=0

usage() {
  cat <<'EOF'
Usage: down.sh [--purge]

  Stops OpenMetadata containers (keeps volumes by default).

  --purge   Also remove named volumes and ./docker-volume data.
  -h        Show this help.

LOCAL ONLY — not for production.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --purge) PURGE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker not found. Install Docker Desktop / Engine, then retry." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "error: docker compose v2 not available. Install Compose plugin, then retry." >&2
  exit 1
fi

cd "${OM_DIR}"

if [[ "${PURGE}" -eq 1 ]]; then
  echo "Tearing down OpenMetadata (containers + volumes + docker-volume/)..."
  docker compose down -v
  rm -rf "${OM_DIR}/docker-volume"
  echo "Purged local OM data under ${OM_DIR}/docker-volume"
else
  echo "Stopping OpenMetadata (keeping volumes)..."
  docker compose down
  echo "Volumes retained. Use --purge to wipe MySQL/ES/Airflow state."
fi

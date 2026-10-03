#!/usr/bin/env bash
# LOCAL ONLY — OpenMetadata spike. Do not use for production deploy.
# Runs registry → OM ingestion (dry-run by default; --live optional).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${OM_DIR}/../.." && pwd)"

LIVE=0
REFRESH_REGISTRY=0
PASSTHROUGH=()

usage() {
  cat <<'EOF'
Usage: ingest.sh [--live] [--refresh-registry]

  From the repo root, runs the Dart ingestion script.
  Dry-run by default (writes fixtures/om_catalog_payload.json).
  Does not require Docker unless --live is set.

  --live               Push payload to local OM (needs stack healthy).
  --refresh-registry   Re-dump registry.json before ingest.
  -h                   Show this help.

Live credentials (optional env): OM_BASE_URL, OM_EMAIL, OM_PASSWORD
Defaults: http://localhost:8585 , admin / admin (local only).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --live) LIVE=1; PASSTHROUGH+=(--live); shift ;;
    --refresh-registry) REFRESH_REGISTRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! command -v dart >/dev/null 2>&1; then
  echo "error: dart not found. Install Dart SDK (or Flutter SDK), then retry." >&2
  exit 1
fi

cd "${REPO_ROOT}"

if [[ "${REFRESH_REGISTRY}" -eq 1 ]]; then
  echo "Refreshing registry fixture..."
  dart run tool/dump_data_catalog.dart --out tool/openmetadata/fixtures/registry.json
fi

if [[ "${LIVE}" -eq 1 ]]; then
  echo "Live ingest against ${OM_BASE_URL:-http://localhost:8585} (local only)..."
else
  echo "Dry-run ingest (no Docker / credentials required)..."
fi

dart run tool/openmetadata/ingestion/ingest_from_registry.dart "${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"}"

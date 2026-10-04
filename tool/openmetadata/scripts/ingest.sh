#!/usr/bin/env bash
# LOCAL ONLY — OpenMetadata spike. Do not use for production deploy.
# Runs registry → OM ingestion (dry-run by default; --live optional).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${OM_DIR}/../.." && pwd)"

LIVE=0
REFRESH_REGISTRY=0
WITH_DQ=0
SKIP_SAMPLE=0
BACKUP=""
PASSTHROUGH=()

usage() {
  cat <<'EOF'
Usage: ingest.sh [--live] [--refresh-registry] [--with-dq] [--skip-sample-data] [--backup PATH]

  From the repo root, runs the Dart ingestion script.
  Dry-run by default (writes fixtures/om_catalog_payload.json).
  Does not require Docker unless --live is set.

  --live               Push payload to local OM (needs stack healthy).
  --refresh-registry   Re-dump registry.json before ingest.
  --with-dq            Run DataQualityScanner + OM DQ bridge
                       (dry-run writes fixtures/om_dq_bridge_payload.json).
  --skip-sample-data   Do not PUT sample rows on live ingest.
  --backup PATH        With --with-dq, scan this backup JSON instead of
                       fixtures/sample_entities.json.
  -h                   Show this help.

Live credentials (optional env): OM_BASE_URL, OM_EMAIL, OM_PASSWORD
Defaults: http://localhost:8585 , admin@open-metadata.org / admin (local only).
OM_PASSWORD is plaintext; the Dart ingest Base64-encodes it for the login API.

See also: scripts/dq_to_om.sh , scripts/profiler.sh
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --live) LIVE=1; PASSTHROUGH+=(--live); shift ;;
    --refresh-registry) REFRESH_REGISTRY=1; shift ;;
    --with-dq) WITH_DQ=1; PASSTHROUGH+=(--with-dq); shift ;;
    --skip-sample-data) SKIP_SAMPLE=1; PASSTHROUGH+=(--skip-sample-data); shift ;;
    --backup)
      BACKUP="${2:-}"
      if [[ -z "${BACKUP}" ]]; then
        echo "error: --backup requires a path" >&2
        exit 2
      fi
      PASSTHROUGH+=(--backup "${BACKUP}")
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

resolve_dart() {
  if command -v dart >/dev/null 2>&1; then
    command -v dart
    return 0
  fi
  if command -v flutter >/dev/null 2>&1; then
    local flutter_bin
    flutter_bin="$(command -v flutter)"
    local sibling
    sibling="$(cd "$(dirname "${flutter_bin}")" && pwd)/dart"
    if [[ -x "${sibling}" ]]; then
      echo "${sibling}"
      return 0
    fi
  fi
  return 1
}

DART_BIN="$(resolve_dart)" || {
  echo "error: dart not found. Install Dart SDK (or Flutter SDK), then retry." >&2
  exit 1
}

cd "${REPO_ROOT}"

if [[ "${REFRESH_REGISTRY}" -eq 1 ]]; then
  echo "Refreshing registry fixture..."
  "${DART_BIN}" run tool/dump_data_catalog.dart --out tool/openmetadata/fixtures/registry.json
fi

if [[ "${LIVE}" -eq 1 ]]; then
  echo "Live ingest against ${OM_BASE_URL:-http://localhost:8585} (local only)..."
else
  echo "Dry-run ingest (no Docker / credentials required)..."
fi
if [[ "${WITH_DQ}" -eq 1 ]]; then
  echo "Including Dart → OM data-quality bridge..."
fi
if [[ "${SKIP_SAMPLE}" -eq 1 ]]; then
  echo "Skipping sample data push..."
fi

"${DART_BIN}" run tool/openmetadata/ingestion/ingest_from_registry.dart "${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"}"

#!/usr/bin/env bash
# LOCAL ONLY — run DataQualityScanner and publish results to OpenMetadata.
# Product DQ remains in-app Salute dati; OM is a viewer/bridge.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${OM_DIR}/../.." && pwd)"

LIVE=0
BACKUP=""
PASSTHROUGH=(--with-dq)

usage() {
  cat <<'EOF'
Usage: dq_to_om.sh [--live] [--backup path.json]

  Runs the in-repo DataQualityScanner on the OM sample fixture (or a backup
  JSON) and builds / publishes an OM 1.5.15 DQ bridge payload.

  Dry-run by default (writes fixtures/om_dq_bridge_payload.json).
  --live also refreshes catalog + sample data, then publishes test
  definition / suite / cases / results + description badges.

  --live               Push to local OM (stack must be healthy).
  --backup PATH        Scan a user backup JSON instead of sample_entities.
  -h                   Help

Env: OM_BASE_URL, OM_EMAIL, OM_PASSWORD (same as ingest.sh).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --live) LIVE=1; PASSTHROUGH+=(--live); shift ;;
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
    local flutter_bin sibling
    flutter_bin="$(command -v flutter)"
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

if [[ "${LIVE}" -eq 1 ]]; then
  echo "Live DQ bridge against ${OM_BASE_URL:-http://localhost:8585} (local only)..."
else
  echo "Dry-run DQ bridge (no Docker required)..."
fi

"${DART_BIN}" run tool/openmetadata/ingestion/ingest_from_registry.dart "${PASSTHROUGH[@]}"

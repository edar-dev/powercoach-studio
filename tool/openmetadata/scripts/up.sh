#!/usr/bin/env bash
# LOCAL ONLY — OpenMetadata spike. Do not use for production deploy.
# Starts the pinned OM 1.5.15 docker-compose stack in the background.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OM_BASE_URL="${OM_BASE_URL:-http://localhost:8585}"
WAIT=0

usage() {
  cat <<'EOF'
Usage: up.sh [--wait]

  Starts OpenMetadata via docker compose (detached).
  Prints UI URL and default local admin credentials.

  --wait   After start, poll health until ready (or timeout).
  -h       Show this help.

LOCAL ONLY — default login admin/admin. Never expose publicly.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wait) WAIT=1; shift ;;
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
echo "Starting OpenMetadata (local spike) from ${OM_DIR} ..."
docker compose up --detach

echo
echo "UI:    ${OM_BASE_URL}"
echo "Login: admin / admin  (local quickstart only — never expose publicly)"
echo
echo "Tip: wait until healthy with:"
echo "  ${SCRIPT_DIR}/health.sh --wait"

if [[ "${WAIT}" -eq 1 ]]; then
  echo
  echo "Waiting for health..."
  "${SCRIPT_DIR}/health.sh" --wait
fi

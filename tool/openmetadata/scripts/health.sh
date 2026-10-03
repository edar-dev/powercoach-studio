#!/usr/bin/env bash
# LOCAL ONLY — OpenMetadata spike. Do not use for production deploy.
# Checks whether the local OM API is ready.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_BASE_URL="${OM_BASE_URL:-http://localhost:8585}"
HEALTH_URL="${OM_BASE_URL%/}/api/v1/system/version"
WAIT=0
TIMEOUT_SECS="${OM_HEALTH_TIMEOUT_SECS:-180}"
INTERVAL_SECS="${OM_HEALTH_INTERVAL_SECS:-5}"

usage() {
  cat <<'EOF'
Usage: health.sh [--wait] [--timeout SECS]

  Probes OpenMetadata at /api/v1/system/version.
  Exit 0 when healthy, non-zero otherwise.

  --wait            Retry until healthy or timeout (default 180s).
  --timeout SECS    Timeout for --wait (env: OM_HEALTH_TIMEOUT_SECS).
  -h                Show this help.

Override base URL with OM_BASE_URL (default http://localhost:8585).
LOCAL ONLY — not for production / CI hard dependency.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wait) WAIT=1; shift ;;
    --timeout)
      if [[ $# -lt 2 ]]; then
        echo "error: --timeout requires a value" >&2
        exit 2
      fi
      TIMEOUT_SECS="$2"
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

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl not found. Install curl, then retry." >&2
  exit 1
fi

check_once() {
  # -f fails on HTTP >= 400; -sS silent but show errors; short connect timeout.
  local body
  if body="$(curl -fsS --connect-timeout 3 --max-time 10 "${HEALTH_URL}" 2>/dev/null)"; then
    echo "healthy: ${HEALTH_URL}"
    if [[ -n "${body}" ]]; then
      echo "${body}" | head -c 400
      echo
    fi
    return 0
  fi
  return 1
}

if [[ "${WAIT}" -eq 0 ]]; then
  if check_once; then
    exit 0
  fi
  echo "unhealthy: cannot reach ${HEALTH_URL}" >&2
  echo "hint: start stack with ${SCRIPT_DIR}/up.sh then retry with --wait" >&2
  exit 1
fi

echo "Waiting up to ${TIMEOUT_SECS}s for ${HEALTH_URL} ..."
deadline=$((SECONDS + TIMEOUT_SECS))
while (( SECONDS < deadline )); do
  if check_once; then
    exit 0
  fi
  remaining=$((deadline - SECONDS))
  echo "  not ready yet (${remaining}s left); retry in ${INTERVAL_SECS}s ..."
  sleep "${INTERVAL_SECS}"
done

echo "unhealthy: timed out after ${TIMEOUT_SECS}s waiting for ${HEALTH_URL}" >&2
exit 1

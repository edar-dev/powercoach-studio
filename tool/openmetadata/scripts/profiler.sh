#!/usr/bin/env bash
# LOCAL / STAGING ONLY — render or run the OM Postgres profiler recipe.
# Never bake production DB passwords into compose or commit secrets.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE="${OM_DIR}/profiler/postgres_coach_entities.yaml.template"
RENDERED="${OM_DIR}/profiler/postgres_coach_entities.rendered.yaml"

MODE=""
usage() {
  cat <<'EOF'
Usage: profiler.sh --render | --print-env | --run

  Optional Postgres profiler against public.coach_entities (OM 1.5.15).

  --render      Write profiler/postgres_coach_entities.rendered.yaml (gitignored)
  --print-env   Show required env vars (no secrets printed)
  --run         Render, copy into ingestion container, run `metadata ingest`
  -h            Help

Connection (pick one style):

  A) URL:
     OM_PROFILER_DB_URL=postgresql://user:pass@host:5432/dbname

  B) Components:
     OM_PROFILER_DB_HOST / OM_PROFILER_DB_PORT / OM_PROFILER_DB_NAME
     OM_PROFILER_DB_USER / OM_PROFILER_DB_PASSWORD

OpenMetadata (for --run):

  OM_PROFILER_OM_HOST_PORT   default http://openmetadata-server:8585/api
                             (from inside the ingestion container)
  OM_PROFILER_OM_JWT          JWT with ingestion bot privileges
                             (OM Settings → Bots → ingestion-bot)

WARN: local/staging only. Do not casually profile production.
JSONB payload columns only get document-level stats in OM.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --render) MODE=render; shift ;;
    --print-env) MODE=print-env; shift ;;
    --run) MODE=run; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${MODE}" ]]; then
  usage >&2
  exit 2
fi

parse_db_url() {
  # postgresql://user:pass@host:port/db
  local url="$1"
  if [[ ! "${url}" =~ ^postgres(ql)?://([^:]+):([^@]+)@([^:/]+):([0-9]+)/([^?]+)$ ]]; then
    echo "error: OM_PROFILER_DB_URL must look like postgresql://user:pass@host:port/db" >&2
    exit 2
  fi
  OM_PROFILER_DB_USER="${BASH_REMATCH[2]}"
  OM_PROFILER_DB_PASSWORD="${BASH_REMATCH[3]}"
  OM_PROFILER_DB_HOST="${BASH_REMATCH[4]}"
  OM_PROFILER_DB_PORT="${BASH_REMATCH[5]}"
  OM_PROFILER_DB_NAME="${BASH_REMATCH[6]}"
}

ensure_db_env() {
  if [[ -n "${OM_PROFILER_DB_URL:-}" ]]; then
    parse_db_url "${OM_PROFILER_DB_URL}"
  fi
  : "${OM_PROFILER_DB_HOST:?set OM_PROFILER_DB_HOST or OM_PROFILER_DB_URL}"
  : "${OM_PROFILER_DB_PORT:=5432}"
  : "${OM_PROFILER_DB_NAME:?set OM_PROFILER_DB_NAME or OM_PROFILER_DB_URL}"
  : "${OM_PROFILER_DB_USER:?set OM_PROFILER_DB_USER or OM_PROFILER_DB_URL}"
  : "${OM_PROFILER_DB_PASSWORD:?set OM_PROFILER_DB_PASSWORD or OM_PROFILER_DB_URL}"
  : "${OM_PROFILER_OM_HOST_PORT:=http://openmetadata-server:8585/api}"
}

render_recipe() {
  ensure_db_env
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "error: missing template ${TEMPLATE}" >&2
    exit 1
  fi
  # shellcheck disable=SC2016
  export OM_PROFILER_DB_HOST OM_PROFILER_DB_PORT OM_PROFILER_DB_NAME
  export OM_PROFILER_DB_USER OM_PROFILER_DB_PASSWORD
  export OM_PROFILER_OM_HOST_PORT
  export OM_PROFILER_OM_JWT="${OM_PROFILER_OM_JWT:-REPLACE_ME_INGESTION_BOT_JWT}"

  python3 - <<'PY' "${TEMPLATE}" "${RENDERED}"
import os, sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
for key in (
    "OM_PROFILER_DB_HOST",
    "OM_PROFILER_DB_PORT",
    "OM_PROFILER_DB_NAME",
    "OM_PROFILER_DB_USER",
    "OM_PROFILER_DB_PASSWORD",
    "OM_PROFILER_OM_HOST_PORT",
    "OM_PROFILER_OM_JWT",
):
    text = text.replace("${%s}" % key, os.environ.get(key, ""))
open(dst, "w", encoding="utf-8").write(text)
print(dst)
PY
  echo "Rendered ${RENDERED} (do not commit; contains secrets if password set)."
}

case "${MODE}" in
  print-env)
    cat <<'EOF'
Required:
  OM_PROFILER_DB_URL   OR   OM_PROFILER_DB_HOST/PORT/NAME/USER/PASSWORD
For --run:
  OM_PROFILER_OM_JWT          (ingestion bot JWT from OM UI)
Optional:
  OM_PROFILER_OM_HOST_PORT    default http://openmetadata-server:8585/api
EOF
    ;;
  render)
    render_recipe
    ;;
  run)
    if [[ -z "${OM_PROFILER_OM_JWT:-}" ]]; then
      echo "error: OM_PROFILER_OM_JWT is required for --run (OM ingestion bot JWT)." >&2
      exit 2
    fi
    render_recipe
    if ! docker ps --format '{{.Names}}' | grep -qx 'openmetadata_ingestion'; then
      echo "error: openmetadata_ingestion container not running. Start with scripts/up.sh" >&2
      exit 1
    fi
    docker cp "${RENDERED}" openmetadata_ingestion:/tmp/powercoach_profiler.yaml
    echo "Running metadata ingest inside openmetadata_ingestion (local/staging only)..."
    docker exec openmetadata_ingestion \
      metadata ingest -c /tmp/powercoach_profiler.yaml
    echo "Profiler workflow finished. Inspect service powercoach_postgres_profiler in OM UI."
    ;;
esac

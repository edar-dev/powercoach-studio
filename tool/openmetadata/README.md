# OpenMetadata local spike

Local-only OpenMetadata viewer for the PowerCoach **in-repo data catalog**.
The Dart registry (`lib/core/data_catalog/`) remains the source of truth; OM is
an optional ingestion target.

> **LOCAL ONLY.** Default quickstart UI login is `admin@open-metadata.org` /
> `admin`. Never expose this stack on a public network. Not used in CI. No
> production SaaS deploy.

## Prerequisites

- Docker Compose v2 (for `up` / `down` / live ingest)
- Dart SDK (for ingestion; Flutter SDK works too)
- `curl` (for `health.sh`)
- Optional for profiler: Python 3 (template render) + OM ingestion bot JWT

Pinned stack: OpenMetadata **1.5.15** (`docker-compose.yml` from the upstream
[1.5.15-release](https://github.com/open-metadata/OpenMetadata/releases/tag/1.5.15-release) asset).

## Recommended workflow (scripts)

From the **repo root**:

```bash
# Start stack (prints UI URL + admin@open-metadata.org / admin)
tool/openmetadata/scripts/up.sh

# Wait until API is ready (or fail with clear status)
tool/openmetadata/scripts/health.sh --wait

# Dry-run ingest (no Docker needed) — writes fixtures/om_catalog_payload.json
# (includes sampleDataByTable for every catalog table)
tool/openmetadata/scripts/ingest.sh

# Live-push: schema + lineage + Sample Data tab rows
tool/openmetadata/scripts/ingest.sh --refresh-registry --live

# Live-push + Dart → OM data-quality bridge
tool/openmetadata/scripts/ingest.sh --live --with-dq

# Stop (keep volumes). Wipe local data with --purge
tool/openmetadata/scripts/down.sh
# tool/openmetadata/scripts/down.sh --purge
```

One-liner flow (works out of the box after a fresh `up` + healthy API):

```bash
tool/openmetadata/scripts/up.sh && \
  tool/openmetadata/scripts/health.sh --wait && \
  tool/openmetadata/scripts/ingest.sh --live --with-dq && \
  tool/openmetadata/scripts/down.sh
```

| Script | Role |
|--------|------|
| `scripts/up.sh` | `docker compose up --detach`; optional `--wait` for health |
| `scripts/health.sh` | Probe `/api/v1/system/version`; `--wait` + `--timeout SECS` |
| `scripts/ingest.sh` | Dry-run by default; `--live`; `--with-dq`; `--refresh-registry` |
| `scripts/dq_to_om.sh` | DQ bridge only (`--live` / `--backup`) |
| `scripts/profiler.sh` | Optional Postgres profiler recipe (`--render` / `--run`) |
| `scripts/down.sh` | `docker compose down`; `--purge` → `down -v` + `rm -rf docker-volume` |

### Defaults (local only)

| Item | Value |
|------|-------|
| UI | http://localhost:8585 |
| **UI login** | `admin@open-metadata.org` / `admin` |
| Health endpoint | `http://localhost:8585/api/v1/system/version` |

> **UI vs API login:** the browser form uses the email above with plaintext
> `admin`. The REST login (`POST /api/v1/users/login`) requires the same email
> and a **Base64-encoded** password (`admin` → `YWRtaW4=`). `ingest.sh --live`
> does that encoding for you — pass plaintext via `OM_PASSWORD` if you override.

### Live ingest env overrides

| Env | Default | Purpose |
|-----|---------|---------|
| `OM_BASE_URL` | `http://localhost:8585` | Server |
| `OM_EMAIL` | `admin@open-metadata.org` | Quickstart user (email, not bare `admin`) |
| `OM_PASSWORD` | `admin` | Quickstart password (**plaintext**; ingest Base64-encodes for the API) |
| `OM_HEALTH_TIMEOUT_SECS` | `180` | `health.sh --wait` timeout |
| `OM_HEALTH_INTERVAL_SECS` | `5` | Poll interval while waiting |

Dry-run needs **no** credentials and does **not** require Docker.

Live ingest also resolves each table UUID (via create response or
`GET /api/v1/tables/name/{fqn}`) before `PUT /api/v1/lineage`. OM 1.5.x rejects
FQNs in `EntityReference.id`.

## Sample data

Live ingest (unless `--skip-sample-data`) builds anonymized **TableData** from
`fixtures/sample_entities.json` (+ synthetic prefs rows for catalog buckets)
and `PUT`s them to `/api/v1/tables/{id}/sampleData`.

- Visible in OM UI under each table’s **Sample Data** tab.
- Dry-run embeds the same structure in `fixtures/om_catalog_payload.json` under
  `sampleDataByTable` (no Docker).
- Fixture entities are synthetic/demo only (`*.example.local`, demo coach id).

```bash
# Inspect sample rows without Docker
tool/openmetadata/scripts/ingest.sh
jq '.sampleDataByTable.customer' tool/openmetadata/fixtures/om_catalog_payload.json

# Push catalog + sample data
tool/openmetadata/scripts/ingest.sh --live
```

## Data quality bridge

In-app **Salute dati** (`lib/core/data_quality/` + Settings UI) remains the
product source of truth. OM only **views** bridged results.

The bridge:

1. Runs `DataQualityScanner` on `sample_entities.json` (or `--backup path.json`)
2. Builds a custom OM 1.5.15 test definition `powercoachDartScanner`, a logical
   hub suite `powercoach_dart_dq`, and **per-table executable** suites
   (`POST …/testSuites/executable`, name `{table}.testSuite`) with cases +
   results (FQN `{tableFqn}.{caseName}`) so Test Cases show Success in the UI
3. Appends a short **Dart DQ bridge** badge to each table description

Live HTTP bodies are written as UTF-8 bytes (lineage descriptions may contain
`→`; Latin-1 `HttpClientRequest.write` would crash).

```bash
# Dry-run → fixtures/om_dq_bridge_payload.json
tool/openmetadata/scripts/dq_to_om.sh
# or
tool/openmetadata/scripts/ingest.sh --with-dq

# Publish to local OM (also refreshes catalog + sample data)
tool/openmetadata/scripts/ingest.sh --live --with-dq
tool/openmetadata/scripts/dq_to_om.sh --live

# Scan a real backup export instead of the fixture
tool/openmetadata/scripts/dq_to_om.sh --live --backup /path/to/backup.json
```

Refresh anytime with the same commands (idempotent enough for spike re-runs:
create-or-get definition/suite/cases, then PUT results + PATCH descriptions).

## Profiler (optional Postgres)

Optional OM ingestion/profiler workflow against the **physical**
`public.coach_entities` table. This is separate from the Dart CustomDatabase
catalog (`cloud_sot.*` logical tables).

> **LOCAL / STAGING ONLY.** Never bake production DB passwords into
> `docker-compose.yml`. Pass credentials via env. Do not casually profile
> production — prefer a local Postgres copy or a staging Supabase project with
> a **read-only** role.

### JSONB limitations

`coach_entities.payload` is JSONB. OM’s Postgres profiler reports
document-level column stats (null %, distinct approximates, etc.) — **not**
nested field metrics inside the JSON. Soft-deleted rows (`deleted_at`) remain
visible unless you profile a filtered view.

### Env

| Env | Purpose |
|-----|---------|
| `OM_PROFILER_DB_URL` | `postgresql://user:pass@host:port/db` (preferred) |
| or `OM_PROFILER_DB_HOST` / `PORT` / `NAME` / `USER` / `PASSWORD` | Components |
| `OM_PROFILER_OM_JWT` | Ingestion bot JWT (OM UI → Settings → Bots) — required for `--run` |
| `OM_PROFILER_OM_HOST_PORT` | Default `http://openmetadata-server:8585/api` (from ingestion container) |

### Commands

```bash
# Show required env (no secrets)
tool/openmetadata/scripts/profiler.sh --print-env

# Render recipe → profiler/postgres_coach_entities.rendered.yaml (gitignored)
export OM_PROFILER_DB_URL='postgresql://readonly:***@db.example:5432/postgres'
tool/openmetadata/scripts/profiler.sh --render

# Run via the compose ingestion container (stack must be up)
export OM_PROFILER_OM_JWT='...'   # ingestion-bot JWT
tool/openmetadata/scripts/profiler.sh --run
```

Template: `profiler/postgres_coach_entities.yaml.template`  
Rendered files matching `*.rendered.yaml` are gitignored.

Manual alternative: copy the rendered YAML into Airflow/OM UI as an ingestion
workflow against service name `powercoach_postgres_profiler`.

## Health check

```bash
# Single probe — exit 0 healthy, non-zero otherwise
tool/openmetadata/scripts/health.sh

# Retry until ready (first boot can take a few minutes)
tool/openmetadata/scripts/health.sh --wait
tool/openmetadata/scripts/health.sh --wait --timeout 300
```

## CI / production policy

- **Not used in CI** — no workflow depends on Docker OM or these scripts.
- **No production deploy** — this spike is for local exploration only.
- The in-repo Dart catalog + `docs/data-catalog.md` remain authoritative.
- Unit tests cover dry-run payload / sample data / DQ bridge builders only.

## Advanced: raw docker / dart commands

From `tool/openmetadata/`:

```bash
docker compose up --detach
docker compose down          # keep volumes
docker compose down -v && rm -rf docker-volume   # full teardown
```

From the **repo root**:

```bash
dart run tool/dump_data_catalog.dart --out tool/openmetadata/fixtures/registry.json
dart run tool/openmetadata/ingestion/ingest_from_registry.dart
dart run tool/openmetadata/ingestion/ingest_from_registry.dart --live --with-dq
dart run tool/openmetadata/ingestion/push_dq_to_om.dart --live
```

`docker-volume/` is gitignored (MySQL / ES / Airflow state).

### Spike acceptance

After dry-run or live ingest, the payload / UI should show:

1. All **5** current coach entity types (`customer`, `workoutPlan`,
   `measurement`, `customExercise`, `customerNote`) with cloud SoT locus
   `supabaseCoachEntities` (+ Drift cache) plus prefs buckets
   (`userProfile`, `pdfBrand`, `userPreferences`, …).
2. Lineage edges **`customer → workoutPlan`** and **`customer → measurement`**
   (from registry soft refs + `fixtures/sample_entities.json`).
3. **Sample Data** rows on each catalog table (fixture + synthetic prefs).
4. With `--with-dq`: test suite `powercoach_dart_dq` + description badges.

## Layout

| Path | Role |
|------|------|
| `docker-compose.yml` | Pinned OM 1.5.15 quickstart stack |
| `scripts/` | Local ops: up / health / ingest / dq_to_om / profiler / down |
| `fixtures/registry.json` | Catalog dump for ingestion |
| `fixtures/sample_entities.json` | Anonymized entity graph + prefs + expected lineage |
| `fixtures/om_catalog_payload.json` | Generated dry-run payload (committed after dump) |
| `fixtures/om_dq_bridge_payload.json` | Generated DQ bridge dry-run (optional commit) |
| `ingestion/ingest_from_registry.dart` | Custom ingest (dry-run / `--live` / `--with-dq`) |
| `ingestion/om_sample_data.dart` | TableData builders for Sample Data tab |
| `ingestion/om_dq_bridge.dart` | Dart scanner → OM test payloads |
| `ingestion/om_live_defaults.dart` | OM 1.5.15 login/lineage helpers |
| `profiler/*.yaml.template` | Optional Postgres profiler recipe |

## Related docs

- [`docs/data-catalog.md`](../../docs/data-catalog.md) — human catalog + Mermaid ER
- [`docs/sync-strategy.md`](../../docs/sync-strategy.md) — cloud SoT / pull / migration

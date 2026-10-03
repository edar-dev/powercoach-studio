# OpenMetadata local spike

Local-only OpenMetadata viewer for the PowerCoach **in-repo data catalog**.
The Dart registry (`lib/core/data_catalog/`) remains the source of truth; OM is
an optional ingestion target.

**Non-goals:** no CI job depends on OM, no production deploy, no secrets in repo.

## Prerequisites

- Docker Compose v2
- Dart SDK (for the custom ingestion script; Flutter SDK works too)

Pinned stack: OpenMetadata **1.5.15** (`docker-compose.yml` from the upstream
[1.5.15-release](https://github.com/open-metadata/OpenMetadata/releases/tag/1.5.15-release) asset).

## Start / stop / teardown

From this directory (`tool/openmetadata/`):

```bash
# Start (downloads images on first run; UI ~2–5 minutes)
docker compose up --detach

# UI
open http://localhost:8585
# Default quickstart login: admin / admin  (local only)

# Stop containers (keep volumes)
docker compose stop

# Full teardown (containers + local docker-volume data)
docker compose down -v
rm -rf docker-volume
```

`docker-volume/` is gitignored (MySQL / ES / Airflow state).

## Refresh registry fixture

From the **repo root**:

```bash
dart run tool/dump_data_catalog.dart --out tool/openmetadata/fixtures/registry.json
```

## Custom ingestion (registry → OM payload / live API)

```bash
# Dry-run (default): builds fixtures/om_catalog_payload.json
dart run tool/openmetadata/ingestion/ingest_from_registry.dart

# Live push to local OM (after compose is healthy)
dart run tool/openmetadata/ingestion/ingest_from_registry.dart --live
```

Optional env for live mode:

| Env | Default | Purpose |
|-----|---------|---------|
| `OM_BASE_URL` | `http://localhost:8585` | Server |
| `OM_EMAIL` | `admin` | Quickstart user |
| `OM_PASSWORD` | `admin` | Quickstart password |

Dry-run needs **no** credentials and is what CI/local validation uses.

### Spike acceptance

After dry-run or live ingest, the payload / UI should show:

1. All **5** current Drift `OfflineEntityType` tables (`customer`, `workoutPlan`,
   `measurement`, `customExercise`, `customerNote`) plus prefs buckets
   (`userProfile`, `pdfBrand`, `userPreferences`, …).
2. Lineage edges **`customer → workoutPlan`** and **`customer → measurement`**
   (from registry soft refs + `fixtures/sample_entities.json`).

## Layout

| Path | Role |
|------|------|
| `docker-compose.yml` | Pinned OM 1.5.15 quickstart stack |
| `fixtures/registry.json` | Catalog dump for ingestion |
| `fixtures/sample_entities.json` | Demo entity graph + expected lineage |
| `fixtures/om_catalog_payload.json` | Generated dry-run payload (committed after dump) |
| `ingestion/ingest_from_registry.dart` | Custom ingest (dry-run / `--live`) |

## Related docs

- [`docs/data-catalog.md`](../../docs/data-catalog.md) — human catalog + Mermaid ER
- [`docs/sync-strategy.md`](../../docs/sync-strategy.md) — local-first / backup path

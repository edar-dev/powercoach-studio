# OpenMetadata local spike

Local-only OpenMetadata viewer for the PowerCoach **in-repo data catalog**.
The Dart registry (`lib/core/data_catalog/`) remains the source of truth; OM is
an optional ingestion target.

> **LOCAL ONLY.** Default quickstart login is `admin` / `admin`. Never expose
> this stack on a public network. Not used in CI. No production SaaS deploy.

## Prerequisites

- Docker Compose v2 (for `up` / `down` / live ingest)
- Dart SDK (for ingestion; Flutter SDK works too)
- `curl` (for `health.sh`)

Pinned stack: OpenMetadata **1.5.15** (`docker-compose.yml` from the upstream
[1.5.15-release](https://github.com/open-metadata/OpenMetadata/releases/tag/1.5.15-release) asset).

## Recommended workflow (scripts)

From the **repo root**:

```bash
# Start stack (prints UI URL + admin/admin)
tool/openmetadata/scripts/up.sh

# Wait until API is ready (or fail with clear status)
tool/openmetadata/scripts/health.sh --wait

# Dry-run ingest (no Docker needed) — writes fixtures/om_catalog_payload.json
tool/openmetadata/scripts/ingest.sh

# Optional: refresh registry fixture, then live-push to local OM
tool/openmetadata/scripts/ingest.sh --refresh-registry --live

# Stop (keep volumes). Wipe local data with --purge
tool/openmetadata/scripts/down.sh
# tool/openmetadata/scripts/down.sh --purge
```

One-liner flow:

```bash
tool/openmetadata/scripts/up.sh && \
  tool/openmetadata/scripts/health.sh --wait && \
  tool/openmetadata/scripts/ingest.sh --live && \
  tool/openmetadata/scripts/down.sh
```

| Script | Role |
|--------|------|
| `scripts/up.sh` | `docker compose up --detach`; optional `--wait` for health |
| `scripts/health.sh` | Probe `/api/v1/system/version`; `--wait` + `--timeout SECS` |
| `scripts/ingest.sh` | Dry-run by default; `--live`; `--refresh-registry` |
| `scripts/down.sh` | `docker compose down`; `--purge` → `down -v` + `rm -rf docker-volume` |

### Defaults (local only)

| Item | Value |
|------|-------|
| UI | http://localhost:8585 |
| Login | `admin` / `admin` |
| Health endpoint | `http://localhost:8585/api/v1/system/version` |

### Live ingest env overrides

| Env | Default | Purpose |
|-----|---------|---------|
| `OM_BASE_URL` | `http://localhost:8585` | Server |
| `OM_EMAIL` | `admin` | Quickstart user |
| `OM_PASSWORD` | `admin` | Quickstart password |
| `OM_HEALTH_TIMEOUT_SECS` | `180` | `health.sh --wait` timeout |
| `OM_HEALTH_INTERVAL_SECS` | `5` | Poll interval while waiting |

Dry-run needs **no** credentials and does **not** require Docker.

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
dart run tool/openmetadata/ingestion/ingest_from_registry.dart --live
```

`docker-volume/` is gitignored (MySQL / ES / Airflow state).

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
| `scripts/` | Local ops: up / health / ingest / down |
| `fixtures/registry.json` | Catalog dump for ingestion |
| `fixtures/sample_entities.json` | Demo entity graph + expected lineage |
| `fixtures/om_catalog_payload.json` | Generated dry-run payload (committed after dump) |
| `ingestion/ingest_from_registry.dart` | Custom ingest (dry-run / `--live`) |

## Related docs

- [`docs/data-catalog.md`](../../docs/data-catalog.md) — human catalog + Mermaid ER
- [`docs/sync-strategy.md`](../../docs/sync-strategy.md) — local-first / backup path

# Sync strategy (v4)

## Decision: local-first excellence (Option A — 2026-07)

PowerCoach Studio operates in **local-first** mode. Business data lives on-device;
Supabase is used for authentication and optional cloud **backup snapshots**
(manual + automatic + sync-on-open merge). There is no GymBlog live sync /
`PendingOperations` outbox.

Remote sync replay and the sync-issues UI are **removed from the product surface**.
Multi-device data transfer uses **backup export / import** (file and cloud snapshot)
plus **sync-on-open merge** when local data already exists.

### Rationale

- Coaches need reliable offline access to clients, plans, and session logs.
- Session execution data (diary, adherence, progress panels) is stored in local plan payloads.
- GymBlog.API remote replay is not active and not planned in the near term.
- On web, IndexedDB can be evicted; automatic cloud snapshots + recovery reduce data-loss risk.

### User-facing implications

| Area | Behavior |
|------|----------|
| Data storage | Drift SQLite + plan `planData` JSON (including `sessionExecutions`) |
| Sync issues screen | **Removed** — no user-facing sync queue |
| Multi-device | File export/import, automatic cloud snapshots, sync-on-open merge |
| Cloud snapshots | JSON uploads to Supabase Storage (same envelope as file backup) |
| Auth | Supabase sign-in for account identity; offline data scoped per user |

### Backup as the multi-device path

1. Export JSON from Settings on device A (Share / file, or cloud snapshot).
2. Import on device B with **Merge by id** (default) or **Replace all** (destructive).
3. Merge keeps the entity with the newer `updatedAt` timestamp per id.

### Cloud snapshots (manual + automatic)

Cloud snapshots copy the same backup JSON envelope to the private `user-backups`
Supabase Storage bucket (max 5 per user, oldest pruned).

**Automatic uploads (web-first):** when “Backup cloud automatico” is enabled
(default **on** on web when unset), `CloudSnapshotScheduler` debounces (~90s)
after material local writes (`OfflineLocalStore.upsertEntity`, profile, exported
preferences, pins/recents) and flushes on app pause / web `beforeunload`.
Upload on unload is best-effort — browsers may not allow reliable async upload.

**Empty-local recovery:** after login, if there are no non-deleted customers and
no non-deleted workout plans **and** cloud snapshots exist, the dashboard shows
“Ripristina ultimo backup cloud?” and can run **replace-all** restore.

**Sync-on-open (Phase B):** when local coach data is **not** empty and the newest
cloud snapshot `createdAt` is newer than
`max(local max entity updatedAt, lastSuccessfulBackupAt, lastCloudSyncAt)`,
`SyncOnOpenService` downloads and **mergeRestore**s (newer `updatedAt` wins),
then schedules a push via the auto snapshot debounce. Empty local is left to
the recovery dialog (replace-all only).

Web also requests `navigator.storage.persist()` after auth; Settings shows a
hint when storage is not persisted.

### Internal outbox (removed)

The legacy `PendingOperations` outbox and `SyncMetaEntries` key/value table were dropped from
the Drift schema in v2 (2026-08, Wave C). The migration runs `DROP TABLE IF EXISTS` for both on
upgrade from v1 — this is destructive for any rows left over from earlier local-only builds, but
those rows were unread and unexported since Wave A. **Back up your data (Settings → Backup)
before updating**, especially on web where storage can otherwise be lost if something goes wrong
during the upgrade. New backups do not export pending ops or sync meta; restore ignores those
legacy keys when present in older backup files.

### Future live sync (not implemented)

If remote sync returns, require a new approved plan before reintroducing:

- Sync orchestrator bootstrap
- Sync-issues UI
- Remote conflict resolution

### Related code

- `lib/core/backup/user_data_backup_service.dart` — export, replace restore, merge restore
- `lib/core/backup/cloud_backup_repository.dart` — Supabase Storage snapshots
- `lib/core/backup/cloud_snapshot_scheduler.dart` — debounced automatic uploads
- `lib/core/backup/sync_on_open_service.dart` — merge when cloud is newer
- `lib/core/backup/web_persistence_coordinator.dart` — persist + recovery + auth hooks
- `lib/core/sync/offline_models.dart` / `offline_repository_support.dart` — local entity models

### Data catalog & quality

Entity shapes, soft FKs, and storage loci are documented in
[`docs/data-catalog.md`](data-catalog.md) (source of truth:
`lib/core/data_catalog/`). Optional local OpenMetadata spike:
`tool/openmetadata/`. Read-only data-quality scanner:
`lib/core/data_quality/` (`dart run tool/data_quality_report.dart <backup.json>`).

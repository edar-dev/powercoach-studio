# Sync strategy (v4)

## Decision: local-first excellence (Option A — 2026-07)

PowerCoach Studio operates in **local-first** mode. Business data lives on-device;
Supabase is used for authentication (and optional cloud **backup snapshots** — not live sync).

Remote sync replay and the sync-issues UI are **removed from the product surface**.
Multi-device data transfer uses **backup export / import** (file and optional cloud snapshot).

### Rationale

- Coaches need reliable offline access to clients, plans, and session logs.
- Session execution data (diary, adherence, progress panels) is stored in local plan payloads.
- GymBlog.API remote replay is not active and not planned in the near term.

### User-facing implications

| Area | Behavior |
|------|----------|
| Data storage | Drift SQLite + plan `planData` JSON (including `sessionExecutions`) |
| Sync issues screen | **Removed** — no user-facing sync queue |
| Multi-device | Official path is **backup export / import** with merge-by-id option |
| Cloud snapshots | Optional JSON uploads to Supabase Storage (same envelope as file backup) — **not** live sync |
| Auth | Supabase sign-in for account identity; offline data scoped per user |

### Backup as the multi-device path

1. Export JSON from Settings on device A (Share / file, or cloud snapshot).
2. Import on device B with **Merge by id** (default) or **Replace all** (destructive).
3. Merge keeps the entity with the newer `updatedAt` timestamp per id.

### Cloud snapshots ≠ sync

Cloud snapshots are opt-in copies of the same backup JSON envelope. There is no automatic
merge, conflict UI, or outbox replay. Clearing browser storage still requires a prior backup.

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
- `lib/core/backup/cloud_backup_repository.dart` — optional Supabase Storage snapshots (when enabled)
- `lib/core/sync/offline_models.dart` / `offline_repository_support.dart` — local entity models

# Sync strategy (v4)

## Decision: local-first excellence (Option A — 2026-07)

PowerCoach Studio operates in **local-first** mode (`kLocalFirstSyncMode = true` in
`lib/core/sync/local_first_sync_config.dart`).

Remote sync replay and the sync-issues UI are **removed from the product surface**.
Multi-device data transfer uses **backup export / import** only.

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
| Auth | Supabase sign-in for account identity; offline data scoped per user |

### Backup as the multi-device path

1. Export JSON from Settings on device A.
2. Import on device B with **Merge by id** (default) or **Replace all** (destructive).
3. Merge keeps the entity with the newer `updatedAt` timestamp per id.

### Internal outbox (legacy)

`PendingOperations` may still exist in Drift from earlier writes. There is no replay hook
and no UI to manage them. A future plan may stop writing pending ops or drop the table after
backup migration validation.

### Future cloud comeback (not implemented)

If remote sync returns, require a new approved plan before reintroducing:

- Sync orchestrator bootstrap
- Sync-issues UI
- Remote conflict resolution

Document the migration in release notes before flipping `kLocalFirstSyncMode`.

### Related code

- `lib/core/backup/user_data_backup_service.dart` — export, replace restore, merge restore
- `lib/core/sync/sync_replay_hook.dart` — no-op replay hook (reserved for a future cloud path)
- `lib/core/sync/pending_operation_resolver.dart` — unit-tested resolver (internal)

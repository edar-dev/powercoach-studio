# Sync strategy (v4)

## Decision: local-first excellence

PowerCoach Studio operates in **local-first** mode (`kLocalFirstSyncMode = true` in
`lib/core/sync/local_first_sync_config.dart`).

### Rationale

- Coaches need reliable offline access to clients, plans, and session logs.
- Session execution data (diary, adherence, progress panels) is stored in local plan payloads.
- GymBlog.API remote replay is not active in the current product build.

### User-facing implications

| Area | Behavior |
|------|----------|
| Data storage | Drift SQLite + plan `planData` JSON (including `sessionExecutions`) |
| Sync issues screen | Labeled **Local data queue**; remote "accept" conflict action hidden |
| Multi-device | Official path is **backup export / import** with merge-by-id option |
| Auth | Supabase sign-in for account identity; offline data scoped per user |

### Backup as the multi-device path

1. Export JSON from Settings on device A.
2. Import on device B with **Merge by id** (default) or **Replace all** (destructive).
3. Merge keeps the entity with the newer `updatedAt` timestamp per id.

### Future cloud comeback (not implemented)

If remote sync returns, set `kLocalFirstSyncMode` to `false`, re-enable
`SyncOrchestrator` bootstrap, and restore remote conflict resolution UX.
Document the migration in release notes before flipping the flag.

### Related code

- `lib/core/backup/user_data_backup_service.dart` — export, replace restore, merge restore
- `lib/features/settings/presentation/screens/sync_issues_screen.dart` — local queue UI
- `lib/core/sync/sync_replay_hook.dart` — no-op replay hook (reserved for cloud path)

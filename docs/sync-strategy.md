# Sync strategy (v5 — cloud SoT)

## Decision: Supabase full CRUD (approved 2026-10)

PowerCoach Studio uses **Supabase `public.coach_entities` as the cloud source of
truth** for coach business entities. Writes are **online-required** (authenticated
session + successful remote write before the UI treats the change as saved).
There is **no offline outbox** in v1.

Drift SQLite (`LocalEntities` via `OfflineLocalStore`) is a **per-user cache**.
After a successful pull, the cache is **fully replaced per entity type**.
SharedPreferences still hold settings, drafts, pins, and PDF brand (not Postgres).

### Rationale

- Multi-device coherence without reintroducing GymBlog.API or a PendingOperations outbox.
- One RLS surface (`user_id = auth.uid()`) on a document/JSONB table aligned with Drift.
- Soft FKs stay inside `payload` JSONB; integrity is enforced in-app + data-quality rules.
- Coaches without network cannot edit — accepted product tradeoff for v1 (decision 1A).

### Entity types

| Type | Notes |
|------|--------|
| `customer` | Coach-owned athletes |
| `workoutPlan` | Plans scoped by `customerId` |
| `measurement` | Body measurements |
| `customExercise` | Library exercises (`scope_id = library`) |
| `customerNote` | Notes threads |

Legacy `exerciseRecord` was removed from Drift (schema v3) and is **not** part of
`coach_entities`.

### User-facing implications

| Area | Behavior |
|------|----------|
| Data storage | Supabase `coach_entities` (SoT) + Drift cache + SharedPreferences prefs |
| Saves | Require session + connectivity; spinner until remote ack |
| Multi-device | Pull on login/resume replaces Drift cache per type |
| Backup | File/cloud JSON remains disaster recovery; restore writes to remote + cache |
| Auth | Supabase JWT scopes all RLS; anon has no table access |
| Sync issues / outbox UI | Not reintroduced |

### Pull / cache

1. On login and app resume: `CoachEntitiesRemote` lists rows for the user (optionally
   filtered by `type` / `updated_at`).
2. For each `OfflineEntityType`, replace Drift rows for that user+type with the
   pulled snapshot (include soft-deleted rows so delete state is coherent).
3. Sign-out: `wipeForUser` clears the Drift cache (existing pattern).

### Migration (existing coaches)

If remote is empty and the device (or backup) has non-deleted entities → **one-shot
upload** (idempotent upsert on PK) with progress UI; mark complete in prefs per user
(`coach_entities_migration_v1_<userId>`). The dashboard gate runs
`CoachEntitiesMigrationService` after sign-in (before empty-local cloud recovery).

### Cloud Storage snapshots

JSON uploads to the private `user-backups` bucket remain available as an extra
safety net (manual + automatic scheduler). They are **not** a substitute for
`coach_entities` live CRUD.

### Security

- RLS policies: SELECT/INSERT/UPDATE/DELETE only when `user_id = auth.uid()`.
- App secrets: `SUPABASE_URL` + `SUPABASE_ANON_KEY` only.
- Never ship `SUPABASE_SERVICE_ROLE` in the client.
- Policy rehearsal: `supabase/tests/coach_entities_rls.sql`.

### Explicit non-goals (v1)

- Offline outbox / conflict merge UI
- Normalized SQL tables per entity
- Moving prefs/PDF brand/pins to Postgres
- Reintroducing GymBlog.API
- Sharing entities across coaches
- Realtime subscriptions (poll/pull on resume only)

### Related code

- `supabase/migrations/*_coach_entities.sql` — table, indexes, RLS
- `lib/core/remote/coach_entities_remote.dart` — list/upsert/soft-delete/pull
- `lib/core/remote/coach_entities_migration_service.dart` — one-shot local→remote upload
- `lib/core/sync/offline_repository_support.dart` — remote-first helper + Drift cache
- `lib/core/storage/offline_local_store.dart` — Drift cache
- `lib/core/backup/user_data_backup_service.dart` — export / restore-to-remote (+ cache pull)
- `lib/core/data_quality/` — soft-FK / orphan scans on pulled or backup JSON

### Data catalog & quality

Entity shapes and soft FKs: [`docs/data-catalog.md`](data-catalog.md).
Run the read-only scanner after pulls when investigating integrity issues:
`dart run tool/data_quality_report.dart <backup.json>`.

-- Optional cloud backup snapshots (Wave B — quasi-cloud, NOT live sync).
--
-- Coaches can manually upload/download the same JSON envelope produced by
-- UserDataBackupService (see lib/core/backup/cloud_backup_repository.dart).
-- There is no automatic upload, merge, or conflict resolution — see
-- docs/sync-strategy.md ("Cloud snapshots != sync").
--
-- Object path convention: {auth.uid()}/backups/{isoTimestamp}.json
-- Soft size limit: keep each JSON snapshot under ~5-10 MB; the app also caps
-- snapshots at 5 per user, pruning the oldest after each upload.

insert into storage.buckets (id, name, public)
values ('user-backups', 'user-backups', false)
on conflict (id) do nothing;

alter table storage.objects enable row level security;

-- Authenticated users may only read/write objects under their own uid folder
-- within the user-backups bucket. No anon access is granted (RLS default-denies
-- any role without a matching policy).
create policy user_backups_select_own
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'user-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy user_backups_insert_own
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'user-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy user_backups_update_own
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'user-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'user-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy user_backups_delete_own
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'user-backups'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

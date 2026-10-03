-- Coach business entities (cloud source of truth — approved supabase_full_crud plan).
-- Document/JSONB model aligned with Drift LocalEntities. Soft-delete via deleted=true.
-- Client uses anon key + user JWT only; never service role from the app.

create table if not exists public.coach_entities (
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null,
  id text not null,
  scope_id text not null default '',
  payload jsonb not null,
  updated_at timestamptz not null default timezone('utc', now()),
  deleted boolean not null default false,
  primary key (user_id, type, id),
  constraint coach_entities_type_check check (
    type in (
      'customer',
      'workoutPlan',
      'measurement',
      'customExercise',
      'customerNote'
    )
  )
);

comment on table public.coach_entities is
  'Cloud SoT for coach business entities (JSONB payloads). Drift is a local cache.';

create index if not exists coach_entities_user_type_idx
  on public.coach_entities (user_id, type);

create index if not exists coach_entities_user_updated_at_idx
  on public.coach_entities (user_id, updated_at desc);

-- Soft FK helper for list-by-customer (customerId in payload JSON).
create index if not exists coach_entities_user_payload_customer_id_idx
  on public.coach_entities (user_id, ((payload->>'customerId')))
  where payload ? 'customerId';

alter table public.coach_entities enable row level security;

-- Authenticated coaches may only touch their own rows (auth.uid() = user_id).
-- No grants for anon. Service role bypasses RLS for admin/ops only — never from the app.

revoke all on public.coach_entities from anon;
grant select, insert, update, delete on public.coach_entities to authenticated;

create policy coach_entities_select_own
  on public.coach_entities
  for select
  to authenticated
  using (user_id = auth.uid());

create policy coach_entities_insert_own
  on public.coach_entities
  for insert
  to authenticated
  with check (user_id = auth.uid());

create policy coach_entities_update_own
  on public.coach_entities
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy coach_entities_delete_own
  on public.coach_entities
  for delete
  to authenticated
  using (user_id = auth.uid());

-- App-access waitlist (invite-only). Distinct from Pro promo coupon_requests.
-- Visitors without an account can request access; admins invite via Dashboard.
-- Client roles have no table grants — inserts go through the request-access Edge Function
-- (service role). Never put the service role in the Flutter app.

create table if not exists public.access_waitlist (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  email_normalized text generated always as (lower(trim(email))) stored,
  name text,
  note text,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  reviewed_at timestamptz,
  reviewed_note text
);

create index if not exists access_waitlist_status_created_idx
  on public.access_waitlist (status, created_at desc);

create unique index if not exists access_waitlist_one_pending_per_email_idx
  on public.access_waitlist (email_normalized)
  where status = 'pending';

alter table public.access_waitlist enable row level security;

-- No SELECT/INSERT/UPDATE/DELETE policies for authenticated or anon.
-- PostgREST clients cannot read or write waitlist rows with the anon key.
revoke all on public.access_waitlist from authenticated, anon;

comment on table public.access_waitlist is
  'Self-serve app-access waitlist (not Pro promo). Admin invites via Dashboard after review.';

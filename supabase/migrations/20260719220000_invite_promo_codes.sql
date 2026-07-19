-- Invite promo codes replace paid checkout during early access.
-- Coaches redeem codes or request access; admins issue codes via SQL/dashboard.

alter table public.billing_entitlements
  add column if not exists entitlement_source text not null default 'none'
    check (entitlement_source in ('none', 'stripe', 'promo', 'manual')),
  add column if not exists promo_code_id uuid;

create table if not exists public.promo_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  code_normalized text generated always as (
    regexp_replace(upper(trim(code)), '\s+', '', 'g')
  ) stored,
  plan text not null default 'pro' check (plan in ('pro')),
  max_redemptions integer,
  redemption_count integer not null default 0,
  expires_at timestamptz,
  note text,
  active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists promo_codes_code_normalized_idx
  on public.promo_codes (code_normalized);

create table if not exists public.promo_redemptions (
  id uuid primary key default gen_random_uuid(),
  promo_code_id uuid not null references public.promo_codes (id) on delete restrict,
  user_id uuid not null references auth.users (id) on delete cascade,
  redeemed_at timestamptz not null default timezone('utc', now()),
  unique (promo_code_id, user_id)
);

create index if not exists promo_redemptions_user_id_idx
  on public.promo_redemptions (user_id);

alter table public.billing_entitlements
  drop constraint if exists billing_entitlements_promo_code_id_fkey;

alter table public.billing_entitlements
  add constraint billing_entitlements_promo_code_id_fkey
  foreign key (promo_code_id) references public.promo_codes (id) on delete set null;

create table if not exists public.coupon_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  email text not null,
  message text,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists coupon_requests_user_id_idx
  on public.coupon_requests (user_id);

create unique index if not exists coupon_requests_one_pending_per_user_idx
  on public.coupon_requests (user_id)
  where status = 'pending';

alter table public.promo_codes enable row level security;
alter table public.promo_redemptions enable row level security;
alter table public.coupon_requests enable row level security;

create policy promo_redemptions_select_own
  on public.promo_redemptions
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy coupon_requests_select_own
  on public.coupon_requests
  for select
  to authenticated
  using (auth.uid() = user_id);

revoke all on public.promo_codes from authenticated, anon;
revoke insert, update, delete on public.promo_redemptions from authenticated, anon;
revoke insert, update, delete on public.coupon_requests from authenticated, anon;

comment on table public.promo_codes is
  'Invite/promo codes granting Pro access without Stripe checkout.';
comment on table public.coupon_requests is
  'Coach requests for a Pro invite code; admin approves offline.';

update public.billing_entitlements
set entitlement_source = 'stripe'
where stripe_customer_id is not null
  and entitlement_source = 'none';

update public.billing_entitlements
set entitlement_source = 'manual'
where plan = 'pro'
  and stripe_customer_id is null
  and promo_code_id is null
  and entitlement_source = 'none';

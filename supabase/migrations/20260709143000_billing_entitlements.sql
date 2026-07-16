-- Billing entitlements (Stripe subscription state per auth user).
-- Business coach data stays local; this table is the only Supabase billing surface.

create table if not exists public.billing_entitlements (
  user_id uuid primary key references auth.users (id) on delete cascade,
  plan text not null default 'free' check (plan in ('free', 'pro')),
  stripe_customer_id text,
  stripe_subscription_id text,
  status text not null default 'none' check (
    status in ('none', 'active', 'trialing', 'past_due', 'canceled')
  ),
  current_period_end timestamptz,
  pro_until timestamptz,
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists billing_entitlements_stripe_customer_id_idx
  on public.billing_entitlements (stripe_customer_id)
  where stripe_customer_id is not null;

create index if not exists billing_entitlements_stripe_subscription_id_idx
  on public.billing_entitlements (stripe_subscription_id)
  where stripe_subscription_id is not null;

alter table public.billing_entitlements enable row level security;

-- Coaches can read their own entitlement row only.
create policy billing_entitlements_select_own
  on public.billing_entitlements
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Writes are service-role only (Stripe webhook Edge Function).
revoke insert, update, delete on public.billing_entitlements from authenticated;
revoke insert, update, delete on public.billing_entitlements from anon;

comment on table public.billing_entitlements is
  'Stripe subscription entitlement per Supabase auth user (web billing).';

-- Billing cycle and price snapshot for subscription UI (populated by Stripe webhook).

alter table public.billing_entitlements
  add column if not exists billing_interval text
    check (billing_interval in ('monthly', 'yearly')),
  add column if not exists price_amount_cents integer,
  add column if not exists currency text not null default 'eur';

comment on column public.billing_entitlements.billing_interval is
  'Stripe subscription billing cadence (monthly/yearly).';
comment on column public.billing_entitlements.price_amount_cents is
  'Stripe price unit_amount in cents at last webhook sync.';

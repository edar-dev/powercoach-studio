# Stripe billing (web launch Phase 2)

PowerCoach Studio web subscriptions use **Stripe Checkout** + **Customer Portal**. Entitlements are stored in Supabase (`billing_entitlements`); coach data stays local (Drift/IndexedDB).

## Product rules (confirmed)

| Tier | Price | Limits |
|------|-------|--------|
| **Free** | €0 forever | Max **5 active customers** |
| **Pro** | €12/month or €99/year | Unlimited customers, CSV export, Hevy, PDF/Excel export |
| **Trial** | None | — |
| **Grace** | 7 days after cancel | `pro_until` keeps Pro gates open |

## Deployed endpoints (gym-blog / `owtkzvphhapjdfibmebl`)

| Function | URL |
|----------|-----|
| get-entitlement | `https://owtkzvphhapjdfibmebl.supabase.co/functions/v1/get-entitlement` |
| create-checkout-session | `https://owtkzvphhapjdfibmebl.supabase.co/functions/v1/create-checkout-session` |
| create-portal-session | `https://owtkzvphhapjdfibmebl.supabase.co/functions/v1/create-portal-session` |
| stripe-webhook | `https://owtkzvphhapjdfibmebl.supabase.co/functions/v1/stripe-webhook` |

Confirm this matches your production `SUPABASE_URL` in Vercel/GitHub secrets before wiring the Flutter client.

## Prerequisites

1. [Stripe account](https://dashboard.stripe.com) (test mode first)
2. Supabase project used for PowerCoach **auth** (same as `SUPABASE_URL` in `.env`)
3. [Supabase CLI](https://supabase.com/docs/guides/cli) installed locally

## Stripe resources (test mode — configured 2026-07-09)

| Resource | ID | Dashboard |
|----------|-----|-----------|
| Product **PowerCoach Studio Pro** | `prod_Ur6bQo6Vqyz1Gt` | [Product](https://dashboard.stripe.com/test/products/prod_Ur6bQo6Vqyz1Gt) |
| Price **Pro Monthly €12** | `price_1TrOOs2Ls7JojLJZijEv3TUK` | lookup: `powercoach_pro_monthly` |
| Price **Pro Yearly €99** | `price_1TrOOr2Ls7JojLJZok7d6j7l` | lookup: `powercoach_pro_yearly` |
| Coupon **Beta Coach 100%** | `1jfkaPgV` | [Coupons](https://dashboard.stripe.com/test/coupons/1jfkaPgV) |

Account: `acct_1TrIHj2Ls7JojLJZ` (test mode).

| Integration | ID |
|-------------|-----|
| Webhook → Supabase | `we_1Ts5Iv2Ls7JojLJZ4h6iroAU` |
| Customer Portal (default) | `bpc_1Ts5Jx2Ls7JojLJZkBb4JZb9` |

## Stripe Dashboard setup

Most catalog items are already created. **Supabase Edge Function secrets** must be set in the [Dashboard → Edge Functions → Secrets](https://supabase.com/dashboard/project/owtkzvphhapjdfibmebl/settings/functions) (the Cursor Supabase MCP token cannot write secrets):

| Secret | Value |
|--------|--------|
| `STRIPE_SECRET_KEY` | `sk_test_...` from [API keys](https://dashboard.stripe.com/acct_1TrIHj2Ls7JojLJZ/apikeys) |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` from [Webhooks → signing secret](https://dashboard.stripe.com/test/webhooks/we_1Ts5Iv2Ls7JojLJZ4h6iroAU) |
| `STRIPE_PRICE_ID_MONTHLY` | `price_1TrOOs2Ls7JojLJZijEv3TUK` — no trailing `.` or spaces |
| `STRIPE_PRICE_ID_YEARLY` | `price_1TrOOr2Ls7JojLJZok7d6j7l` — no trailing `.` or spaces |

Re-run for a new Stripe account or live mode:

```bash
STRIPE_SECRET_KEY=sk_test_... bash scripts/configure-stripe-billing.sh
```

Or manually (if webhook/portal already exist):

1. **Product / prices** — use IDs above (`STRIPE_PRICE_ID_MONTHLY` / `YEARLY`).
2. **Customer Portal** — [Billing → Customer portal](https://dashboard.stripe.com/test/settings/billing/portal): enable cancel (at period end), payment method update, invoice history.
3. **Webhook** (test, then repeat for live):
   - URL: `https://owtkzvphhapjdfibmebl.supabase.co/functions/v1/stripe-webhook`
   - Events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, `invoice.payment_failed`
   - Signing secret → `STRIPE_WEBHOOK_SECRET`

## Supabase setup

### 1. Link project

```bash
supabase login
supabase link --project-ref <your-project-ref>
```

Update `supabase/config.toml` `project_id`.

### 2. Apply migration

```bash
supabase db push
# or: supabase migration up
```

Creates `public.billing_entitlements` with RLS (authenticated read own row; writes service-role only).

### 3. Edge Function secrets

Set in Supabase Dashboard → Project Settings → Edge Functions → Secrets:

| Secret | Source |
|--------|--------|
| `STRIPE_SECRET_KEY` | Stripe → Developers → API keys |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret |
| `STRIPE_PRICE_ID_MONTHLY` | Stripe price ID |
| `STRIPE_PRICE_ID_YEARLY` | Stripe price ID |

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically for Edge Functions.

### 4. Deploy functions

```bash
supabase functions deploy get-entitlement
supabase functions deploy create-checkout-session
supabase functions deploy create-portal-session
supabase functions deploy stripe-webhook --no-verify-jwt
```

## Local webhook testing

```bash
stripe listen --forward-to http://127.0.0.1:54321/functions/v1/stripe-webhook
supabase functions serve stripe-webhook --no-verify-jwt
```

Use the `whsec_...` from `stripe listen` as local `STRIPE_WEBHOOK_SECRET`.

## API reference (Edge Functions)

All authenticated endpoints require header: `Authorization: Bearer <supabase_access_token>`.

### `GET|POST /functions/v1/get-entitlement`

Returns effective plan for gating:

```json
{
  "plan": "free",
  "subscriptionPlan": "free",
  "status": "none",
  "currentPeriodEnd": null,
  "proUntil": null,
  "billingInterval": null,
  "priceAmountCents": null,
  "currency": "eur"
}
```

`plan` includes grace period logic; use it for paywall gates.

### `POST /functions/v1/create-checkout-session`

Body:

```json
{
  "billingInterval": "monthly",
  "successUrl": "https://powercoach-studio.vercel.app/settings/subscription?checkout=success",
  "cancelUrl": "https://powercoach-studio.vercel.app/settings/subscription?checkout=cancel"
}
```

Response: `{ "url": "https://checkout.stripe.com/..." }`

Promotion codes are enabled on Checkout (`allow_promotion_codes: true`). Users can enter beta or campaign coupons on the Stripe page.

### `POST /functions/v1/create-portal-session`

Body:

```json
{
  "returnUrl": "https://powercoach-studio.vercel.app/settings/subscription",
  "flow": "payment_method"
}
```

Optional `flow`: `payment_method`, `subscription_update`, `subscription_cancel` (opens Stripe Customer Portal on the matching screen). Omit for the default portal home (invoices, etc.).

Response: `{ "url": "https://billing.stripe.com/..." }`

### `POST /functions/v1/stripe-webhook`

Stripe-signed only. No JWT.

## Flutter client (Phase 2.2+)

Not in this PR. Follow `.cursor/plans/web-launch-phase2-billing.plan.md` for:

- `EntitlementRepository` → calls `get-entitlement`
- `PlanGate` → max 5 customers on Free
- `subscription_screen.dart` → Checkout / Portal buttons

## Manual QA checklist

- [ ] New user → `get-entitlement` returns `plan: free`
- [ ] Checkout with test card `4242 4242 4242 4242` → `plan: pro`
- [ ] Cancel in Customer Portal → still `plan: pro` for 7 days (`proUntil` set)
- [ ] After grace → `plan: free`
- [ ] Webhook retries idempotent (no duplicate errors)

## Beta coaches

Grant Pro without payment:

```sql
insert into public.billing_entitlements (user_id, plan, status)
values ('<auth-user-uuid>', 'pro', 'active')
on conflict (user_id) do update
  set plan = 'pro', status = 'active', pro_until = null, updated_at = now();
```

Or issue coupon **`Beta Coach 100%`** (`1jfkaPgV`) at checkout for early adopters.

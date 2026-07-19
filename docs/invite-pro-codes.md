# Pro access via invite codes

During early access, **Pro is not sold via Stripe checkout**. Coaches stay on Free or unlock Pro with an **invite code**, or by **requesting a code** from the team.

Free vs Pro limits are unchanged (see `docs/stripe-billing.md`).

## User flows

1. **Redeem code** — Settings → Subscription → enter code → `redeem-promo-code` Edge Function.
2. **Request access** — same screen → “Request invite code” → `request-coupon` Edge Function. One pending request per user; you approve offline and send a code by email.

Stripe checkout buttons were removed from the app. Existing Stripe subscribers still see the Customer Portal (`entitlement_source = stripe`).

## Edge Functions

| Function | Body | Result |
|----------|------|--------|
| `redeem-promo-code` | `{ "code": "POWERCOACH-2026" }` | Upserts `billing_entitlements` with `plan=pro`, `status=active`, `entitlement_source=promo` |
| `request-coupon` | `{ "message": "optional" }` | Inserts `coupon_requests` row (`pending`) |
| `get-entitlement` | — | Adds `entitlementSource`, `hasPendingCouponRequest` |

## Database

- `promo_codes` — codes (normalized automatically), optional `max_redemptions`, `expires_at`
- `promo_redemptions` — audit per user/code
- `coupon_requests` — pending/approved/rejected requests
- `billing_entitlements.entitlement_source` — `none` | `stripe` | `promo` | `manual`

## Admin: create a code

```sql
insert into public.promo_codes (code, max_redemptions, note)
values ('POWERCOACH-BETA', 50, 'Early access batch 1');
```

Share the `code` value as-is (spaces/case are normalized on redeem).

## Admin: handle requests

List pending:

```sql
select id, email, message, created_at
from public.coupon_requests
where status = 'pending'
order by created_at;
```

After sending a personal code by email:

```sql
update public.coupon_requests
set status = 'approved', updated_at = now()
where id = '<request-uuid>';
```

Or reject:

```sql
update public.coupon_requests
set status = 'rejected', updated_at = now()
where id = '<request-uuid>';
```

## Deploy

After merging, deploy Edge Functions:

- `get-entitlement`
- `redeem-promo-code`
- `request-coupon`

Migration: `supabase/migrations/20260719220000_invite_promo_codes.sql`

# App-access waitlist (invite-only)

Self-serve **waitlist** for coaches who want access while public signups stay **disabled**.  
This is **not** Pro promo / coupon codes (`docs/invite-pro-codes.md` / `coupon_requests`).

## Product rules

| Concern | Rule |
|---------|------|
| Public signup | Stay **OFF** (Authentication → Providers → Email → Enable sign ups) |
| Visitor | Submits email (+ optional name/note) on `/register` |
| Storage | `public.access_waitlist` via Edge Function `request-access` |
| Approval | Admin reviews pending rows → Dashboard **Invite user** |
| Flutter | Anon key + JWT only — **no service role in the app** |

## User flow

1. Landing / login → “How to get access” → `/register`
2. Fill waitlist form → `request-access` inserts `pending`
3. Admin lists pending (SQL below) → Invite user in Dashboard
4. Mark row `approved` after sending the invite
5. Coach sets password from invite email → `/login`

## Edge Function

| Function | JWT | Body | Result |
|----------|-----|------|--------|
| `request-access` | **false** (public form) | `{ "email", "name?", "note?" }` | `{ ok, alreadyPending }` |

- Validates email; truncates name (120) / note (500)
- One **pending** row per normalized email
- Soft rate limit: same email within 60s → HTTP 429
- Writes with **service role** inside the function only

## Database

Migration: `supabase/migrations/20261012120000_access_waitlist.sql`

- RLS enabled; **no** grants/policies for `anon` / `authenticated`
- Columns: `email`, `email_normalized`, `name`, `note`, `status` (`pending` \| `approved` \| `rejected`), timestamps

## Admin ops (Edoardo)

### 1. Keep public signups off

1. [Supabase Dashboard](https://supabase.com/dashboard) → project **PowerCoach Studio**
2. **Authentication** → **Providers** → **Email**
3. **Enable sign ups** = **OFF** → Save

### 2. List pending waitlist requests

```sql
select id, email, name, note, created_at
from public.access_waitlist
where status = 'pending'
order by created_at;
```

### 3. Invite the coach

1. **Authentication** → **Users** → **Invite user**
2. Enter the waitlist email → send invite
3. Coach opens email → sets password → signs in at `/login`

### 4. Mark the request approved (or rejected)

```sql
update public.access_waitlist
set
  status = 'approved',
  updated_at = now(),
  reviewed_at = now(),
  reviewed_note = 'Invited via Dashboard'
where id = '<request-uuid>';
```

Reject:

```sql
update public.access_waitlist
set
  status = 'rejected',
  updated_at = now(),
  reviewed_at = now(),
  reviewed_note = 'optional reason'
where id = '<request-uuid>';
```

### 5. Deploy (after merge)

```bash
# Apply migration (CLI or Dashboard SQL)
supabase db push   # or run the migration file in SQL editor

supabase functions deploy request-access
```

Ensure secrets `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are available to Edge Functions (standard for this project).

## Why not in-app admin?

There is no admin identity / RBAC in the Flutter app today (same as Pro `coupon_requests`). SQL + Dashboard Invite matches existing ops and avoids shipping a service-role or open admin surface.

## Optional later: Edge invite on approve

`auth.admin.inviteUserByEmail` can run in a **server-only** Edge Function with service role after an admin secret or Dashboard action. Not required for v1 — Dashboard Invite is enough.

## Distinguishing from Pro

| | App waitlist | Pro promo |
|--|--------------|-----------|
| Table | `access_waitlist` | `coupon_requests` / `promo_codes` |
| Who | Anonymous visitor | Logged-in Free coach |
| Outcome | Auth invite → account | Pro entitlement |
| Docs | this file | `docs/invite-pro-codes.md` |

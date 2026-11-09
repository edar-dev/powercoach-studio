# PostHog funnel dashboards (EU UI checklist)

Manual setup for the four coach web funnels defined in [`posthog-product-events.md`](posthog-product-events.md).

**Project:** [eu.posthog.com](https://eu.posthog.com) (EU cloud).  
**Ingest:** `https://eu.i.posthog.com` locally; production Vercel web uses first-party proxy `/pcs-ph` (see README + `docs/vercel-web-deploy.md`).

These funnels are built from **product events** (+ `$pageview`). Do **not** rely on CanvasKit session replay or heatmaps for drop-off measurement.

## Dashboard

Suggested dashboard name: **Coach web funnels**

Pin the four funnel insights below to that dashboard after creating them.

## Shared funnel settings

For each funnel insight:

1. **Product analytics → Insights → New insight → Funnel**
2. **Conversion window:** 7–14 days (start with 14d if traffic is sparse)
3. **Aggregation:** Unique users
4. **Host filter (prod):** filter `$host` / hostname to the production web host (exclude localhost / preview hosts when comparing live conversion)
5. Steps that allow create **or** save: use PostHog **OR** matching on the same step (`workout_plan_created` OR `workout_plan_saved`)

## F1 — Web acquisition

| Step | Event / filter |
|------|----------------|
| 1 | `landing_cta_clicked` |
| 2 | `login_completed` |
| 3 | `$pageview` where sanitized path = `/dashboard` |

**How:**

1. New funnel → add step `landing_cta_clicked`
2. Add step `login_completed`
3. Add step `$pageview` and filter the event property **`path`** (app emits `path`, not `$pathname`) to `/dashboard`
4. Save as e.g. `F1 Web acquisition` → pin to **Coach web funnels**

**Side insight (not a funnel step):** create a separate insight for `waitlist_submitted` (optionally break down by `already_pending`). Do not insert it between CTA and login.

## F2 — Coach activation

| Step | Event / filter |
|------|----------------|
| 1 | `login_completed` |
| 2 | `customer_created` |
| 3 | `workout_plan_created` **OR** `workout_plan_saved` |
| 4 | `pdf_exported` |
| 5 | `subscription_checkout_started` (optional step 6: `subscribed`) |

**How:**

1. New funnel → steps in order above
2. On step 3, configure OR matching so either create or save counts
3. Optionally add `subscribed` after checkout started
4. Save as e.g. `F2 Coach activation` → pin to dashboard

## F3 — Add exercise to plan

| Step | Event / filter |
|------|----------------|
| 1 | `$pageview` path `/workouts/builder` |
| 2 | `exercise_added_to_day` |
| 3 | `workout_plan_created` **OR** `workout_plan_saved` |

**How:**

1. New funnel → `$pageview` filtered by property **`path`** = `/workouts/builder`
2. Add `exercise_added_to_day` (optional breakdown by `via`: `add` / `duplicate`)
3. Add OR step for plan create/save
4. Save as e.g. `F3 Add exercise to plan` → pin to dashboard

## F4 — Assign plan

| Step | Event / filter |
|------|----------------|
| 1 | `customer_created` |
| 2 | `plan_assigned` |
| 3 | `pdf_exported` (optional) |

**Semantics:** `plan_assigned` fires on every successful plan **create** for a real customer (new plan, assign draft, follow-up clone) — not only the first assignment per athlete.

**How:**

1. New funnel → `customer_created` → `plan_assigned`
2. Optionally add `pdf_exported`
3. Save as e.g. `F4 Assign plan` → pin to dashboard

**F1 note:** Logged-in visitors who click landing CTAs may never emit a fresh `login_completed` in the conversion window. Prefer filtering F1 to anonymous→auth traffic, or accept that step 2 is the gate for logged-out users only.

## Live events verification checklist

After a consented web session on an environment with `POSTHOG_API_KEY` set:

- [ ] Landing conversion CTA → Live events shows `landing_cta_clicked` with expected `cta` token
- [ ] Waitlist submit → `waitlist_submitted` with `already_pending`
- [ ] Login → `login_completed`; navigate to dashboard → `$pageview` `/dashboard`
- [ ] Create customer → `customer_created`
- [ ] Open builder → `$pageview` `/workouts/builder`; add/duplicate exercise → `exercise_added_to_day` (`via`)
- [ ] Create plan for a customer → `workout_plan_created` **and** `plan_assigned`
- [ ] Save existing plan → `workout_plan_saved`
- [ ] Create custom exercise via library UI (not first-open seed) → one `custom_exercise_created` with `catalog_source: manual`
- [ ] Export PDF / start checkout → existing `pdf_exported` / `subscription_checkout_started` still fire
- [ ] No names, emails, or entity ids in event properties

## Manual UI required

No personal PostHog API key is available in-repo to automate insight creation. A human must click in PostHog EU:

1. Create **4 funnel insights** (F1–F4) with the settings above
2. Create dashboard **Coach web funnels** (if missing)
3. **Pin** the four funnel insights to that dashboard
4. Optionally add a `waitlist_submitted` trend/breakdown as a side card (not a F1 step)

Event catalog + property semantics: [`posthog-product-events.md`](posthog-product-events.md).

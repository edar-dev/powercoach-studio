# PostHog product events (Flutter web)

High-signal events via `ProductAnalytics` (`lib/core/analytics/product_analytics.dart`).
Web + consent + `POSTHOG_API_KEY` only. **No PII** in properties (no names, emails, plan/customer ids).

Session replay stays masked; CanvasKit limits visual fidelity — use **event funnels** for coach drop-off, **not** CanvasKit session replay or heatmaps. See also [`posthog-funnel-dashboards.md`](posthog-funnel-dashboards.md) for PostHog EU UI setup.

## Event catalog

| Event | When | Props (non-PII) |
|-------|------|-----------------|
| `landing_cta_clicked` | Conversion CTA on landing (not section-scroll nav) | `cta` (`hero_primary` \| `hero_secondary` \| `how_primary` \| `pricing_free` \| `pricing_pro` \| `bottom_cta` \| `nav_login` \| `nav_start_free` \| `start_free`) |
| `waitlist_submitted` | Waitlist request succeeds (`/register`) | `already_pending` (bool) |
| `login_completed` | Password sign-in success | — |
| `signup_completed` | Defined; invite-only may not fire | — |
| `customer_created` | After remote customer create | — |
| `exercise_added_to_day` | Exercise added/duplicated in builder day | `via` (`add` \| `duplicate`) |
| `workout_plan_created` | First cloud create of a workout plan | — |
| `workout_plan_saved` | Later update of an existing plan | — |
| `plan_assigned` | Plan **created** for a real customer (non-empty `customerId`, not template scope). Fires with `workout_plan_created` on first create / assign-draft / follow-up clone — not a separate “first assignment only” signal | — |
| `custom_exercise_created` | **User-initiated** custom exercise create (library UI, builder pick-panel, mobility “save to library”). Not fired on catalog seed or JSON import | `catalog_source` (`manual`) |
| `pdf_exported` | PDF export succeeds | `source` (`workout_plan` \| `measurements`) |
| `subscription_checkout_started` | Stripe Checkout opened | `billing_interval` |
| `subscribed` | Return from Stripe with `?checkout=success` | `source` (default `stripe_checkout`) |
| `first_save_failed` | Editor first cloud create fails | `silent` (bool), `reason` (`offline` \| `not_authenticated` \| `remote` \| `network` \| `unknown`) |
| `offline_save_blocked` | Remote write blocked (offline / no session) | `reason` (`offline` \| `not_authenticated`) |
| `session_logged` | Session marked completed | `source` (`dashboard_today` \| `schedule_detail` \| `workout_builder` \| `calendar` \| `customer_plan` \| `unknown`), `has_exercise_data` (bool) |
| `$pageview` | Router navigation (not via `ProductAnalytics`) | Sanitized path (`:id` redaction) |

## Funnel definitions

Build these as **Unique users** funnels in PostHog EU. Prefer a **7–14 day** conversion window. Filter to production host when comparing live traffic. **Do not** use CanvasKit session replay or heatmaps as the source of truth for these funnels.

### F1 — Web acquisition

1. `landing_cta_clicked`
2. `login_completed`
3. `$pageview` with path `/dashboard` (already emitted by the router; filter `$pathname` / sanitized path)

**Side insight (not a funnel step after login):** `waitlist_submitted` measures invite-waitlist conversion from `/register`. Treat it as a parallel acquisition insight, not as a step between landing CTA and login.

### F2 — Coach activation (core)

1. `login_completed`
2. `customer_created`
3. `workout_plan_created` **OR** `workout_plan_saved` (OR-match in PostHog)
4. `pdf_exported`
5. `subscription_checkout_started` (optional last step: `subscribed`)

### F3 — Add exercise to plan

1. `$pageview` with path `/workouts/builder`
2. `exercise_added_to_day`
3. `workout_plan_created` **OR** `workout_plan_saved`

### F4 — Assign plan

1. `customer_created`
2. `plan_assigned` (any successful plan create for a real customer — see catalog note)
3. `pdf_exported` (optional)

## Drop-off / engagement (secondary insights)

| Event | When | Notes |
|-------|------|--------|
| `first_save_failed` | Editor first cloud create fails | Paired with `offline_save_blocked` on offline first-create |
| `offline_save_blocked` | Remote write blocked | Also fires for customers, measurements, deletes — not builder-only |
| `session_logged` | Session marked completed | Engagement, not a funnel gate |

**Correlation:** An offline first-create failure emits **both** `offline_save_blocked` (repository gate) and `first_save_failed` (editor). Treat them as paired, not as independent funnel steps.

## API

```dart
ProductAnalytics.capture('event_name', {'key': 'value'});
ProductAnalytics.landingCtaClicked(cta: 'hero_primary');
ProductAnalytics.waitlistSubmitted(alreadyPending: false);
ProductAnalytics.exerciseAddedToDay(via: 'add');
ProductAnalytics.planAssigned();
ProductAnalytics.customExerciseCreated(catalogSource: 'manual');
ProductAnalytics.firstSaveFailed(silent: false, reason: 'offline');
```

No-op off-web, when disabled, or before consent.

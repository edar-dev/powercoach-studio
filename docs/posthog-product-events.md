# PostHog product events (Flutter web)

High-signal events via `ProductAnalytics` (`lib/core/analytics/product_analytics.dart`).
Web + consent + `POSTHOG_API_KEY` only. **No PII** in properties (no names, emails, plan/customer ids).

Session replay stays masked; CanvasKit limits visual fidelity — use **event funnels** for coach drop-off, not replay.

## Coach activation funnel

| Step | Event(s) | Notes |
|------|----------|--------|
| 1. Login | `login_completed` | Password sign-in success |
| 2. Customer | `customer_created` | After remote create |
| 3. Plan saved | `workout_plan_created` **or** `workout_plan_saved` | First create vs later update |
| 4. PDF | `pdf_exported` | Prop `source`: `workout_plan` \| `measurements` |
| 5. Checkout | `subscription_checkout_started` → `subscribed` | Stripe start + `?checkout=success` |

## Drop-off / engagement (gap events)

| Event | When | Props (non-PII) |
|-------|------|-----------------|
| `first_save_failed` | Editor first cloud create fails | `silent` (bool), `reason` (`offline` \| `not_authenticated` \| `remote` \| `network` \| `unknown`) |
| `offline_save_blocked` | Remote write blocked (offline / no session) | `reason` (`offline` \| `not_authenticated`) |
| `session_logged` | Session marked completed | `source` (`dashboard_today` \| `schedule_detail` \| `workout_builder` \| `calendar` \| `customer_plan` \| `unknown`), `has_exercise_data` (bool) |

**Correlation:** An offline first-create failure emits **both** `offline_save_blocked` (repository gate) and `first_save_failed` (editor). Treat them as paired, not as independent funnel steps. `offline_save_blocked` also fires for any blocked remote write (customers, measurements, deletes), not only the builder.

## Other events

| Event | Props |
|-------|--------|
| `signup_completed` | — (defined; invite-only may not fire) |
| `$pageview` | Sanitized path (`:id` redaction); not via `ProductAnalytics` |

## API

```dart
ProductAnalytics.capture('event_name', {'key': 'value'});
ProductAnalytics.firstSaveFailed(silent: false, reason: 'offline');
```

No-op off-web, when disabled, or before consent.

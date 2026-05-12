# Local notifications & reminders (Feature 02)

PowerCoach Studio uses [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) with [`timezone`](https://pub.dev/packages/timezone) for **UTC-based** `zonedSchedule` (inexact alarms on Android to avoid sensitive `SCHEDULE_EXACT_ALARM` requirements where possible).

## Supported platforms

| Platform | Behaviour |
|----------|-----------|
| **Android** | `POST_NOTIFICATIONS` (API 33+), reminder channel `powercoach_reminders`, `AndroidScheduleMode.inexactAllowWhileIdle`. |
| **iOS** | Runtime permission for alert/badge/sound. |
| **macOS** | Same plugin path as iOS where supported. |
| **Web** | **Not supported** — the Settings toggle is disabled; creating reminders from the customer sheet shows a localized message. |
| **Windows** | Plugin support is limited; scheduling is gated the same way as unsupported targets. |

## User flows

1. **Settings → Notifications**  
   When turning **on**, the OS permission dialog runs. If the user denies, the switch stays off and a snackbar explains next steps. When turning **off**, pending OS notifications for this app are cancelled (see `NotificationSchedulerService.cancelAllScheduled`).

2. **Customer detail → ⋮ → Set reminder**  
   Pick date and time; a `Reminder` is stored in `SharedPreferences` and scheduled if notifications are enabled.

3. **Tap notification**  
   Payload is a GoRouter path (e.g. `/customers/{id}`). Navigation uses `appRootNavigatorKey` + `GoRouter.go`.

4. **Sign out**  
   Cancels all scheduled local notifications and clears the reminder list from the device (privacy on shared devices).

## Backup / restore

User backup JSON (v1) includes an optional top-level **`reminders`** array (additive). Import restores reminders then calls `syncWithNotificationPreference()`.

## Manual QA checklist

- [ ] **Android**: enable toggle → grant permission → create reminder 2 min ahead → notification fires → tap opens customer.
- [ ] **Android**: deny permission → toggle stays off, message shown.
- [ ] **iOS**: same happy path as Android.
- [ ] **Web**: toggle disabled; customer reminder action shows “not supported on web”.
- [ ] **Logout**: pending reminders cleared; no stale notifications after re-login with another account (same device).

## Tests

- `test/core/notifications/reminder_test.dart` — stable id + JSON.
- `test/core/backup/user_data_backup_codec_test.dart` — optional `reminders` in envelope.

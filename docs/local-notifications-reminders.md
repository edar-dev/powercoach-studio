# Local notifications & calendar reminders

PowerCoach Studio uses [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) with [`timezone`](https://pub.dev/packages/timezone) for **UTC-based** `zonedSchedule` (inexact alarms on Android to avoid sensitive `SCHEDULE_EXACT_ALARM` requirements where possible).

## Supported platforms

| Platform | Behaviour |
|----------|-----------|
| **Android** | `POST_NOTIFICATIONS` (API 33+), reminder channel `powercoach_reminders`, `AndroidScheduleMode.inexactAllowWhileIdle`. |
| **iOS** | Runtime permission for alert/badge/sound. |
| **macOS** | Same plugin path as iOS where supported. |
| **Web** | **Not supported** — calendar reminder toggles in Settings are disabled with a localized message. |
| **Windows** | Plugin support is limited; scheduling is gated the same way as unsupported targets. |

## User flows

1. **Settings → Calendar reminders**  
   When enabling, the OS permission dialog runs. Lead-time hours control how far ahead of a planned session the notification fires. When turning **off**, pending OS notifications for this app are cancelled (see `NotificationSchedulerService.cancelAllScheduled`).

2. **Plan calendar events**  
   Reminders are derived from scheduled plan sessions (calendar path). There is **no** manual per-client ReminderStore / “Set reminder” sheet anymore.

3. **Tap notification**  
   Payload is a GoRouter path (e.g. `/customers/{id}` or schedule detail). Navigation uses `appRootNavigatorKey` + `GoRouter.go`.

4. **Sign out**  
   Cancels all scheduled local notifications (privacy on shared devices).

## Backup / restore

User backup JSON may still include a legacy top-level **`reminders`** array; import **ignores** those rows. Calendar reminder **preferences** (enabled + lead hours) are restored via `preferences`.

## Manual QA checklist

- [ ] **Android**: enable calendar reminders → grant permission → schedule a session soon → notification fires → tap opens the right screen.
- [ ] **Android**: deny permission → toggle stays off / message shown.
- [ ] **iOS**: same happy path as Android.
- [ ] **Web**: calendar reminder UI shows “not supported on web”.
- [ ] **Logout**: pending notifications cleared.

## Tests

- `test/core/notifications/calendar_reminder_scheduler_test.dart` — calendar scheduling.
- `test/core/backup/user_data_backup_codec_test.dart` — prefs + legacy `reminders` tolerance.

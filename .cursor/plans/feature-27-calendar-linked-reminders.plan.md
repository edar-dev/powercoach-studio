---
name: feature-27-calendar-linked-reminders
overview: "Feature #4 v4 — Promemoria automatici da sessioni calendario: schedule notifica N ore prima della sessione pianificata, integrato con NotificationSchedulerService."
todos:
  - id: reminder-prefs
    content: SettingsPrefsKeys — calendarRemindersEnabled, reminderLeadHours (default 24), reminderDefaultHour se sessione senza orario
    status: pending
  - id: session-reminder-model
    content: SessionReminderDescriptor — planId, customerId, sessionKey, fireAt, notificationId; persistenza in prefs o Drift reminders table esistente
    status: pending
  - id: scheduler-bridge
    content: CalendarReminderScheduler — calcola prossime sessioni da CalendarEventLoader, schedule/cancel via NotificationSchedulerService
    status: pending
  - id: lifecycle-hooks
    content: Reschedule su plan save, session override, archive plan, app resume — invalidate e ricalcola
    status: pending
  - id: settings-ui
    content: Sezione in settings — toggle promemoria calendario + lead time picker
    status: pending
  - id: per-customer-opt-out
    content: Opzionale flag su Customer o reminder skip per cliente
    status: pending
  - id: web-fallback
    content: Messaggio reminderWebNotSupported se piattaforma non supportata (già in l10n)
    status: pending
  - id: tests
    content: Unit test calcolo fireAt con override date; mock NotificationSchedulerService
    status: pending
isProject: false
---

# Feature 27 — Reminder da calendario

## Obiettivo prodotto

Feature-02 permette promemoria **manuali** per cliente.  
Il passo naturale è notificare il coach **prima delle sessioni già in calendario**, senza creare reminder uno a uno.

## Stato attuale

| Area | File |
|------|------|
| Notifiche | [`notification_scheduler_service.dart`](lib/core/notifications/notification_scheduler_service.dart) |
| Reminder manuali | [`customer_reminder_sheet.dart`](lib/features/customers/presentation/widgets/customer_reminder_sheet.dart) |
| Calendario | [`calendar_event_loader.dart`](lib/features/dashboard/domain/calendar_event_loader.dart) |
| Toggle notifiche | `settings_screen.dart` |

## Design — Flusso

1. Coach abilita "Promemoria sessioni" in Settings
2. All'enable / ogni notte / on app resume:
   - `CalendarEventLoader` → eventi prossimi 7 giorni
   - Per ogni evento `planned`: `fireAt = sessionDate - leadHours`
   - Schedule notifica locale con titolo `"Marco Rossi — Giorno A"`

3. Su override skip/move: cancel + reschedule
4. Su plan archived: cancel tutti i reminder del planId

## Design — Orario sessione

I piani non hanno ora esplicita. MVP:
- Usare `reminderDefaultHour` (es. 09:00 locale) sul giorno sessione
- Lead time: notifica il giorno prima alle 20:00 se `leadHours=24`

Documentare limite in UI.

## Dipendenze

- Feature-02 — notifiche locali (**completata**)
- Feature-20 — override date per fireAt corretto

## Test

- `test/core/notifications/calendar_reminder_scheduler_test.dart`

## Rischi

- **Limite notifiche OS** — cap a 7 giorni lookahead; documentare
- **Web** — notifiche non supportate; gate già esistente
- **Battery** — reschedule on resume, non polling continuo

## Definition of done

- Toggle settings funziona
- Almeno 1 notifica schedulabile da sessione reale (test manuale Android/iOS)
- Cancel su archive plan
- ≥3 unit test calcolo date
- Analyze verde

## Branch suggerito

`feat/calendar-linked-reminders`

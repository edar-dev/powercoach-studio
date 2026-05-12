---
name: feature-06-plan-calendar-assignment
overview: Modellare date di assegnazione e avanzamento piano (settimane/giorni), vista calendario coach e stato sessione, integrando WorkoutPlan payload e navigazione esistente dashboard/schedule.
todos:
  - id: data-model-start-end-progress
    content: Definire in plan JSON o campi piano startDate endDate currentWeek assignedSessions; migrazione lettura backward compatible per piani vecchi
    status: pending
  - id: repository-update-apis
    content: Estendere WorkoutPlanRepository con updateScheduleMarkers setSessionCompleted; validazioni date
    status: pending
  - id: calendar-ui-package
    content: Aggiungere table_calendar o custom scroll month; tema Stitch
    status: pending
  - id: coach-calendar-screen
    content: Nuova schermata /dashboard/calendar con eventi aggregati da tutti i clienti (color by client)
    status: pending
  - id: customer-context-strip
    content: In customer workouts o plan editor mostrare strip prossime date e stato completamento
    status: pending
  - id: sync-offline-entities
    content: Garantire che modifiche stato sessione passino da OfflineRepositorySupport come altre entità workoutPlan
    status: pending
  - id: l10n-router
    content: Route protetta drawer link; stringhe IT/EN
    status: pending
  - id: tests-model
    content: Unit test su calcolo occorrenze settimanali da planData routine
    status: pending
isProject: false
---

# Feature 06 — Assegnazione piani con date e calendario

## Obiettivo prodotto

- Ogni piano ha una **timeline** chiara: data inizio, durata (settimane), eventuali **sessioni** calendarizzate.
- Il coach ha una **vista calendario** (mensile/settimanale) con sessioni dei clienti sovrapposte.
- Stati sessione: **pianificata / completata / saltata** (MVP può limitarsi a completata boolean).

## Stato attuale

- [`CoachDashboardScreen`](lib/features/dashboard/presentation/screens/coach_dashboard_screen.dart) calcola “oggi” da `WorkoutPlanApiModel` + `planDataToRoutine` (`_planStartDate`).
- [`ScheduleScreen`](lib/features/dashboard/presentation/screens/schedule_screen.dart) / detail: probabilmente placeholder o query string — allineare durante implementazione.
- Piani in [`WorkoutPlanRepository`](lib/features/workouts/data/workout_plan_repository.dart) con `planData` JSON strutturato ([`workout_routine_model.dart`](lib/features/workouts/data/workout_routine_model.dart)).

## Modello dati — livelli

### Livello 1 (MVP veloce)

- Usare **solo** `startDate` esistente nel payload piano + inferenza “giorni di allenamento” da routine (se modello lo consente).
- Aggiungere mappa opzionale `sessionCompletionByKey` nel payload piano (es. `weekIndex-dayIndex` → bool) senza migrazione DB schema Drift.

### Livello 2 (più ricco)

- Entità separata `OfflineEntityType` nuovo tipo `scheduledSession` con `scopeId = customerId` o `planId` — più query flessibili ma più codice.

**Raccomandazione**: iniziare da **Livello 1** nel JSON `planData` o root payload piano già serializzato in `WorkoutPlanApiModel`; documentare in `.cursor/rules` o README feature.

## Vista calendario

- Dipendenza suggerita: **`table_calendar`** (leggero) o costruzione **custom** con `PageView` se si vuole zero deps.
- **Eventi**: lista `CalendarEvent { DateTime day, String customerId, String planId, String label, SessionStatus status }`.
- **Caricamento**: `getAll()` piani + clienti per nomi; filtrare per intervallo visibile del mese corrente ±1 per prefetch.
- **Tap evento**: navigazione a `/customers/:id/workouts` o editor con `planId`.

## Aggiornamento stato sessione

- UI: checkbox o long-press su evento → `toggleSessionCompleted`.
- Persistenza: `getById` → merge nel `planData` / payload → `WorkoutPlanRepository.update(...)` (metodo esistente o nuovo).

## Integrazione dashboard

- Riutilizzare stessa sorgente eventi del calendario per sezione “Oggi” così non si duplica logica (estrarre `CalendarEventLoader` condiviso con Feature 03).

## Router

- Aggiungere in [`lib/app.dart`](lib/app.dart) sotto `/dashboard` route `calendar` se non presente:
  - Es. `path: 'calendar', builder: (_) => CoachCalendarScreen()`.
- Link da drawer in [`coach_dashboard_screen.dart`](lib/features/dashboard/presentation/screens/coach_dashboard_screen.dart) `_DashboardDrawer`.

## i18n

- Nomi mesi: usare `intl` con locale app.
- Stringhe: `calendarTitle`, `sessionCompleted`, `sessionSkipped`, `calendarEmptyMonth`.

## Test

- Parser: da `planData` finto → lista di `DateTime` attesi per una settimana tipo.
- Repository: update non perde altri campi payload (merge sicuro).

## Rischi

- **Complessità `planData`**: varianti builder (mobility, multiset) possono avere strutture diverse — definire quali varianti supportano il calendario in v1.
- **Performance** aggregando tutti i piani su anno intero — limitare range.

## Definition of done

- Calendario mensile navigabile con almeno eventi derivati da data inizio + regola semplice.
- Marcatura completata persistita e visibile dopo riavvio app.
- Analyze ok; documentazione limiti varianti in commento codice.

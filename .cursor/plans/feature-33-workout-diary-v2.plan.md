---
name: feature-33-workout-diary-v2
overview: "Feature #2 v5 — Diario workout v2: dettaglio navigabile, filtri data/stato, deep link a piano e sessione."
todos:
  - id: diary-detail-screen
    content: "WorkoutDiaryEntryScreen — route /workouts/diary/:executionKey; sostituisce bottom sheet inline"
    status: pending
  - id: date-range-filter
    content: "Filtro intervallo date (7/30/custom) + chip stato completed/skipped/all"
    status: pending
  - id: deep-links
    content: "CTA Apri piano → customer workout editor; Apri sessione → schedule detail con query planId/week/day"
    status: pending
  - id: extract-detail-widget
    content: "workout_diary_entry_body.dart — lista esercizi/set condivisa con session log"
    status: pending
  - id: routing
    content: "app_routes.dart + route_redirect — nuova route protetta diary detail"
    status: pending
  - id: l10n
    content: "workoutDiaryFilterDate, workoutDiaryOpenPlan, workoutDiaryOpenSession, diaryDetailTitle"
    status: pending
  - id: tests
    content: "Widget test filtri + navigation mock; loader filter unit test"
    status: pending
isProject: false
---

# Feature 33 — Diario workout v2

## Obiettivo prodotto

Il diario MVP (F25) elenca le sessioni ma il dettaglio è un bottom sheet limitato. v5 lo rende **navigabile** e **filtrabile** come strumento di review coach.

## Stato attuale

| Esiste | Limite |
|--------|--------|
| `WorkoutDiaryScreen` — lista cross-cliente | Solo filtro cliente |
| `_showEntryDetail` bottom sheet | No route dedicata |
| `SessionExecutionService.listAll()` | No filtro lato dominio (ok filtrare in UI) |

## Design — Lista con filtri

```
┌─────────────────────────────────────┐
│ Diario          [Cliente ▼] [Data ▼]│
│ [Tutte] [Completate] [Saltate]      │
├─────────────────────────────────────┤
│ 8 lug · Marco · Ipertrofia W2 D1    │
└─────────────────────────────────────┘
```

## Design — Dettaglio (schermata)

- Header: cliente, piano, week/day, data, status
- Note sessione
- Lista esercizi con set/load (read-only in v2; edit defer a F35 se non in parallelo)
- Actions: **Apri piano**, **Apri in calendario**

## Dipendenze

- F24 — `SessionExecution` / `SessionExecutionEntry`
- F35 opzionale — condividere widget body con session log

## Navigazione

- `/workouts/diary` — lista (esistente)
- `/workouts/diary/:sessionKey` — dettaglio (`sessionKey` = chiave planData)

## Test

- `test/features/workouts/workout_diary_screen_test.dart` (estendere)
- Nuovo `workout_diary_entry_screen_test.dart` se route dedicata

## Rischi

- **sessionKey encoding** in URL — usare path param safe o query base64
- **Performance** filtri su lista lunga — debounce + memoized filter

## Definition of done

- Filtro data funzionante (almeno preset 7/30/tutto)
- Dettaglio full-screen con link a piano
- i18n IT/EN
- ≥2 test
- Analyze verde

## Branch suggerito

`feat/workout-diary-v2`

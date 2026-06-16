---
name: feature-25-workout-diary-coach-stats
overview: "Feature #2 v4 — Diario workout reale e dashboard stats coach: storico sessioni, aderenza, sostituisce redirect /workouts/diary e /workouts/stats."
todos:
  - id: diary-screen
    content: Creare WorkoutDiaryScreen — lista SessionExecution cross-cliente o filtro cliente; route /workouts/diary reale (rimuovere redirect)
    status: pending
  - id: diary-detail
    content: WorkoutDiaryEntryDetail — esercizi eseguiti, note, link a piano/sessione
    status: pending
  - id: log-session-flow
    content: Da SessionDetailView — CTA Segna completata apre sheet log rapido (checklist esercizi dal piano, note opzionale) prima di save
    status: pending
  - id: coach-stats-screen
    content: CoachStatsScreen — route /workouts/stats; KPI aderenza 7/30gg, sessioni completate/saltate, clienti attivi
    status: pending
  - id: stats-loader
    content: CoachStatsLoader — aggrega da tutti i piani + SessionExecutionService
    status: pending
  - id: routing
    content: Aggiornare app.dart e route_redirect.dart — diary/stats non più redirect
    status: pending
  - id: nav-entry
    content: Opzionale link da dashboard AppBar o settings; non reintrodurre placeholder in bottom nav builder
    status: pending
  - id: l10n
    content: diaryTitle, diaryEmpty, statsAdherence, statsCompletedSessions, statsSkippedSessions
    status: pending
  - id: tests
    content: CoachStatsLoader unit test; widget test diary empty + populated
    status: pending
isProject: false
---

# Feature 25 — Diario workout e coach stats

## Obiettivo prodotto

Sostituire i redirect temporanei (v3) con due schermate reali:
- **Diario** — cosa è stato fatto, quando, per quale cliente
- **Stats** — vista aggregata aderenza e attività coach

## Stato attuale

| Route | Comportamento post-v3 |
|-------|----------------------|
| `/workouts/diary` | Redirect → `/dashboard/schedule` |
| `/workouts/stats` | Redirect → `/dashboard` |
| Session detail | Segna completed/skipped senza log esercizi |

## Design — Diario

### Lista

```
┌─────────────────────────────────────┐
│ Diario                    [Filtro ▼]│
├─────────────────────────────────────┤
│ 15 giu · Marco Rossi                │
│ Ipertrofia — Giorno A · 8/8 esercizi│
├─────────────────────────────────────┤
│ 14 giu · Sara Bianchi · Saltata     │
└─────────────────────────────────────┘
```

Filtri: cliente, intervallo date, solo completate/saltate.

### Log rapido (da session detail)

1. Coach tap "Segna completata"
2. Bottom sheet: lista esercizi del giorno con checkbox + campo note
3. Save → `SessionExecution` + flag completion

MVP+: edit set/load per esercizio (defer se troppo pesante).

## Design — Coach stats

KPI cards (periodo selezionabile 7 / 30 giorni):

| KPI | Calcolo |
|-----|---------|
| Aderenza % | completed / (completed + skipped + planned passati) |
| Sessioni completate | count |
| Sessioni saltate | count |
| Clienti con ≥1 sessione | distinct customerId |

Grafico semplice: barre per giorno settimana (sessioni completate).

## Dipendenze

- **Feature-24** — modello `SessionExecution` obbligatorio
- Feature-19 — `SessionDetailView` come entry point log

## Navigazione

- `/workouts/diary` → `WorkoutDiaryScreen` (protetta)
- `/workouts/stats` → `CoachStatsScreen` (protetta)
- Rimuovere redirect in [`route_redirect.dart`](lib/core/routing/route_redirect.dart)

## Test

- `test/features/workouts/coach_stats_loader_test.dart`
- `test/features/workouts/workout_diary_screen_test.dart`

## Rischi

- **Performance** — aggregazione su tutti i piani; cache in loader se lento
- **UX log** — troppo lungo per 14 esercizi; MVP checklist senza set detail

## Definition of done

- Diary e stats sono schermate reali, non redirect
- Log minimo da session detail funziona
- ≥3 test
- i18n IT/EN
- Analyze verde

## Branch suggerito

`feat/workout-diary-coach-stats`

---
name: feature-38-coach-hub-discoverability
overview: "Feature #7 v5 — Discoverability: entry point dashboard/hub verso diario, stats e progresso."
todos:
  - id: dashboard-cards
    content: "Dashboard — 2 card/quick actions: Diario workout, Statistiche coach (context.go routes esistenti)"
    status: pending
  - id: customer-detail-links
    content: "Customer detail — link Diario filtrato per cliente (query customerId)"
    status: pending
  - id: schedule-hub
    content: "Schedule screen — chip/link Diario + Stats in app bar o overflow menu"
    status: pending
  - id: diary-customer-filter
    content: "WorkoutDiaryScreen — leggere customerId da query e pre-applicare filtro (dipende F33 o MVP query only)"
    status: pending
  - id: settings-shortcuts
    content: "Opzionale — sezione Coach tools in settings con diary/stats (no duplicare se dashboard basta)"
    status: pending
  - id: l10n
    content: "dashboardDiaryAction, dashboardStatsAction, customerOpenDiary"
    status: pending
  - id: tests
    content: "Widget test dashboard taps navigate; diary pre-filter query test"
    status: pending
isProject: false
---

# Feature 38 — Coach hub discoverability

## Obiettivo prodotto

Le feature v4 (diario, stats) esistono ma sono **difficili da scoprire**. v5 aggiunge entry point naturali dal flusso giornaliero del coach.

## Stato attuale

| Route | Entry attuale |
|-------|---------------|
| `/workouts/diary` | Menu workouts / deep link manuale |
| `/workouts/stats` | Idem |
| Customer detail | Progress panel inline, no link diario |

## Design — Dashboard quick actions

Sezione sotto "Oggi" o in griglia 2 colonne:

```
┌──────────────┐ ┌──────────────┐
│ 📓 Diario    │ │ 📊 Stats     │
│ 3 sessioni   │ │ 85% 7gg    │
└──────────────┘ └──────────────┘
```

Subtitle opzionale con count da loader leggero (cache / async).

## Design — Customer detail

In overview header actions:

- **Vedi diario** → `/workouts/diary?customerId=...`

## Design — Schedule

App bar overflow:

- Diario
- Statistiche

## Dipendenze

- F33 consigliato per filtro query customerId robusto
- F34 per subtitle stats su dashboard (opzionale — placeholder "Statistiche" ok)

## Test

- `test/features/dashboard/` — tap navigates to diary/stats
- Query param parsing in diary screen

## Rischi

- **Dashboard overload** — max 2 card; no ridondanza con tab workouts
- **Extra network/load** — subtitle counts devono essere cheap (local only)

## Definition of done

- Dashboard → diario e stats navigabili
- Customer detail → diario filtrato
- i18n IT/EN
- Analyze verde

## Branch suggerito

`feat/coach-hub-discoverability`

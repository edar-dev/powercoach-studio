---
name: feature-34-coach-stats-charts
overview: "Feature #3 v5 — Coach stats: grafici aderenza/settimana e export KPI (defer v4)."
todos:
  - id: stats-series
    content: "CoachStatsLoader — aggiungere dailyCompletedCounts o weeklyBuckets per periodo selezionato"
    status: pending
  - id: chart-widget
    content: "coach_stats_adherence_chart.dart — bar chart sessioni completate per giorno (fl_chart o CustomPainter leggero)"
    status: pending
  - id: screen-integration
    content: "CoachStatsScreen — inserire chart sotto KPI cards; empty state se zero dati"
    status: pending
  - id: export-csv
    content: "Opzionale — share CSV KPI + serie giornaliera via share_plus"
    status: pending
  - id: l10n
    content: "coachStatsChartTitle, coachStatsChartEmpty, coachStatsExportCsv"
    status: pending
  - id: tests
    content: "coach_stats_loader_test — bucket aggregation; widget smoke chart con dati fake"
    status: pending
isProject: false
---

# Feature 34 — Coach stats — grafici

## Obiettivo prodotto

Completare il defer v4: oltre ai KPI numerici, il coach vede **andamento** sessioni completate nel periodo 7/30 giorni.

## Stato attuale

| File | Contenuto |
|------|-----------|
| [`coach_stats_screen.dart`](lib/features/workouts/presentation/screens/coach_stats_screen.dart) | KPI cards only |
| [`coach_stats_loader.dart`](lib/features/workouts/domain/coach_stats_loader.dart) | adherenceRate, counts |

## Design — Chart

Barre verticali per giorno (7 o 30 barre max):

- Asse X: giorno (locale-aware short label)
- Asse Y: count sessioni **completed** (skipped opzionale seconda serie — defer)
- Tap barra → snackbar con data + count (no navigazione obbligatoria)

## Dipendenze chart library

Preferenza: **nessuna nuova dependency** se possibile — `CustomPainter` o widget Column semplice con `LayoutBuilder`.  
Se `fl_chart` già in pubspec, riusarlo; altrimenti valutare aggiunta (stop condition: chiedere approvazione utente per nuova dep).

## Export CSV (opzionale MVP+)

```
period,7d
adherence,0.85
completed,12
skipped,2
date,completed_count
2026-07-01,2
...
```

## Test

- `test/features/workouts/coach_stats_loader_test.dart` — bucket per date
- Widget test con snapshot fake

## Rischi

- **Locale date labels** — usare `intl` + `Localizations.localeOf`
- **Sparse data** — giorni senza sessioni = barra zero

## Definition of done

- Grafico visibile con dati reali o fake in test
- Periodo 7/30 aggiorna chart
- i18n IT/EN
- Analyze verde

## Branch suggerito

`feat/coach-stats-charts`

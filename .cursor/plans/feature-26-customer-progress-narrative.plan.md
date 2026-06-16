---
name: feature-26-customer-progress-narrative
overview: "Feature #3 v4 — Narrativa progresso cliente: unisce misure corporee, aderenza sessioni e PR da exercise records in un pannello unificato nel customer detail."
todos:
  - id: progress-snapshot
    content: CustomerProgressSnapshot — weightTrend, adherencePercent, lastSessionDate, recentPrs[], sessionsThisMonth
    status: pending
  - id: progress-builder
    content: CustomerProgressMetrics.build(customerId) — aggrega CustomerOverviewMetrics + SessionExecutionService + CustomerExerciseRecordRepository
    status: pending
  - id: progress-panel-ui
    content: CustomerProgressPanel widget — sotto o accanto a CustomerOverviewMetricsPanel nel customer detail
    status: pending
  - id: adherence-strip
    content: Mini calendario o barra 4 settimane — verde completata, grigio saltata, vuoto nessuna sessione
    status: pending
  - id: pr-highlights
    content: Top 3 PR recenti da customer_exercise_record (se dati presenti)
    status: pending
  - id: empty-states
    content: CTA quando no misure / no piani / no esecuzioni — link a add measurement o assign plan
    status: pending
  - id: l10n
    content: customerProgressAdherence, customerProgressLastSession, customerProgressRecentPrs, customerProgressNoData
    status: pending
  - id: tests
    content: Unit test CustomerProgressMetrics; widget test panel con snapshot fake
    status: pending
isProject: false
---

# Feature 26 — Progress narrative cliente

## Obiettivo prodotto

Il customer detail oggi mostra metriche corporee reali (v3) ma non **come il cliente si comporta sul piano**.  
Unificare corpo + comportamento + performance in una narrativa leggibile in 10 secondi.

## Stato attuale

| Componente | File | Dati |
|------------|------|------|
| Overview metriche | [`customer_overview_metrics_panel.dart`](lib/features/customers/presentation/widgets/customer_overview_metrics_panel.dart) | Peso, sparkline 30gg |
| Piani | `customer_detail_screen` | Lista piani recenti |
| Exercise records | `customer_exercise_record_repository` | PR per esercizio custom |
| Aderenza | — | **Assente** |

## Design — CustomerProgressSnapshot

```dart
class CustomerProgressSnapshot {
  final double? adherencePercent;      // ultimi 30gg, null se no piani attivi
  final int completedSessions30d;
  final int skippedSessions30d;
  final DateTime? lastSessionDate;
  final List<CustomerPrHighlight> recentPrs;
  final List<WeeklyAdherenceDot> last4Weeks;
}
```

## Design — UI

```
┌─ Progresso ─────────────────────────┐
│ Aderenza 30gg          82%         │
│ ████████░░  Ultima: 2 giorni fa     │
│                                     │
│ ■ ■ □ ■  (ultime 4 settimane)       │
│                                     │
│ PR recenti                          │
│ · Squat 120 kg (+5)                 │
│ · Bench 85 kg                       │
└─────────────────────────────────────┘
```

Posizione: tab Overview o sezione sotto `CustomerOverviewMetricsPanel`.

## Calcolo aderenza

Per ogni piano **attivo** del cliente:
- Slot passati nel periodo (da `CalendarEventLoader` o logica condivisa con dashboard)
- Confronto con `SessionExecution` / `sessionCompletionByKey`

Escludere piani archiviati (`isArchivedPlan`).

## Dipendenze

- **Feature-24** — esecuzioni per aderenza accurata
- Feature-15 — overview metriche esistenti (non duplicare peso)

## Test

- `test/features/customers/customer_progress_metrics_test.dart`
- `test/features/customers/customer_progress_panel_test.dart`

## Rischi

- **Doppio calcolo** — estrarre helper aderenza condiviso con F25 stats loader
- **Piani multipli** — aggregare o mostrare per piano attivo principale (MVP: aggregato)

## Definition of done

- Pannello visibile in customer detail con dati reali
- Aderenza calcolata da sessioni, non mock
- Empty state chiaro
- ≥3 test
- Analyze verde

## Branch suggerito

`feat/customer-progress-narrative`

---
name: feature-35-session-log-enriched
overview: "Feature #4 v5 — Session log arricchito: edit set/reps/load, allineamento diary e schedule detail."
todos:
  - id: log-model
    content: "Verificare SessionExecutionEntry — supporto reps/load per set; estendere se manca"
    status: completed
  - id: log-ui-sets
    content: "session_log_set_row.dart — input reps/load opzionali per set; toggle completed per esercizio"
    status: completed
  - id: refactor-sheet
    content: "session_log_sheet.dart — estrarre body; ridurre a orchestrator (<200 righe)"
    status: completed
  - id: save-persist
    content: "SessionExecutionService.save — persist set details; aggiornare updatedAt"
    status: completed
  - id: diary-parity
    content: "WorkoutDiaryEntryScreen — riusa workout_diary_entry_body read-only da F33"
    status: completed
  - id: schedule-entry
    content: "schedule_detail_screen — CTA Registra sessione apre log enriched (non solo checklist)"
    status: completed
  - id: l10n
    content: "sessionLogSetReps, sessionLogSetLoad, sessionLogAddSet"
    status: completed
  - id: tests
    content: "session_execution_service_test — round-trip set data; widget test log sheet"
    status: completed
isProject: false
---

# Feature 35 — Session log arricchito

## Obiettivo prodotto

Oltre alla checklist MVP (F24), il coach registra **carichi e ripetizioni** per set durante o dopo la sessione — dati utili per follow-up e PR (F27).

## Stato attuale

| Componente | Comportamento |
|------------|---------------|
| [`session_log_sheet.dart`](lib/features/workouts/presentation/widgets/session_log_sheet.dart) | Checklist esercizi, note, status |
| `SessionExecutionEntry` | `exerciseKey`, `completed` — verificare campi set |
| Schedule detail | Apre sheet log |

## Design — Set row

Per ogni esercizio espandibile:

```
☑ Panca piana
  Set 1  [reps] [kg]  ✓
  Set 2  [reps] [kg]  ✓
  + Aggiungi set
```

- Reps/load **opzionali** (nullable) — checklist still valid without numbers
- Salvataggio on dismiss o explicit Save (match pattern esistente sheet)

## Allineamento dati

- Stesso payload usato da `CustomerProgressPanel` / PR detection
- Diary detail (F33) mostra set salvati in read-only

## Dipendenze

- F24 — session execution model
- F33 consigliato prima o in parallelo (shared body widget)

## Test

- `test/features/workouts/session_execution_service_test.dart`
- Widget test input validation (reps positive int, load decimal)

## Rischi

- **Schema drift** in Drift JSON payload — migration backward compat per log esistenti senza set
- **UX mobile** — keyboard overlap; usare `Scrollable` + `viewInsets`

## Definition of done

- Coach può salvare almeno reps OR load per set
- Diary mostra dati salvati
- i18n IT/EN
- Analyze + test verdi

## Branch suggerito

`feat/session-log-enriched`

---
name: feature-28-follow-up-from-execution
overview: "Feature #5 v4 — Follow-up intelligente: clona mesociclo usando volumi/load da SessionExecution precedente, non solo struttura del piano."
todos:
  - id: audit-follow-up-factory
    content: Rivedere prepareFollowUpRoutine in workout_follow_up_factory.dart — estendere input con List<SessionExecution> o adherence summary
    status: pending
  - id: load-progression-rules
    content: Regole MVP — mantieni sets/reps; se tutti i set completed, +2.5% load suggerito (testo) o copia load effettivo da execution
    status: pending
  - id: repository-wire
    content: WorkoutPlanRepository.createFollowUp — carica esecuzioni piano sorgente prima di prepareFollowUpRoutine
    status: pending
  - id: ui-preview
    content: Dialog follow-up — mostra "Basato su 12 sessioni completate" + checkbox "Applica carichi eseguiti"
    status: pending
  - id: partial-execution
    content: Se nessuna execution — fallback a comportamento attuale (clone struttura)
    status: pending
  - id: l10n
    content: workoutFollowUpFromExecution, workoutFollowUpNoExecutionData
    status: pending
  - id: tests
    content: Unit test prepareFollowUpRoutine con execution fixture; regression test senza execution
    status: pending
isProject: false
---

# Feature 28 — Follow-up da esecuzione

## Obiettivo prodotto

Il follow-up esistente clona **struttura** (`prepareFollowUpRoutine`).  
Dopo F24, il coach ha dati su cosa è stato **eseguito** — il follow-up deve rifletterli.

## Stato attuale

| Area | File |
|------|------|
| Factory | [`workout_follow_up_factory.dart`](lib/features/workouts/domain/workout_follow_up_factory.dart) |
| Repository | `WorkoutPlanRepository.createFollowUp` |
| UI | `customer_workouts_screen`, `customer_detail_screen` |

## Design — Input esteso

```dart
WorkoutRoutine prepareFollowUpRoutine({
  required WorkoutRoutine source,
  required List<SessionExecution> executions,
  FollowUpOptions options = const FollowUpOptions(),
});

class FollowUpOptions {
  final bool applyExecutedLoads;
  final bool bumpLoadWhenAllSetsCompleted;
}
```

## Regole MVP

| Scenario | Azione |
|----------|--------|
| Nessuna execution | Clone struttura (oggi) |
| Execution con set/load | Copia load/reps negli `ExerciseSet` del nuovo piano |
| Tutti set completed per esercizio | Note coach "considera progressione" (non auto-apply aggressivo in v1) |
| Sessioni saltate frequenti | Opzionale: non avanzare week index |

## UI

Prima di creare follow-up:

```
Crea follow-up da "Ipertrofia Maggio"
☑ Usa carichi dall'ultima esecuzione (8 sessioni)
[ Crea follow-up ]
```

## Dipendenze

- **Feature-24** — `SessionExecution`
- Feature-10 — follow-up clone base (**implementato**)

## Test

- `test/features/workouts/workout_follow_up_factory_test.dart` (estendere)

## Rischi

- **Progressione automatica** — troppo aggressiva per coach conservativi; default off o solo copy
- **Mismatch exercise id** — dopo edit piano, id cambiano; match per nome fallback

## Definition of done

- Follow-up con execution data differisce da clone puro (test dimostra)
- Fallback senza execution invariato
- Dialog preview in UI
- ≥4 unit test
- Analyze verde

## Branch suggerito

`feat/follow-up-from-execution`

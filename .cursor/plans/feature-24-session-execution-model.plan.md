---
name: feature-24-session-execution-model
overview: "Feature #1 v4 — Modello dati per esecuzione sessione: log esercizi eseguiti, collegamento a completed/skipped, API dominio e persistenza local-first."
todos:
  - id: domain-model
    content: Definire SessionExecution, ExecutedExercise, ExecutedSet in domain/ — id, planId, weekIndex, dayIndex, sessionDate, status, exercises[], notes, completedAt
    status: pending
  - id: storage-key
    content: "Persistenza in planData.sessionExecutions (map keyed by sessionKey) oppure entità OfflineEntity dedicata session_execution — preferire planData per coerenza con sessionCompletionByKey"
    status: pending
  - id: codec-roundtrip
    content: Estendere workout_routine_model.dart encode/decode sessionExecutions con backward compat (assente = {})
    status: pending
  - id: repository-api
    content: WorkoutPlanRepository.upsertSessionExecution, getSessionExecution, listExecutionsForPlan, deleteExecution
    status: pending
  - id: bridge-status-service
    content: PlanSessionStatusService — quando completed, creare/aggiornare SessionExecution stub; quando skipped, marcare senza esercizi
    status: pending
  - id: session-key-helper
    content: Riutilizzare sessionKey esistente (week/day + override date) — allineare con plan_calendar_event.dart
    status: pending
  - id: unit-tests
    content: Codec round-trip, repository CRUD fake store, sessionKey collisioni
    status: pending
isProject: false
---

# Feature 24 — Modello esecuzione sessione

## Obiettivo prodotto

Oggi il coach può segnare una sessione **completata** o **saltata**, ma non **cosa** è stato fatto.  
Serve un modello persistente per alimentare diario, stats e follow-up intelligenti.

## Stato attuale

| Area | File | Limite |
|------|------|--------|
| Completion flags | `sessionCompletionByKey` in [`workout_routine_model.dart`](lib/features/workouts/data/workout_routine_model.dart) | Solo bool completed/skipped |
| Status service | [`plan_session_status_service.dart`](lib/features/workouts/domain/plan_session_status_service.dart) | Scrive flag, non log |
| Overrides | `sessionOverrides` | Sposta/salta date, non esecuzione |

## Design — Modello (MVP)

```dart
class SessionExecution {
  final String sessionKey;      // es. "w0_d1" o con suffisso data override
  final DateTime sessionDate;   // giorno calendario effettivo
  final PlanSessionStatus status;
  final DateTime? completedAt;
  final String? notes;
  final List<ExecutedExercise> exercises;
}

class ExecutedExercise {
  final String exerciseId;      // id nel piano
  final String name;
  final List<ExecutedSet> sets;
  final String? customExerciseId;
}

class ExecutedSet {
  final String? reps;
  final String? load;           // kg o RPE testuale come nel builder
  final bool completed;
}
```

### Persistenza — planData

```json
{
  "sessionExecutions": {
    "w0_d1_2026-06-15": {
      "sessionDate": "2026-06-15",
      "status": "completed",
      "completedAt": "2026-06-15T10:30:00.000Z",
      "exercises": [ ... ]
    }
  }
}
```

**Perché planData:** co-locato con piano, incluso in backup/export JSON esistente.

## Design — Creazione esecuzione

| Trigger | Comportamento MVP |
|---------|-------------------|
| Segna completata (senza log) | `SessionExecution` con `exercises` vuoto o prefill da piano (opzionale) |
| Log manuale futuro (F25) | Upsert completo con set |
| Segna saltata | `status: skipped`, no exercises |

Non rompere `sessionCompletionByKey` — mantenerlo in sync per calendario esistente fino a migrazione graduale.

## API dominio

```dart
class SessionExecutionService {
  Future<SessionExecution?> get({required String planId, required String sessionKey});
  Future<void> save({required String planId, required SessionExecution execution});
  Future<List<SessionExecution>> listForPlan(String planId);
  Future<double> adherenceRate(String planId, {DateTime? from, DateTime? to});
}
```

## Test

- `test/features/workouts/session_execution_codec_test.dart`
- `test/features/workouts/session_execution_service_test.dart`

## Rischi

- **Dimensione planData** — piani con centinaia di log; valutare cap o purge esecuzioni > N mesi in follow-up
- **Chiave sessione** — allineamento con override date (feature-20)

## Definition of done

- Modello serializzabile in planData
- Repository salva/legge esecuzioni
- `PlanSessionStatusService` crea stub execution su completed/skipped
- ≥5 unit test
- Analyze verde

## Branch suggerito

`feat/session-execution-model`

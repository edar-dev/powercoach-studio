---
name: feature-45-plan-diff
overview: "Wave 2 PR2 — Confronto strutturale in-memory tra due WorkoutRoutine (picker A/B stesso cliente); nessuna migration Drift."
todos:
  - id: domain-diff
    content: "Nuovo workout_routine_diff.dart — diff days/exercises/sets/coachingNote; output typed changes"
    status: pending
  - id: picker-ui
    content: "Plan diff screen — picker routine A/B stesso customerId; solo piani locali OfflineLocalStore"
    status: pending
  - id: diff-view
    content: "Vista grouped: added/removed/modified per day ed exercise; set changes collapsed"
    status: pending
  - id: route-entry
    content: "Entry da builder o customer detail — top-level o nested path documentato; no persist diff"
    status: pending
  - id: tests
    content: "Unit test matrice diff (identical, rename, coachingNote, set reps/load); widget picker"
    status: pending
isProject: false
---

# Feature 45 — Plan diff (structural compare)

## Obiettivo

Il coach **confronta due versioni** di scheda dello stesso cliente — diff strutturale in memoria, senza snapshot DB né migration Drift.

## Domain

Nuovo modulo puro: `lib/features/workouts/domain/workout_routine_diff.dart`

Input:

- `WorkoutRoutine a`, `WorkoutRoutine b` (già in memoria da `OfflineLocalStore`)

Output suggerito:

```dart
class WorkoutRoutineDiff {
  final List<DayDiff> days; // added | removed | modified
}
class DayDiff { /* coachingNote change, exercises */ }
class ExerciseDiff { /* sets added/removed/changed */ }
```

Regole:

- Match day per indice/nome come builder esistente
- Match exercise per `exerciseId` poi fallback name (allineato a follow-up factory)
- Set diff: reps, load, rpe, rest, notes — ignora ordine se invariante
- `Day.coachingNote` (F41) incluso nel diff

## UI

[`plan_diff_screen.dart`](../../lib/features/workouts/presentation/screens/plan_diff_screen.dart):

1. **Picker A / B** — dropdown o bottom sheet; filtra `customerId` uguale
2. **Summary chips** — N giorni modificati, M esercizi aggiunti, …
3. **Grouped list** — expand per day; colori semantic (added/removed/changed)
4. Read-only — **nessun** apply merge in v1 (scope cut esplicito)

Entry:

- Builder toolbar “Confronta versione…”
- Customer detail → piani → compare

## Persistenza

- **Zero** Drift schema change
- Diff calcolato on demand; nessun cache file
- Opzionale: confronto backup JSON importato in memoria (future; out of scope v1)

## Test

- Fixture: piani identici → empty diff
- Rename exercise vs new exercise
- coachingNote added/removed
- Set load change only
- Widget: picker disabilita stessa routine per A e B

## Branch

`feat/identity-wave2`

## Dipendenze

- F41 `coachingNote` nel modello (Wave 1 ✅)
- Indipendente da F44 (gym mode)

## Scope escluso

- Merge / apply diff al piano
- Version history automatica in DB
- Diff PDF export (Wave 3 narrative candidate)

## Definition of done

- Coach seleziona A/B stesso cliente e vede diff strutturale chiaro
- `flutter analyze` + unit test domain + smoke widget picker

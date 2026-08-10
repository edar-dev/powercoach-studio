---
name: feature-42-progression-suggestions
overview: "Wave 1 PR3 — Suggerimenti progressione rules-based da log locali; chip Apply in builder/follow-up (suggest-only, no auto-write)."
todos:
  - id: domain-module
    content: "Nuovo exercise_progression_suggestions.dart — input piano + sessionExecutions"
    status: completed
  - id: rules-engine
    content: "Regole default: bump carico, maintain, +reps; graceful su carico non numerico"
    status: completed
  - id: builder-ui
    content: "Chip Apply su card esercizio builder e/o preview follow-up dialog"
    status: completed
  - id: tests
    content: "Matrice regole con fixture; widget chip; no regressione follow-up apply loads"
    status: completed
isProject: false
---

# Feature 42 — Progression suggestions

## Obiettivo

Suggerimenti **rules-based** dalla storia sessioni locali — il coach applica con un tap, senza mutazione silenziosa del piano.

## Modulo

`lib/features/workouts/domain/exercise_progression_suggestions.dart`

- Input: piano + `sessionExecutions` locali
- Regole default: ultime sessioni complete → bump carico (~2.5%); parziale → maintain; top range reps → +reps
- Matching exerciseId/name come [`workout_follow_up_factory.dart`](../../lib/features/workouts/domain/workout_follow_up_factory.dart)

## UI

- Chip “Apply” su card esercizio builder e/o preview in follow-up dialog
- **Non** auto-write del piano

## Test

- Matrice regole con fixture
- Widget chip
- Nessuna regressione follow-up apply loads

## Branch

`feat/identity-wave1-progression-suggestions`

## Dipendenze

Consigliato dopo F40 (log arricchiti alimentano le regole).

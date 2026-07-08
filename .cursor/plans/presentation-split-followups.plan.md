---
name: presentation-split-followups
overview: "Follow-up al presentation-split-v1: import handler exercise library, riuso set rows editor, riduzione ulteriore mobility screen."
todos:
  - id: exercise-library-import-handler
    content: "Estrarre import Hevy/file/default in handler + service (404 righe screen)"
    status: completed
  - id: reuse-set-rows-editor
    content: "Usare ExerciseAddSetRowsEditor in workout_training_helpers"
    status: completed
  - id: mobility-screen-trim
    content: "Date pickers + WorkoutBuilderScreenTabs (513 righe screen, −88 vs PR #67)"
    status: completed
  - id: verify-followups
    content: "flutter analyze + test/ — 278 test passati"
    status: completed
isProject: false
---

# Presentation Split — Follow-ups

## Obiettivo

Completare i tre follow-up emersi dopo presentation-split-v1, senza cambiare UX.

## Scope

| # | Target | Azione | Risultato |
|---|--------|--------|-----------|
| 1 | `exercise_library_screen.dart` | `ExerciseLibraryImportService` + `ExerciseLibraryImportHandler` | 635 → **404** |
| 2 | `workout_training_helpers.dart` | Riutilizzare `ExerciseAddSetRowsEditor` | −~80 righe duplicate |
| 3 | `workout_builder_mobility_screen.dart` | Date picker helpers + `WorkoutBuilderScreenTabs` | 601 → **513** |

## Regole

- Nessun behavior change intenzionale
- Test unitari per import service e date picker helpers
- Branch: `refactor/presentation-split-followups-v1`

## Residuo opzionale

- Mobility screen ancora >400 righe: candidati futuri load/save state applicator nel coordinator

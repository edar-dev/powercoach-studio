---
name: presentation-split-followups
overview: "Follow-up al presentation-split-v1: import handler exercise library, riuso set rows editor, riduzione ulteriore mobility screen."
todos:
  - id: exercise-library-import-handler
    content: "Estrarre import Hevy/file/default da exercise_library_screen in handler + service"
    status: in_progress
  - id: reuse-set-rows-editor
    content: "Usare ExerciseAddSetRowsEditor in workout_training_helpers al posto del blocco duplicato"
    status: pending
  - id: mobility-screen-trim
    content: "Estrarre date pickers e tab/shell wiring da workout_builder_mobility_screen (<400 righe)"
    status: pending
  - id: verify-followups
    content: "flutter analyze + flutter test test/ — no behavior change"
    status: pending
isProject: false
---

# Presentation Split — Follow-ups

## Obiettivo

Completare i tre follow-up emersi dopo presentation-split-v1, senza cambiare UX.

## Scope

| # | Target | Azione | Target righe |
|---|--------|--------|--------------|
| 1 | `exercise_library_screen.dart` | `ExerciseLibraryImportService` + `ExerciseLibraryImportHandler` | ~450 |
| 2 | `workout_training_helpers.dart` | Riutilizzare `ExerciseAddSetRowsEditor` | −~80 righe duplicate |
| 3 | `workout_builder_mobility_screen.dart` | Date picker helpers + `WorkoutBuilderScreenTabs` | <400 |

## Regole

- Nessun behavior change intenzionale
- Test unitari per import service e date picker helpers
- Un branch: `refactor/presentation-split-followups-v1`

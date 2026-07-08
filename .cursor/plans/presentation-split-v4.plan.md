---
name: presentation-split-v4
overview: "Split sui candidati v3 priorità 7–9 e file presentation >430 righe rimasti dopo v3."
status: completed
dependsOn: presentation-split-v3
todos:
  - id: split-customer-list
    content: "customer_list_screen.dart 484 → 130 righe"
    status: completed
  - id: split-training-helpers
    content: "workout_training_helpers.dart 474 → barrel + dialog modules"
    status: completed
  - id: split-mobility-add-sheet
    content: "mobility_add_sheet.dart 449 → 28 righe + content 427"
    status: completed
  - id: split-measurement-history
    content: "customer_measurement_history_screen.dart 446 → 283 righe"
    status: completed
  - id: split-exercise-record-form
    content: "customer_exercise_record_form_screen.dart 458 → 268 righe"
    status: completed
  - id: split-mobility-tab
    content: "workout_mobility_tab.dart 432 → 167 righe"
    status: completed
  - id: verify-v4
    content: "flutter analyze + test/ — 280 passed"
    status: completed
isProject: false
---

# Presentation Split v4

Completamento candidati opzionali lasciati aperti da v3 (priorità 7–9) più file presentation ancora >430 righe.

## Regole

- Extract-only, nessun behavior change intenzionale
- Branch: `refactor/presentation-split-v4`

## Risultati

| File | Prima | Dopo |
|------|------:|-----:|
| `customer_list_screen.dart` | 484 | 130 |
| `workout_training_helpers.dart` | 474 | 4 (barrel) |
| `mobility_add_sheet.dart` | 449 | 28 |
| `customer_measurement_history_screen.dart` | 446 | 283 |
| `customer_exercise_record_form_screen.dart` | 458 | 268 |
| `workout_mobility_tab.dart` | 432 | 167 |

`exercise_add_sheet.dart` (470) resta sotto soglia critica; ulteriore split opzionale v5.

---
name: presentation-split-v5
overview: "Split finale exercise_add_sheet — unico file presentation >470 righe dopo v4."
status: completed
dependsOn: presentation-split-v4
todos:
  - id: split-exercise-add-content
    content: "exercise_add_sheet.dart 470 → 38 righe; content 323"
    status: completed
  - id: split-exercise-add-loader
    content: "exercise_add_sheet_loader.dart — picker + customer records"
    status: completed
  - id: split-exercise-add-save
    content: "exercise_add_sheet_save_handler.dart — save/create flows"
    status: completed
  - id: verify-v5
    content: "flutter analyze + test/ — 280 passed"
    status: completed
isProject: false
---

# Presentation Split v5

## Obiettivo

Ridurre `exercise_add_sheet.dart` (470 righe) allineandolo al pattern v4 di `mobility_add_sheet` + `mobility_add_sheet_content`.

## Regole

- Extract-only, nessun behavior change intenzionale
- Branch: `refactor/split-exercise-add-sheet`
- Verifica: `flutter analyze --no-pub` + `flutter test test/ --no-pub`

## Risultati

| File | Prima | Dopo |
|------|------:|-----:|
| `exercise_add_sheet.dart` | 470 | 38 |
| `exercise_add_sheet_content.dart` | — | 323 |
| `exercise_add_sheet_loader.dart` | — | 81 |
| `exercise_add_sheet_save_handler.dart` | — | 158 |
| `exercise_add_create_new_fields.dart` | — | 39 |

Nessun file presentation >470 righe su main post-merge.

## Non in scope

- `mobility_add_sheet_content.dart` (427) — opzionale v5b

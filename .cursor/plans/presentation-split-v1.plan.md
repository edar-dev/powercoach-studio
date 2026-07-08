---
name: presentation-split-v1
overview: "Spezzare i mega-file presentation (>900 righe) estraendo controller, tab body e widget riusabili. Chiuso con follow-ups v1/v2 — vedi presentation-split-v3 per prossimi candidati opzionali."
status: closed
closedAt: "2026-07-08"
todos:
  - id: inventory-and-order
    content: "Ordine split confermato e completato (#62–69)"
    status: completed
  - id: split-mobility-builder
    content: "workout_builder_mobility_screen.dart 1291 → 390 righe (#67–69)"
    status: completed
  - id: split-customer-workouts
    content: "customer_workouts_screen.dart 1108 → 413 righe (#62–63)"
    status: completed
  - id: split-plan-templates
    content: "workout_plan_templates_screen.dart 1071 → 401 righe (#64)"
    status: completed
  - id: split-exercise-library
    content: "exercise_library_screen.dart 937 → 230 righe (#65, #68–69)"
    status: completed
  - id: split-exercise-add-sheet
    content: "exercise_add_sheet.dart 926 → 470 righe (#66)"
    status: completed
  - id: widget-tests-per-split
    content: "Copertura test su estratti critici — vedi tabella sotto"
    status: completed
  - id: analyze-after-each-pr
    content: "flutter analyze + test/ verde su ogni PR #62–69"
    status: completed
isProject: false
---

# Presentation Layer Split v1 — CHIUSO

## Esito

Obiettivo raggiunto: **nessuno dei 5 screen target supera ~470 righe**; i quattro principali sono **≤401 righe**. Nessun behavior change intenzionale.

Completato in **8 PR** (#62–#69) + follow-ups documentati in [`presentation-split-followups.plan.md`](presentation-split-followups.plan.md) e [`presentation-split-followups-v2.plan.md`](presentation-split-followups-v2.plan.md).

## Risultati finali per file target

| File | Partenza | Finale | PR |
|------|----------|--------|-----|
| `workout_builder_mobility_screen.dart` | ~1291 | **390** | #67, #68, #69 |
| `customer_workouts_screen.dart` | ~1108 | **413** | #62, #63 |
| `workout_plan_templates_screen.dart` | ~1071 | **401** | #64 |
| `exercise_library_screen.dart` | ~937 | **230** | #65, #68, #69 |
| `exercise_add_sheet.dart` | ~926 | **470** | #66 |

## PR mergiati

| PR | Branch | Scope |
|----|--------|-------|
| #62 | `refactor/split-customer-workout-list` | Customer workout list widgets |
| #63 | `refactor/split-customer-workouts-screen` | Session actions + plan dialogs |
| #64 | `refactor/split-plan-templates-screen` | Template list/preview/assign |
| #65 | `refactor/split-exercise-library-screen` | Tab view, tree helpers, import sheet |
| #66 | `refactor/split-exercise-add-sheet` | Picker, set rows, sheet states |
| #67 | `refactor/split-mobility-builder-handlers` | Handlers + routine coordinator |
| #68 | `refactor/presentation-split-followups-v1` | Import handler, set rows reuse, date/tabs |
| #69 | `refactor/presentation-split-followups-v2` | CRUD/export, load/actions/tabs config |

## Verifica

- **280 test** in `test/` (da ~263 a inizio split)
- `flutter analyze --no-pub` — green su ogni PR
- CI GitHub — green su #62–#69

## Copertura test estratti critici

| Area | Test |
|------|------|
| Mobility builder shell | `workout_builder_editor_shell_test.dart` |
| Builder widgets | `workout_builder_widgets_test.dart` |
| Session / load / coordinator | `workout_builder_session_controller_test.dart`, `workout_builder_load_helpers_test.dart`, `workout_builder_routine_coordinator_test.dart` |
| Follow-ups load/date | `workout_builder_editor_load_application_test.dart`, `workout_builder_date_picker_helpers_test.dart` |
| Exercise library | `exercise_library_list_tile_test.dart`, `exercise_library_tree_helpers_test.dart`, `exercise_library_import_service_test.dart` |
| Plan templates | `workout_template_list_helpers_test.dart` |
| Exercise add sheet | `exercise_picker_sheet_test.dart` (pattern esistente) |

Gap noti (non bloccanti): nessun widget test dedicato a `WorkoutBuilderScreenTabsConfig` o `ExerciseLibraryCrudHandler` — logica UI delegata a dialog/sheet già testati altrove.

## Prossimo passo opzionale

File presentation ancora >400 righe fuori scope v1 → [`presentation-split-v3.plan.md`](presentation-split-v3.plan.md).

## Pattern consolidato

1. Screen = entry point routing + stato minimo
2. Controller/coordinator = load/save/dirty
3. Handler = flussi UI multi-step (import, CRUD, export)
4. Widget/tab body in `presentation/widgets/`
5. Helper puri in `domain/` con unit test
6. Un PR per scope, branch `refactor/<scope>-<description>`

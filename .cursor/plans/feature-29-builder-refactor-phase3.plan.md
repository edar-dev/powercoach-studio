---
name: feature-29-builder-refactor-phase3
overview: "Feature #6 v4 — Builder refactor fase 3: estrarre superset/prescription UI, thin screen wrapper; target screen principale sotto 1000 righe."
todos:
  - id: audit-line-count
    content: Baseline righe workout_builder_mobility_screen.dart e lista metodi ancora inline
    status: pending
  - id: extract-superset-panel
    content: workout_superset_tab.dart o estensione workout_training_tab — multiset/superset/intuitive UI
    status: pending
  - id: extract-prescription-scope
    content: Spostare prescription scope selector e logica in widget dedicato
    status: pending
  - id: thin-screen
    content: Screen delega a tab widgets + WorkoutEditorController; rimuovere metodi _updateExercise rimasti se duplicano workout_exercise_mutations
    status: pending
  - id: controller-coverage
    content: WorkoutEditorController — esporre mobility/superset callbacks; test fake repo
    status: pending
  - id: widget-tests
    content: Test tab training con controller fake; regression mobility mutations
    status: pending
  - id: profiling-checklist
    content: Documentare in workout_lazy_tab.md o PR template — DevTools steps per piano 14 esercizi (docs/pdfs stress)
    status: pending
  - id: line-target
    content: Verificare screen sotto 1000 righe post-estrazione
    status: pending
isProject: false
---

# Feature 29 — Builder refactor fase 3

## Obiettivo prodotto

Dopo v3 il builder è ~1500 righe con mobility/exercise mutations estratte.  
Fase 3 completa l'estrazione del **training/superset** e rende lo screen un thin wrapper testabile.

## Stato attuale (post-v3)

| Estratto | File |
|----------|------|
| Controller | `workout_editor_controller.dart` |
| Tab | `workout_training_tab.dart`, `workout_mobility_tab.dart`, `workout_lazy_tab.dart` |
| Mutations | `workout_routine_mutations.dart`, `workout_exercise_mutations.dart`, `workout_mobility_mutations.dart` |
| App bar / save | `workout_editor_app_bar.dart`, `workout_editor_save_status_indicator.dart` |

| Ancora nel monolite | Stima |
|---------------------|-------|
| Superset / multiset / intuitive variant UI | ~400 righe |
| Prescription scope | ~150 righe |
| Orchestrazione save/export/editor mode | ~200 righe |
| Dialoghi residui | ~100 righe |

## Design — Estrazioni

```
workout_builder_mobility_screen.dart  (<1000 righe)
├── WorkoutEditorController
├── WorkoutEditorAppBar
├── TabBar + WorkoutLazyTab × N
│   ├── WorkoutTrainingTab
│   ├── WorkoutSupersetPanel (nuovo)
│   ├── WorkoutMobilityTab
│   └── WorkoutPlanDetailsTab
└── Bottom nav (standalone only)
```

### WorkoutSupersetPanel

Props: `routine`, `weekIndex`, `dayIndex`, `variant`, callbacks `onRoutineChanged`.

Contiene UI specifica per `WorkoutBuilderVariant.superset | multiset | intuitiveSuperset`.

## Principi

- Nessun rewrite architetturale
- Ogni estrazione = PR verificabile con analyze + test
- Comportamento invariato per export PDF/JSON

## Dipendenze

- Feature-16 (v3) — fasi 1–2 (**completate**)
- Feature-22 — performance lazy tab (**completata**)

## Test

- Estendere `workout_editor_controller_test.dart`
- Widget test `workout_superset_panel_test.dart` (opzionale se UI semplice)

## Rischi

- **Regressioni varianti** — testare tutte e 4 varianti builder manualmente
- **Editor mode cliente** — bottom nav nascosta; verificare parità

## Definition of done

- Screen < 1000 righe
- Superset UI in file dedicato
- Nessuna regressione export
- Analyze + test esistenti verdi

## Branch suggerito

`refactor/builder-phase3-superset-extract`

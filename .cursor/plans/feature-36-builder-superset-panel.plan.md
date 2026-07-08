---
name: feature-36-builder-superset-panel
overview: "Feature #5 v5 — Pannello superset dedicato nel workout builder training (residuo F29)."
todos:
  - id: superset-panel-widget
    content: "workout_builder_superset_panel.dart — lista esercizi nel superset, reorder, rimuovi, aggiungi da library"
    status: completed
  - id: wire-training-tab
    content: "workout_builder_training_tab.dart — apri panel su tap superset block (sostituire dialog inline se presente)"
    status: completed
  - id: prescription-scope
    content: "Allineare prescription editor scope con superset — sets/reps a livello superset vs per-exercise (documentare scelta)"
    status: completed
  - id: actions-refactor
    content: "workout_superset_actions.dart — spostare create/link/unlink nel panel dove possibile"
    status: completed
  - id: l10n
    content: "builderSupersetPanelTitle, builderSupersetAddExercise, builderSupersetEmpty"
    status: completed
  - id: tests
    content: "Widget test panel con fake plan data; existing superset_actions tests green"
    status: completed
isProject: false
---

# Feature 36 — Builder superset panel

## Obiettivo prodotto

Completare il residuo **F29**: gestione superset con UI dedicata invece di azioni sparse nel builder training.

## Stato attuale

| File | Ruolo |
|------|--------|
| [`workout_superset_actions.dart`](lib/features/workouts/presentation/workout_superset_actions.dart) | create/link/unlink |
| [`workout_builder_training_tab.dart`](lib/features/workouts/presentation/widgets/workout_builder_training_tab.dart) | lista blocchi |
| [`workout_builder_mobility_screen.dart`](lib/features/workouts/presentation/screens/workout_builder_mobility_screen.dart) | ~390 righe (target 1000 già raggiunto post presentation-split) |

**Nota:** il goal "screen <1000 righe" di F29 è già soddisfatto; v5 punta alla **UX superset**, non al line count.

## Design — Panel (bottom sheet o side panel)

```
Superset A                    [×]
─────────────────────────────────
1. Curl bilanciere    [↕] [🗑]
2. French press       [↕] [🗑]
[+ Aggiungi esercizio]
Prescrizione: 3 × 12  (scope superset)
[Salva]
```

- Reorder drag handle per esercizi nel gruppo
- Aggiungi esercizio → picker library filtrato
- Unlink singolo esercizio dal superset

## Prescription scope

Documentare in piano/code comment:

- **Default v5:** sets/reps condivisi a livello superset (come oggi se già così)
- Se per-exercise diverso → defer v6

## Dipendenze

- F29 parziale — superset data model in plan JSON
- Exercise library picker esistente

## Test

- Estendere test superset se presenti in `test/features/workouts/`
- Widget smoke: apri panel, aggiungi mock exercise

## Rischi

- **Undo/draft** — assicurare `WorkoutPlanDraftStore` riceva update panel
- **Mobility vs training** — panel solo training tab

## Definition of done

- Tap superset block → panel dedicato funzionante
- Create/link/unlink coperti da panel o actions refactor
- i18n IT/EN
- Analyze verde

## Branch suggerito

`feat/builder-superset-panel`

---
name: feature-49-workout-plan-phases
overview: "Fasi strutturali nel tab Allenamento (preset + custom), UI Stitch rail+dettaglio, migrazione codec weeks→phases."
todos:
  - id: model-codec
    content: Phase model (+ objective) + WorkoutRoutine.phases; codec dual-read; flattenWeeks
    status: completed
  - id: mutations-session
    content: Phase CRUD + week-in-phase; selectedPhaseIndex + selectedWeekInPhase
    status: completed
  - id: presets-l10n
    content: workout_phase_presets + ARB IT/EN
    status: completed
  - id: training-ui
    content: "UI Stitch: rail fasi + dettaglio meta + settimane; empty Aggiungi Fase"
    status: completed
  - id: downstream-tests
    content: Wizard/diff/export via flatten; codec/mutation/widget tests
    status: completed
isProject: false
---

# Feature 49 — Workout plan phases

Piano dettagliato + screenshot Stitch: [`workout_plan_phases_e1a13e69.plan.md`](workout_plan_phases_e1a13e69.plan.md)

Asset: [`design/stitch-assets/phase-planning-ui/`](../../design/stitch-assets/phase-planning-ui/)

## Obiettivo

`WorkoutRoutine` → `List<Phase>` → `List<Week>` → days. Tab Allenamento: lista fasi + dettaglio (obiettivo, durata/frequenza derivate, avanzamento %) + settimane annidate.

## Branch

`feat/workout-plan-phases`

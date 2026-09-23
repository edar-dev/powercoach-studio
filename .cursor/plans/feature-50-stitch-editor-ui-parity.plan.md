---
name: feature-50-stitch-editor-ui-parity
overview: "Uniformare l’intero flusso editor scheda (Allenamento + modali sessione/libreria/esercizio custom) ai prototipi Stitch: parity visuale tab fasi e Modifica sessione in modale full-screen con drawer libreria e modale creazione esercizio."
todos:
  - id: assets-sync
    content: Re-download all Stitch screens PNG+HTML into design/stitch-assets/phase-planning-ui/
    status: completed
  - id: allenamento-parity
    content: "Visual parity pass: phase rail/meta/day cards; Modifica sessione opens modal only"
    status: completed
  - id: session-modal
    content: Extract TrainingSessionEditSheet; showAppBottomSheet fullScreen; remove inline panel
    status: completed
  - id: library-drawer
    content: Library side panel (desktop) / sheet (mobile) from Aggiungi esercizio
    status: completed
  - id: create-exercise-modal
    content: Stitch-aligned custom exercise create modal from library drawer
    status: completed
  - id: tests-docs
    content: Widget tests + flutter analyze; keep README index current
    status: completed
isProject: false
---

# Feature 50 — Stitch editor UI parity (identica al prototipo)

Piano dettagliato + screenshot Stitch: [`stitch_editor_ui_parity_945a84f8.plan.md`](stitch_editor_ui_parity_945a84f8.plan.md)

Asset: [`design/stitch-assets/phase-planning-ui/`](../../design/stitch-assets/phase-planning-ui/)

Prerequisito / modello fasi: [`feature-49-workout-plan-phases.plan.md`](feature-49-workout-plan-phases.plan.md)

## Obiettivo

Allineare l’editor scheda ai prototipi Stitch progetto `14496212854931615246`:

1. Shell Allenamento (pills fasi, meta, day cards) — parity visuale
2. **Modifica sessione** in modale full-screen (niente editor inline)
3. Drawer / side panel libreria da “Aggiungi esercizio”
4. Modale creazione esercizio personalizzato da libreria

## Decisioni chiuse

- **Scope 1B:** tutto il flusso editor Stitch (non solo tab Allenamento).
- **Editing sessione:** modale full-screen; rimuovere pannello inline sotto griglia giorni.
- **Branch:** continuare su `feat/workout-plan-phases` (modello fasi già presente).
- **Source of truth:** asset in `design/stitch-assets/phase-planning-ui/`.

## Workstream (ordine)

| ID | Focus | Stato |
|----|--------|-------|
| A | Asset sync + Allenamento parity | ✅ |
| B | Modale Modifica sessione | ✅ |
| C | Drawer libreria | ✅ |
| D | Modale crea esercizio | ✅ |
| E | Test + analyze | ✅ |
| F50–F55 | Density / editor mode / empty / drawer states | ✅ (F50 chrome full deferred) |

## Fuori scope

- Tab “Progressione & Carichi” (mock header Stitch)
- Gym mode / session log execution
- Cambio modello `Phase` / codec
- Font esterni non nel design system (`StitchM3Theme` tokens)

## Follow-up screens F50–F55

Asset folder: [`design/stitch-assets/phase-planning-ui/`](../../design/stitch-assets/phase-planning-ui/)

| ID | Screen | Assets | Implementation notes |
|----|--------|--------|----------------------|
| **F55** | Density → library drawer | [`f55-density-to-drawer.png`](../../design/stitch-assets/phase-planning-ui/f55-density-to-drawer.png) · [`f55-density-to-drawer.html`](../../design/stitch-assets/phase-planning-ui/f55-density-to-drawer.html) | Highest priority: `showAddExerciseToSupersetDialog` → `showExerciseLibraryPickPanel` (pick-only, `useRootNavigator`), add via `buildExerciseFromPrescription` + `supersetGroupId` + `defaultExerciseSetDetails()`. CTA label `builderDensityAddExercise`. |
| **F51** | Session editor mode | [`f51-sessione-editor-mode.png`](../../design/stitch-assets/phase-planning-ui/f51-sessione-editor-mode.png) · [`f51-sessione-editor-mode.html`](../../design/stitch-assets/phase-planning-ui/f51-sessione-editor-mode.html) | Optional `editorMode` / `planId` / `customerName` / `onLogSession` on session sheet: badge + Log session + History. Thread `editorCustomerName` from mobility / tabs config. |
| **F53** | Empty session day | [`f53-sessione-giorno-vuoto.png`](../../design/stitch-assets/phase-planning-ui/f53-sessione-giorno-vuoto.png) · [`f53-sessione-giorno-vuoto.html`](../../design/stitch-assets/phase-planning-ui/f53-sessione-giorno-vuoto.html) | Title `workoutBuilderSessionEmptyTitle` + empty-day CTA; day toolbar stays visible. |
| **F52** | Library drawer states | [`f52-drawer-libreria-stati.png`](../../design/stitch-assets/phase-planning-ui/f52-drawer-libreria-stati.png) · [`f52-drawer-libreria-stati.html`](../../design/stitch-assets/phase-planning-ui/f52-drawer-libreria-stati.html) | True empty → `exerciseLibraryEmpty` + hint + create CTA; search empty keeps `workoutBuilderCompactAddEmpty`. |
| **F50** | Density group manage | [`f50-density-group.png`](../../design/stitch-assets/phase-planning-ui/f50-density-group.png) · [`f50-density-group.html`](../../design/stitch-assets/phase-planning-ui/f50-density-group.html) | Light parity (F55 wiring + density add label). Full Stitch chrome deferred. |
| **F54** | Nested stack desktop | [`f54-nested-stack-desktop.png`](../../design/stitch-assets/phase-planning-ui/f54-nested-stack-desktop.png) · [`f54-nested-stack-desktop.html`](../../design/stitch-assets/phase-planning-ui/f54-nested-stack-desktop.html) | Reference only — no new UI. Nested navigators already correct (`useRootNavigator` on pick + create). |


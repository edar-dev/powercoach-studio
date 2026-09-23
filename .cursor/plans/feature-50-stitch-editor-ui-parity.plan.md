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
| A | Asset sync + Allenamento parity | asset ✅ · UI pending |
| B | Modale Modifica sessione | pending |
| C | Drawer libreria | pending |
| D | Modale crea esercizio | pending |
| E | Test + analyze | pending |

## Fuori scope

- Tab “Progressione & Carichi” (mock header Stitch)
- Gym mode / session log execution
- Cambio modello `Phase` / codec
- Font esterni non nel design system (`StitchM3Theme` tokens)

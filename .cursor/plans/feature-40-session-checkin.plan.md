---
name: feature-40-session-checkin
overview: "Wave 1 PR1 — Post-session check-in: sessionRpe, painLevel, painLocation su SessionExecution + UI session_log_sheet + diario."
todos:
  - id: model-codec
    content: "Estendere SessionExecution con sessionRpe/painLevel/painLocation; JSON additive + codec legacy"
    status: completed
  - id: log-sheet-ui
    content: "session_log_sheet — sezione RPE/pain dopo esercizi, prima note; opzionale su skip"
    status: completed
  - id: diary-display
    content: "Workout diary entry body — mostrare RPE/pain in read-only"
    status: completed
  - id: l10n-tests
    content: "l10n distinto da ExerciseSet.rpe; test codec round-trip + widget sheet"
    status: completed
isProject: false
---

# Feature 40 — Post-session check-in (RPE + pain)

## Obiettivo

Dopo la sessione, il coach registra **difficoltà percepita** e **dolore** in modo strutturato — distinto da RPE prescrittivo sui set.

## Modello

Estendere [`session_execution.dart`](../../lib/features/workouts/domain/session_execution.dart):

- `sessionRpe` (`int?` 1–10) — difficoltà sessione reale
- `painLevel` (`int?` 0–10)
- `painLocation` (`String?`)

## UI

- [`session_log_sheet.dart`](../../lib/features/workouts/presentation/widgets/session_log_sheet.dart): blocchi dopo lista esercizi, prima note libere
- Diario: entry body read-only

## Test

- Codec round-trip legacy senza campi
- Widget sheet
- Diary display

## Branch

`feat/identity-wave1-session-checkin`

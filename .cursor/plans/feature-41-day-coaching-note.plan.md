---
name: feature-41-day-coaching-note
overview: "Wave 1 PR2 — Day.coachingNote: campo opzionale per nota coaching di giorno in builder, follow-up e PDF."
todos:
  - id: model-codec
    content: "Aggiungere coachingNote su Day + workout_routine_json_codec; mutation + dirty snapshot"
    status: pending
  - id: builder-ui
    content: "Campo/expand in training_session_toolbar o day panel del builder"
    status: pending
  - id: export-readonly
    content: "Visibilità read-only + header day in PDF export se supportato"
    status: pending
  - id: tests
    content: "Test codec legacy, mutation, dirty, widget builder"
    status: pending
isProject: false
---

# Feature 41 — Day coaching notes

## Obiettivo

Ogni **giorno di scheda** può avere una nota coaching opzionale — contesto per il coach, preservata in follow-up e export.

## Modello

- Aggiungere `coachingNote` su [`Day`](../../lib/features/workouts/data/workout_routine_model.dart)
- Codec [`workout_routine_json_codec.dart`](../../lib/features/workouts/domain/workout_routine_json_codec.dart)

## UI

- Builder: campo nella session toolbar / foglio giorno
- Read-only dove il piano è visualizzato; header day in PDF se applicabile

## Test

- Codec legacy, mutation, dirty flag, widget builder

## Branch

`feat/identity-wave1-day-coaching-note`

## Dipendenze

Indipendente da F40; consigliato dopo F40 nel merge order.

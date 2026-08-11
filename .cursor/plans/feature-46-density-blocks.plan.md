---
name: feature-46-density-blocks
overview: "Wave 3 PR1 — Circuit/EMOM-lite via Day.densityBlocks keyed by existing supersetGroupId; builder + PDF/Excel labels; no Drift migration."
todos:
  - id: model-codec
    content: "DensityBlockConfig + Day.densityBlocks encode/decode; legacy absent = empty"
    status: completed
  - id: mutations-fingerprint
    content: "set/clear density block; clear orphan keys; dirty fingerprint"
    status: completed
  - id: builder-ui
    content: "New circuit/EMOM menu; panel heading; editor sheet fields"
    status: completed
  - id: export-l10n
    content: "PDF/Excel type-aware headers; ARB IT/EN; tests"
    status: completed
isProject: false
---

# Feature 46 — Circuit / EMOM-lite density blocks

## Obiettivo

Blocchi densità oltre i supersets: **circuit** (rounds + rest) e **EMOM-lite** (interval + duration), riusando `supersetGroupId` e `partitionExercisesBySuperset`.

## Modello (additive planData)

```json
"densityBlocks": {
  "ss_…": { "type": "circuit", "rounds": 3, "restSeconds": 90 },
  "ss_…": { "type": "emom", "intervalSeconds": 60, "durationMinutes": 12 }
}
```

- Assente / vuoto → comportamento superset attuale
- Nessuna migrazione Drift

## UI

- Menu esercizio: New circuit / New EMOM (oltre New supersets)
- Panel heading + subtitle metadata
- Editor sheet: type + campi rounds/rest o interval/duration

## Export

- PDF/Excel: label l10n `pdfCircuit` / `pdfEmom` (+ meta)
- Hevy: resta `superset_id` (follow-up note)

## Fuori scope

Timer gym mode, mapping Hevy nativo, rename globale partition helper.

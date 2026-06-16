---
name: feature-31-backup-restore-v2
overview: "Feature #8 v4 — Backup e restore migliorati: restore selettivo, preview contenuto, validazione envelope, test compatibilità versioni precedenti."
todos:
  - id: backup-preview
    content: Prima di import — schermata preview entità (N clienti, M piani, K esecuzioni sessione se presenti)
    status: pending
  - id: selective-restore
    content: Checkbox gruppi — clienti, piani, exercise library, reminders, pending ops (default tutto)
    status: pending
  - id: merge-strategy
    content: Import mode — replace all vs merge by id (merge aggiorna updatedAt più recente)
    status: pending
  - id: codec-v1-compat
    content: user_data_backup_codec — parse backup senza sessionExecutions, archivedAt, reminders
    status: pending
  - id: export-metadata
    content: Aggiungere exportedAt, appVersion, entityCounts in envelope (backward compat optional fields)
    status: pending
  - id: settings-ui
    content: Estendere settings_screen export/import flow con preview + conferma
    status: pending
  - id: tests
    content: Estendere user_data_backup_codec_test — minimal v1 payload, full v2 con executions
    status: pending
  - id: docs
    content: Aggiornare .cursor/rules/13-user-data-backup-json-compat.mdc se schema cambia
    status: pending
isProject: false
---

# Feature 31 — Backup / restore v2

## Obiettivo prodotto

Il backup v1 funziona per export/import completo.  
Con session executions (F24) e lifecycle markers, serve **controllo** e **merge** per evitare sovrascritture accidentali.

## Stato attuale

| Area | File |
|------|------|
| Codec | [`user_data_backup_codec.dart`](lib/core/backup/user_data_backup_codec.dart) |
| Service | `user_data_backup_service.dart` |
| UI | `settings_screen.dart` — export/import file |
| Test | `user_data_backup_codec_test.dart` |
| Regola | `.cursor/rules/13-user-data-backup-json-compat.mdc` |

Lifecycle markers (`archivedAt`, `completedAt`) già in planData — inclusi automaticamente.

## Design — Preview import

```
Backup del 15 giu 2026
· 12 clienti
· 34 piani workout
· 156 esecuzioni sessione
· 3 promemoria

[ ] Sostituisci tutti i dati (destructive)
[✓] Unisci per id (consigliato)

[ Importa ]
```

## Design — Merge by id

Per ogni entità nel backup:
- Se id assente localmente → insert
- Se id presente → keep entity con `updatedAt` più recente
- Pending ops — opzionale skip in merge (default import solo entities)

## Envelope v1.1 (compatibile)

```json
{
  "format": "powercoach_user_backup_v1",
  "schemaVersion": 1,
  "exportedAt": "2026-06-15T12:00:00.000Z",
  "appVersion": "1.2.0",
  "entityCounts": { "customers": 12, "workoutPlans": 34 },
  "entities": [ ... ],
  "pendingOperations": [ ... ]
}
```

Campi nuovi **opzionali** — parser v1 ignora.

## Dipendenze

- Feature-24 — `sessionExecutions` in planData (inclusi in export entities)
- Feature-30 opzione A — backup come path multi-device

## Test

- Backup minimal senza nuovi campi → import OK
- Backup con sessionExecutions → round-trip
- Merge: local newer wins

## Rischi

- **Destructive import** — richiedere conferma esplicita + digita "IMPORT"
- **Grandi file** — progress indicator su import

## Definition of done

- Preview prima di import
- Almeno merge by id funzionante
- Test compatibilità v1
- Regola compat aggiornata se necessario
- Analyze verde

## Branch suggerito

`feat/backup-restore-v2`

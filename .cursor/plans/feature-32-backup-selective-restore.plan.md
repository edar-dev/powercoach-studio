---
name: feature-32-backup-selective-restore
overview: "Feature #1 v5 — Completa F31: restore selettivo per gruppi entità, metadata envelope, test compatibilità."
todos:
  - id: envelope-metadata
    content: "Export — aggiungere exportedAt, appVersion, entityCounts opzionali in user_data_backup_codec (backward compat)"
    status: completed
  - id: selective-groups
    content: "Definire BackupEntityGroup enum — customers, workoutPlans, exerciseLibrary, reminders, preferences (default tutti on)"
    status: completed
  - id: preview-ui
    content: "Estendere BackupImportPreviewDialog — checkbox per gruppo + counts per gruppo"
    status: completed
  - id: merge-filter
    content: "UserDataBackupService.mergeRestore / restoreParsed — filtrare entities per gruppi selezionati"
    status: completed
  - id: settings-handler
    content: "settings_backup_handler — passare gruppi selezionati al restore"
    status: completed
  - id: tests
    content: "Estendere user_data_backup_codec_test + settings backup test — selective merge, v1 payload senza metadata"
    status: completed
  - id: docs
    content: "Aggiornare 13-user-data-backup-json-compat.mdc se entityCounts cambia shape"
    status: completed
isProject: false
---

# Feature 32 — Backup selettivo e metadata

## Obiettivo prodotto

Completare il residuo di **F31**: il coach può importare **solo** clienti, o solo piani, evitando sovrascritture indesiderate della library esercizi. L'envelope export include metadata leggibile in preview.

## Stato attuale (post-v4)

| Già fatto | Manca |
|-----------|--------|
| Preview counts (clienti, piani, esecuzioni) | Checkbox gruppi entità |
| Merge by id vs replace all | Filtro merge per tipo entità |
| Conferma digita IMPORT per replace | `exportedAt` / `entityCounts` in export |
| `settings_backup_handler.dart` | Wiring selective groups |

File chiave: [`user_data_backup_codec.dart`](lib/core/backup/user_data_backup_codec.dart), [`settings_backup_handler.dart`](lib/features/settings/presentation/settings_backup_handler.dart), [`backup_import_preview_dialog.dart`](lib/features/settings/presentation/widgets/backup_import_preview_dialog.dart).

## Design — Preview import esteso

```
Backup del 8 lug 2026 · app 1.x
[✓] Clienti (12)
[✓] Piani workout (34)
[ ] Libreria esercizi (156)
[✓] Promemoria (3)

Merge per id  ·  Replace all (destructive)
[ Importa ]
```

## Regole merge selettivo

- Gruppo deselezionato → entità di quel tipo **ignorate** in import (locali intatte).
- Merge by id: stessa logica `updatedAt` per entità importate.
- Replace all: richiede conferma IMPORT (invariato); gruppi deselezionati = quelli **sostituiti** solo se replace (specificare in UI).

## Dipendenze

- F31 parziale (preview + merge già in main)
- [`docs/sync-strategy.md`](../../docs/sync-strategy.md) — backup = path multi-device ufficiale

## Test

- `test/core/backup/user_data_backup_codec_test.dart`
- `test/features/settings/settings_screen_backup_test.dart`

## Rischi

- **Mapping entity type → group** — allineare con `OfflineEntity` / backup entity `type` field
- **UX confusione** merge + partial groups — copy chiaro in IT/EN

## Definition of done

- Almeno 3 gruppi selezionabili (clienti, piani, library)
- Export include `exportedAt` (ISO8601)
- Test selective merge
- Analyze verde

## Branch suggerito

`feat/backup-selective-restore`

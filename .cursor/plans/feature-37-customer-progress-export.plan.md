---
name: feature-37-customer-progress-export
overview: "Feature #6 v5 — Export/share riepilogo progresso cliente (aderenza, PR, misure)."
todos:
  - id: export-service
    content: "customer_progress_export_service.dart — build CSV e/o PDF da CustomerProgressPanel data"
    status: completed
  - id: csv-format
    content: "CSV — sezioni aderenza, sessioni recenti, PR, misure (header + rows)"
    status: completed
  - id: pdf-optional
    content: "PDF leggero via printing package OPPURE solo CSV MVP — decidere in implementazione (stop se nuova dep)"
    status: completed
  - id: ui-action
    content: "Customer detail overview — IconButton share/export accanto a progress panel"
    status: completed
  - id: share-plus
    content: "share_plus — share file temporaneo con nome cliente + data"
    status: completed
  - id: l10n
    content: "customerProgressExport, customerProgressExportSuccess, customerProgressExportFailed"
    status: completed
  - id: tests
    content: "Unit test export service — fixture progress snapshot → CSV string expected"
    status: completed
isProject: false
---

# Feature 37 — Export progresso cliente

## Obiettivo prodotto

Il coach condivide con il cliente (WhatsApp, email) un **riepilogo strutturato** di aderenza, PR e misure — senza sync cloud.

## Stato attuale

| Esiste | Manca |
|--------|--------|
| [`customer_progress_panel.dart`](lib/features/customers/presentation/widgets/customer_progress_panel.dart) | Export/share |
| [`customer_progress_loader.dart`](lib/features/customers/domain/customer_progress_loader.dart) | Serializer export |
| Measurement history export (parziale altrove) | Narrativa unificata per cliente |

## Design — Export trigger

Da customer detail → tab Overview:

```
[Progress panel header]  [Share ↗]
```

## Formato CSV (MVP)

```csv
# PowerCoach Studio — Progresso Marco Rossi
# Generato: 2026-07-08

section,adherence_7d,adherence_30d
summary,0.85,0.72

section,exercise,load,date
pr,Panca piana,80kg,2026-07-01

section,measurement,value,date
measures,Peso,78.5,2026-07-05
```

## PDF (stretch)

Solo se `printing` già in pubspec o approvazione nuova dependency. Altrimenti **CSV-only** per v5.

## Dipendenze

- F26 — progress panel data
- F27 — PR da session log (F35 arricchisce qualità export)

## Test

- `test/features/customers/customer_progress_export_service_test.dart`

## Rischi

- **PII** — filename sanitizzato; no email in export unless in customer record (opt-in)
- **Large history** — limitare ultime N sessioni / misure in export

## Definition of done

- Share CSV funzionante da customer detail
- i18n IT/EN
- Unit test export
- Analyze verde

## Branch suggerito

`feat/customer-progress-export`

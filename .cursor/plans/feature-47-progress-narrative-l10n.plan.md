---
name: feature-47-progress-narrative-l10n
overview: "Wave 3 PR2 — Locale-aware narrative block atop customer progress CSV (IT/EN); keep machine CSV section."
todos:
  - id: narrative-builder
    content: "customer_progress_narrative + export labels DTO / l10n wiring"
    status: completed
  - id: csv-layout
    content: "Prepend narrative + localized header/weekly labels; fallback English keys"
    status: completed
  - id: arb-tests
    content: "ARB IT/EN templates; export service tests for it/en"
    status: completed
isProject: false
---

# Feature 47 — Progress narrative export (multi-locale)

## Obiettivo

Blocco narrativo human-readable in cima al CSV progresso cliente (WhatsApp/email coach→cliente), in **locale app** (IT/EN), senza cambiare la sezione machine CSV.

## Layout CSV

```
# {title} — {customerName}
# {generatedOn}: {date}
#
{narrative sentences}
#
# --- data ---
{existing structured rows}
```

## Template ARB

- Summary adherence + completed/skipped
- Last session
- Optional recent PR
- Weekly completed/missed labels when labels present

## Fuori scope

PDF progresso, full column localization, customer-locale vs coach-locale.

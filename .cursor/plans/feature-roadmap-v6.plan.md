---
name: feature-roadmap-v6
overview: "Roadmap v6 — polish prodotto e trasparenza release: release notes in-app, processo changelog, eventuali miglioramenti post-v5."
todos:
  - id: release-notes-screen
    content: "Implementare feature-39-release-notes-screen.plan.md"
    status: completed
isProject: false
---

# Roadmap v6 — Trasparenza release e polish

## Tesi

La **v5** ha completato profondità coach (backup selettivo, diario/stats, session log, superset, export progresso, discoverability hub).  
La **v6** parte dal **polish user-facing**: far scoprire e documentare il valore già rilasciato, con processo chiaro per ogni bump di versione.

Non riapre sync cloud né grandi feature dati — focus su UX, comunicazione, manutenibilità release.

## Scope

| # | Feature | Piano | Priorità |
|---|---------|-------|----------|
| 1 | Release notes screen + storico retroattivo | [feature-39](feature-39-release-notes-screen.plan.md) | Alta |

## Wave unica (1 PR)

- **39**: schermata statica, catalogo 1.0.1–1.0.7, entry Impostazioni, l10n IT/EN, test

## Processo release (post-implementazione)

Ad ogni bump `pubspec.yaml`:

1. Aggiungere entry in `kReleaseNotesCatalog`
2. Aggiungere bullet l10n IT/EN
3. Allineare `kAppVersionLabel`
4. Copiare sintesi in Play Store / release GitHub (se applicabile)

Documentare step 1–4 in `docs/play-store-release-guide.md` (follow-up opzionale nel PR feature-39).

## Definition of done roadmap

- Feature 39 mergiata su `main`
- Coach può aprire Novità da Impostazioni e vedere storico completo

## Branch suggerito

`feat/release-notes-screen`

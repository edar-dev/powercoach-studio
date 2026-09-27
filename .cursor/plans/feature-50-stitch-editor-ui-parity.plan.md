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

Auth dark Stitch (login/register): [`design/stitch-assets/auth/`](../../design/stitch-assets/auth/) — `login-dark.html` / `login-dark.png` (`75b281a64afc47fbb12b7e07fbd342ab`), `register-dark.html` / `register-dark.png` (`3048409cc4154aa891fe1c5cfc264fd9`).

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

## Exercise Library screen (Stitch)

Asset folder: [`design/stitch-assets/exercise-library/`](../../design/stitch-assets/exercise-library/)

| Screen | Assets | Notes |
|--------|--------|-------|
| Libreria esercizi — ricerca / cartelle | [`libreria-esercizi-ricerca-cartelle.png`](../../design/stitch-assets/exercise-library/libreria-esercizi-ricerca-cartelle.png) · [`libreria-esercizi-ricerca-cartelle.html`](../../design/stitch-assets/exercise-library/libreria-esercizi-ricerca-cartelle.html) | Header counts, search + sort (alpha / variant count), folder cards with variant chips, ⌘K focus on tablet+, dual FAB (Nuova cartella = same create dialog). **Deferred:** muscle-group / equipment filter chips (no schema; name heuristics would be fake). |

## Coach Dashboard redesign (Stitch)

Asset folder: [`design/stitch-assets/dashboard/`](../../design/stitch-assets/dashboard/)

| Screen | Assets | Notes |
|--------|--------|-------|
| Dashboard Coach redesign | [`dashboard-coach-redesign.png`](../../design/stitch-assets/dashboard/dashboard-coach-redesign.png) · [`dashboard-coach-redesign.html`](../../design/stitch-assets/dashboard/dashboard-coach-redesign.html) | Hero KPI strip (`clientCount` / `activePrograms` / `weeklyUpdates` / attention count), Oggi empty+agenda CTA, positive empties for attention / no-plan / stale, management shortcuts, offline-first footer. **Not claimed:** Cloud Sync OK / fake 30d session KPI. |
| Dashboard — Dialog Proteggi i tuoi dati & Avviso Backup | [`backup-protect-dialogs.png`](../../design/stitch-assets/dashboard/backup-protect-dialogs.png) · [`backup-protect-dialogs.html`](../../design/stitch-assets/dashboard/backup-protect-dialogs.html) (screen `e36294eb80f64f26bf3044af77780a3b`) | Custom dark data-protection modal (`backup_onboarding_dialog.dart`) + teal backup reminder banner (`backup_reminder_banner.dart`). **Product-accurate:** Offline-First + JSON backup / desk→gym; no automatic Cloud Sync claims. |

## Customers (Stitch dark)

Asset folder: [`design/stitch-assets/customers/`](../../design/stitch-assets/customers/)

| Screen | Assets | Notes |
|--------|--------|-------|
| Customers empty list | [`customers-empty-dark.html`](../../design/stitch-assets/customers/customers-empty-dark.html) · [`customers-empty-dark.png`](../../design/stitch-assets/customers/customers-empty-dark.png) (screen `21fa4ca96f9645c980179709a2091c48`) | Dark empty (`#080c14`), concentric person-add graphic, onboarding step cards, Offline-First footer. App keeps AppBar + drawer (no Stitch marketing top nav). Toolbar: search + Tutti/Attivi/In pausa/Da assegnare + Nuovo cliente. |
| Customers populated list | [`customers-populated-dark.html`](../../design/stitch-assets/customers/customers-populated-dark.html) · [`customers-populated-dark.png`](../../design/stitch-assets/customers/customers-populated-dark.png) (screen `8b0142f2d2054edb8245ce674b66a129`) | Metrics bar (totale / schede / in pausa / da aggiornare — **no** fake check-in %), richer rows (avatar, goals, last plan update, status pills, quick actions), sort “Più recenti”, footer “Mostrati X di Y”. **Not claimed:** mesocycle phase names, progress %, last workout logs/RPE, weekly check-in completion. |
| New customer | [`new-customer-dark.html`](../../design/stitch-assets/customers/new-customer-dark.html) · [`new-customer-dark.png`](../../design/stitch-assets/customers/new-customer-dark.png) (screen `9cdeb5f67c664f10a27440d53e39745a`) | Dark form sections (anagrafica / fisici / obiettivi), goal chips, experience → notes, local-data hint (**not** cloud sync). Save → PlanGate + `/customers/:id`. |
| Customer detail overview | [`customer-overview-dark.html`](../../design/stitch-assets/customers/customer-overview-dark.html) · [`customer-overview-dark.png`](../../design/stitch-assets/customers/customer-overview-dark.png) (screen `5b17b75938db4e669576b3b769fd819b`) | Dark shell `#080c14`, back “Torna ai clienti”, Attivo badge + short ID, hero (avatar/initials, goal, age/email/phone, journey start + last check-in only when real), CTAs Assegna/Modifica, biometric KPI cards (peso / massa muscolare / BF% / SBD), progress + plans restyled. Notes stay in overflow (no 5th tab). **Not claimed:** Cloud Sync, fake frequenza sedute, marketing top nav. |
| Measures & history | [`measures-history-dark.html`](../../design/stitch-assets/customers/measures-history-dark.html) · [`measures-history-dark.png`](../../design/stitch-assets/customers/measures-history-dark.png) (screen `b0c9c655c68c4d52b35459dce722183d`) | Measurements tab + history: metric dropdown, 30d/3m/6m/all pills, current value + dark chart, dark measurement cards, full history route. |
| Edit measure / 1RM modal | [`edit-measure-1rm-modal-dark.html`](../../design/stitch-assets/customers/edit-measure-1rm-modal-dark.html) · [`edit-measure-1rm-modal-dark.png`](../../design/stitch-assets/customers/edit-measure-1rm-modal-dark.png) (screen `a11a05769ae54a47b509cda6282b8889`) | Dialog-like dark form (wide) / full-screen (narrow): date + Oggi, 1RM cards with real deltas vs previous, SBD total when all three present, body comp, notes. **Not claimed:** DOTS/Wilks. |

## Public Landing (Stitch)

Asset folder: [`design/stitch-assets/landing/`](../../design/stitch-assets/landing/)

| Screen | Assets | Notes |
|--------|--------|-------|
| Landing Page Redesign Dark Theme | [`landing-dark-theme.html`](../../design/stitch-assets/landing/landing-dark-theme.html) · [`landing-dark-theme.png`](../../design/stitch-assets/landing/landing-dark-theme.png) (project `14496212854931615246`, screen `8f70bab127c04f47b18d30a213463c57`) | **Source of truth.** Full-page dark (`#090d16`), sticky header + pill nav, hero + trust row + app preview, 4 rich feature cards, periodization banner, CTA. Status chip: **Offline-First** (not Cloud Sync). Catalog trust: **266+**. |
| Landing first viewport (partial) | [`w8-landing.png`](../../design/stitch-assets/landing/w8-landing.png) (Stitch screen `8807023090542286040`) | Light/partial export only — do not treat as canonical. |



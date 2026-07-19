---
name: workout-builder-ux-phase3-advanced
overview: "Fase 3 — Esperienza avanzata: undo esteso, onboarding, layout desktop, modalità palestra, wizard, varianti builder, polish diario/PDF (WB-13 … WB-22)."
todos:
  - id: wb13-extended-undo
    content: "WB-13 — Snackbar undo per delete week, unlink superset, delete mobility item (pattern removeExercise)"
    status: pending
  - id: wb14-onboarding
    content: "WB-14 — First-run checklist 3 step in builder (SharedPreferences flag) + l10n dismiss"
    status: pending
  - id: wb15-desktop-two-pane
    content: "WB-15 — TrainingWeekDayPanel: Breakpoints.isDesktop → week list fixed + day editor scroll"
    status: pending
  - id: wb16-gym-compact-add
    content: "WB-16 — Modalità compatta add exercise: sheet ridotto, recenti+pin, 1 tap add con serie default"
    status: pending
  - id: wb17-new-plan-wizard
    content: "WB-17 — Wizard opzionale post WB-06: nome → settimane → giorni/settimana → preset split"
    status: pending
  - id: wb18-builder-variants
    content: "WB-18 — Rimuovere route orfane multiset/superset OPPURE menu Impostazioni builder 'Includi mobilità'"
    status: pending
  - id: wb19-pdf-preview
    content: "WB-19 — Anteprima PDF in editor prima di export (web: iframe/pdf viewer)"
    status: pending
  - id: wb20-training-history-link
    content: "WB-20 — Da header giorno: link storico esecuzioni diario filtrato plan+session"
    status: pending
  - id: wb22-diary-pagination
    content: "WB-22 — WorkoutDiaryScreen: load by plan/customer paginato vs listAll()"
    status: pending
  - id: wb-phase3-qa
    content: "QA checklist + test regressione su mobile 390px e desktop 1200px"
    status: pending
isProject: false
---

# Workout Builder UX — Fase 3: Advanced

## Obiettivo prodotto

Ottimizzare l’esperienza per **coach in palestra** (mobile, pochi tap) e **coach al desk** (web/tablet, layout largo). Polish e performance di lungo periodo.

**Prerequisito:** [Fase 2](workout-builder-ux-phase2-coach-flow.plan.md) completata (minimo WB-06, WB-08, WB-09).

**Nota:** items in fase 3 sono **indipendenti** — prioritizzare in base a feedback coach reali post fase 1–2.

---

## WB-13 — Undo esteso (P2 · M)

### Scope

Replicare pattern in `WorkoutBuilderTrainingHandlers.removeExercise`:

| Azione | Undo restore |
|--------|--------------|
| Delete week | Ripristina week in routine |
| Unlink superset | Re-link group |
| Delete mobility item | Re-insert item |

SnackBar 5s + action `workoutBuilderUndo`.

### File

- `workout_builder_training_handlers.dart`
- `workout_builder_mobility_handlers.dart`
- `workout_superset_actions.dart`

### Branch

`feat/workout-extended-undo`

---

## WB-14 — Onboarding first-run (P2 · M)

### Design

Card dismissibile in cima al builder (solo prima occorrenza):

1. Scegli settimana e giorno  
2. Aggiungi esercizi  
3. Imposta date in Dettagli per il calendario  

Flag: `workout_builder_onboarding_dismissed` in SharedPreferences (per userId).

### File

- Nuovo `workout_builder_onboarding_card.dart`
- `workout_builder_editor_shell.dart`
- `core/settings/settings_prefs_keys.dart`
- `app_*.arb`

### Branch

`feat/workout-builder-onboarding`

---

## WB-15 — Layout desktop two-pane (P2 · L)

### Design

```
┌──────────────┬─────────────────────────────┐
│ Settimane    │  Giorno 3 — Mercoledì       │
│ ■ Sett 1     │  [esercizi…]                │
│   Sett 2     │                             │
│   Sett 3     │                             │
└──────────────┴─────────────────────────────┘
```

Breakpoint: riusare pattern `Breakpoints` da `core/ui` se presente, altrimenti `>= 900` logical px.

### File

- `training_week_day_panel.dart`
- `training_week_selector_row.dart` / `training_day_selector_row.dart` — adattare layout

### Rischi

- Stato selezione week/day su resize
- Test widget desktop width

### Branch

`feat/workout-builder-desktop-layout`

---

## WB-16 — Modalità compatta aggiunta esercizio (P2 · L)

### Problema

Sheet full-screen + set editor = troppi tap tra le serie in palestra.

### Design

Toggle in builder (o auto on mobile width):

- Lista compatta: recenti + pin + search 1 riga
- Tap exercise → aggiunge con **serie default** (3×10 o ultimo usato per quell’esercizio)
- Link “Modifica prescrizione” apre editor completo

### File

- `exercise_add_sheet.dart` / `exercise_add_sheet_content.dart`
- Nuovo `exercise_add_compact_sheet.dart` (opzionale)
- `UserPreferencesRepository` — preferenza modalità

### Metriche

- Target: −20% tap per aggiungere esercizio standard

### Branch

`feat/workout-gym-compact-add`

---

## WB-17 — Wizard nuova scheda (P2 · L)

### Problema

Coach principianti non sanno ordine settimana → giorno → esercizio → date.

### Design

Opzionale dopo WB-06 sheet (“Guida guidata”):

| Step | Input |
|------|-------|
| 1 | Nome piano |
| 2 | Numero settimane |
| 3 | Giorni per settimana (3/4/6) |
| 4 | Preset split (Full body / Upper-Lower / PPL) — genera giorni vuoti nominati |

Output: routine skeleton → editor normale.

### File

- Nuovo `workout_new_plan_wizard.dart`
- Domain helper `workout_split_presets.dart`
- Integrazione `customer_new_workout_sheet.dart`

### Branch

`feat/workout-new-plan-wizard`

---

## WB-18 — Varianti builder (P3 · S–M)

### Opzione A — Rimuovere dead routes

Eliminare da `app_routes.dart`:

- `/workouts/builder/multiset`
- `/workouts/builder/superset`
- `/workouts/builder/intuitive-superset`

Aggiornare test redirect.

### Opzione B — Esporre in UI

Toggle in Dettagli builder: **“Includi tab Mobilità”** → set variant mobility vs training-only (query `?mobility=0`).

**Raccomandazione:** Opzione B minimal (1 toggle) > route orfane.

### Branch

`chore/workout-builder-variant-cleanup` o `feat/workout-mobility-toggle`

---

## WB-19 — Anteprima PDF (P3 · M)

### Scope

Prima di export PDF da `WorkoutBuilderExportActions`, dialog preview (web: blob URL / print preview).

Mobile: share sheet esistente sufficiente — preview web-only ok.

### File

- `workout_builder_export_actions.dart`
- `core/ui/widgets/pdf_export_progress_dialog.dart`

### Branch

`feat/workout-pdf-preview`

---

## WB-20 — Storico esecuzioni da Training (P3 · M)

### Design

Link su header giorno: “Vedi storico” → `/workouts/diary?planId=&sessionKey=` o entry list filtrata.

Richiede mapping week/day → sessionKey (schedule service).

### File

- `training_week_day_panel.dart`
- `workout_diary_screen.dart` — query filter

### Branch

`feat/workout-day-execution-history`

---

## WB-22 — Paginazione diario (P3 · M)

### Problema

`WorkoutDiaryEntryScreen` / list usa `listAll()` — scala male.

### Soluzione

Repository method `listEntries({planId, limit, offset})` + infinite scroll o pagination.

### File

- Workout diary repository / loader
- `workout_diary_screen.dart`
- `coach_stats_loader.dart` se condiviso

### Branch

`perf/workout-diary-pagination`

---

## Priorità consigliata dentro fase 3

| Priorità | ID | Motivo |
|----------|-----|--------|
| 1 | WB-16 | Impatto palestra diretto |
| 2 | WB-14 | Riduce abbandono nuovi coach |
| 3 | WB-13 | Affidabilità per edit distruttivi |
| 4 | WB-15 | Coach web/desk |
| 5 | WB-17 | Onboarding strutturato |
| 6 | WB-18 | Pulizia prodotto |
| 7 | WB-19, WB-20, WB-22 | Nice to have |

## Definition of done fase 3

- Item prioritizzati implementati e mergiati
- Metriche tap/tempo (se strumentate) revisionate
- Roadmap todo `phase3-advanced` → completed o parziale con note

## Dipendenze esterne

- Nessuna API remota
- Eventuale overlap con [presentation-split-v*](presentation-split-v1.plan.md) — coordinare refactor file >300 righe prima di WB-16/WB-17

# Workout Builder — Analisi UX / prodotto

> Documento di riferimento per coach flow, attriti e backlog miglioramenti.  
> Aggiornato: 2026-07-19 · Collegato a [workout-builder-ux-roadmap.plan.md](../.cursor/plans/workout-builder-ux-roadmap.plan.md)

---

## Contesto

PowerCoach Studio è **Italian-first**, tema scuro, uso in palestra. I dati workout sono **local-first** (Drift), scoped per utente autenticato. Il builder è implementato come **un solo screen** (`WorkoutBuilderMobilityScreen`) con varianti di routing, non quattro app separate.

QA manuale: [workout-builder-qa-checklist.md](./workout-builder-qa-checklist.md).

---

## Flusso coach attuale

### Percorso A — Assegnare piano al cliente (primario)

| Step | Dove | Cosa succede |
|------|------|--------------|
| 1 | `/customers` | Coach apre un cliente |
| 2 | `/customers/:id` | Overview: `CustomerDetailWorkoutPlansSection` |
| 3 | Tap **Assegna workout** | `openCustomerWorkoutEditor()` → `/customers/:id/workouts/new` |
| 4 | `WorkoutBuilderMobilityScreen` (`editorMode: true`) | Routine vuota; tab **Training** |
| 5 | Primo **Save** (app bar) | Crea piano in DB; URL → `/customers/:id/workouts/:planId` |
| 6 | Modifiche successive | Autosave debounce 2.5s **solo se `loadedPlanId != null`** |
| 7 | Tab **Dettagli** | Date, settimana iniziale, fase/tag/note → calendario |
| 8 | Tab **Mobilità** | Warm-up / mobilità (`WorkoutMobilityTab`) |
| 9 | Indietro | Dialog uscita non salvata → `/customers/:id/workouts` |

Altre entry sullo stesso cliente: tile piano recente; **Vedi tutti** → `CustomerWorkoutsScreen` (search, filtri, FAB, menu azioni).

### Percorso B — Template → cliente

| Step | Dove | Cosa succede |
|------|------|--------------|
| 1 | `/workouts/templates` | Libreria template |
| 2 | Preview → **Assegna** | Dialog cliente + data inizio |
| 3 | `duplicateToCustomer` | Snackbar; **non** apre editor |
| 4 | Coach cerca piano sotto cliente | Nessun deep link al piano creato |

### Percorso C — Builder standalone (non legato al cliente)

| Step | Dove | Cosa succede |
|------|------|--------------|
| 1 | Dashboard drawer / footer → `/workouts/builder` | Sandbox |
| 2 | Draft | `SharedPrefsWorkoutDraftStore` |
| 3 | Save | SharedPreferences; export PDF/JSON/Excel/Hevy |
| 4 | Indietro | Esce a `/dashboard` (web URL sync) |

### Percorso D — Piano → esecuzione → diario

Calendario / schedule → azioni sessione → `showSessionLogSheet` → `/workouts/diary` (+ entry detail).  
**Assegnare un piano non crea voci diario** finché le sessioni non sono loggate.

---

## Architettura UI (mappa)

```
Entry points
├── CustomerDetailOverviewTab / CustomerWorkoutsScreen
│     → customerWorkoutEditorPath → WorkoutBuilderMobilityScreen
├── Dashboard → /workouts/builder (standalone)
├── WorkoutPlanTemplatesScreen → assign (no editor)
└── Route orfane: /workouts/builder/{multiset|superset|intuitive-superset}

WorkoutBuilderMobilityScreen
└── WorkoutBuilderEditorShell
      ├── WorkoutEditorAppBar (save, export, back)
      ├── TabBar: Training | [Mobilità] | Dettagli
      └── WorkoutLazyTab bodies

Training tab
└── TrainingWeekDayPanel → WorkoutDayExerciseList
      ├── WorkoutExerciseCard
      └── WorkoutSupersetBlock → panel / editor sheet
```

### Varianti builder (`WorkoutBuilderVariant`)

| Variante | Route | Differenza runtime |
|----------|-------|-------------------|
| mobility | customer routes, `/workouts/builder` | 3 tab (Training + Mobilità + Dettagli) |
| multiset / superset / intuitiveSuperset | sotto-route `/workouts/builder/*` | Tab Mobilità nascosto |

**Nota:** le varianti non sono linkate da UI in-app. Superset behavior è condiviso via `WorkoutSupersetBlock` su tutte le varianti. Assegnazione cliente usa **sempre** `mobility`.

---

## Punti di forza

1. CTA chiara per assegnazione piano (overview + FAB lista piani)
2. Gestione piani ricca: duplica, follow-up, template, archivia, completa, filtri
3. Integrazione calendario su tile (`PlanScheduleStrip`, long-press sessioni)
4. Autosave + chip stato save (saved / unsaved / saving / failed + retry)
5. Guard uscita con dialog a tre vie (cancel / discard / save)
6. Aggiunta esercizi: libreria, recenti, pin, storico carichi, % max
7. Tooling superset (gruppi, editor sheet, assign da card)
8. Diario collegato a editor e schedule
9. Undo su delete esercizio (SnackBar)
10. i18n IT/EN orientato al coach

---

## Attriti e debolezze

### Journey e modello mentale

| # | Problema | Dettaglio |
|---|----------|-----------|
| 1 | **Gap primo save** | Autosave richiede `loadedPlanId`; piano nuovo a rischio perdita dati |
| 2 | **Follow-up incoerente** | Overview crea piano vuoto; lista piani usa dialog con carichi eseguiti |
| 3 | **Template assign dead-end** | Nessun “Apri piano” post-assegnazione |
| 4 | **Standalone vs cliente** | Dashboard → sandbox; coach crede di aver assegnato al cliente |
| 5 | **Workout non in tab cliente** | Solo overview (max 5 piani); lista completa richiede tap extra |

### Builder e interazione

| # | Problema | Dettaglio |
|---|----------|-----------|
| 6 | **Varianti fantasma** | Route multiset/superset/intuitive senza link UI |
| 7 | **Profondità tap mobile** | Sheet add → dialog edit → dialog set |
| 8 | **Log sessione fuori builder** | Solo da calendario/schedule |
| 9 | **Layout web** | Nessun two-pane; chip orizzontali |

### Affidabilità e stati

| # | Problema | Dettaglio |
|---|----------|-----------|
| 10 | **Errori silenziosi** | Archive/complete/load diary/overview senza feedback |
| 11 | **Empty day minimale** | Solo testo count=0, FAB facile da perdere |
| 12 | **Piani archiviati editabili** | Nessuna read-only |
| 13 | **Strip calendario vuota** | `SizedBox.shrink()` senza hint “imposta data” |
| 14 | **Undo limitato** | Solo delete esercizio |
| 15 | **Nessuna onboarding** | Primo utilizzo senza guida |

---

## Backlog completo (impatto · priorità · costo)

**Costo:** S = 0.5–1 gg · M = 2–4 gg · L = 1–2 sett · XL = 2+ sett  
**Priorità:** P0 critico · P1 alto · P2 medio · P3 basso

| ID | Miglioramento | Impatto | P | Costo | Fase |
|----|---------------|---------|---|-------|------|
| WB-01 | Autosave / save al primo edit | Alto | P0 | M | 1 |
| WB-02 | Unificare follow-up overview ↔ lista | Alto | P1 | S | 1 |
| WB-03 | Post-template → “Apri piano” | Alto | P1 | S | 1 |
| WB-04 | Empty day CTA inline | Medio | P1 | S | 1 |
| WB-05 | Feedback errori silenziosi | Medio | P1 | S | 1 |
| WB-06 | FAB nuovo piano: vuoto / template / duplica | Alto | P1 | M | 2 |
| WB-07 | Chiarire builder standalone (sandbox + CTA assign) | Alto | P1 | M | 2 |
| WB-08 | Tab Workout su dettaglio cliente | Medio | P1 | M | 2 |
| WB-09 | Log sessione dal builder | Alto | P2 | M | 2 |
| WB-10 | Duplica giorno / settimana | Alto | P2 | M | 2 |
| WB-11 | Read-only piani archiviati/completati | Medio | P2 | M | 2 |
| WB-12 | Strip calendario → hint data inizio | Medio | P2 | S | 2 |
| WB-13 | Undo esteso (settimana, superset, mobilità) | Medio | P2 | M | 3 |
| WB-14 | Onboarding first-run checklist | Medio | P2 | M | 3 |
| WB-15 | Layout desktop two-pane | Medio | P2 | L | 3 |
| WB-16 | Modalità compatta aggiunta esercizio (palestra) | Alto | P2 | L | 3 |
| WB-17 | Wizard nuova scheda guidata | Alto | P2 | L | 3 |
| WB-18 | Rimuovere o esporre varianti builder | Basso | P3 | S–M | 3 |
| WB-19 | Anteprima PDF in editor | Medio | P3 | M | 3 |
| WB-20 | Storico esecuzioni da tab Training | Medio | P3 | M | 3 |
| WB-21 | Test E2E journey cliente | Medio | P2 | M | 2 |
| WB-22 | Paginazione diario | Basso | P3 | M | 3 |

---

## Fasi di implementazione (sintesi)

| Fase | Obiettivo | Durata stimata | PR |
|------|-----------|----------------|-----|
| **1 — Trust** | Fiducia, coerenza, zero perdita dati | ~1 settimana | 2–3 |
| **2 — Coach flow** | Percorso cliente più lineare | ~2–3 settimane | 4–5 |
| **3 — Advanced** | Mobile palestra, desktop, onboarding | backlog | 5+ |

Dettaglio: piani in `.cursor/plans/workout-builder-ux-phase*.plan.md`.

---

## Metriche suggerite

| Metrica | Baseline | Target post-fase 1–2 |
|---------|----------|----------------------|
| Piani abbandonati senza save | da misurare | → 0 |
| Tempo creazione prima scheda | da misurare | −30% |
| Tap medi per aggiungere esercizio | da misurare | −20% (fase 3) |
| Template assign → edit < 1 min | basso | +50% |

---

## File chiave (riferimento implementazione)

| Area | File |
|------|------|
| Builder screen | `lib/features/workouts/presentation/screens/workout_builder_mobility_screen.dart` |
| Save / autosave | `lib/features/workouts/presentation/workout_editor_controller.dart` |
| Exit guard | `lib/features/workouts/presentation/workout_builder_editor_exit.dart` |
| Customer assign | `lib/features/customers/presentation/screens/customer_workouts_screen.dart` |
| Overview piani | `lib/features/customers/presentation/widgets/customer_detail_workout_plans_section.dart` |
| Templates | `lib/features/workouts/presentation/screens/workout_plan_templates_screen.dart` |
| Training UI | `lib/features/workouts/presentation/widgets/training_week_day_panel.dart` |
| Session log | `lib/features/workouts/presentation/widgets/session_log_sheet.dart` |
| Routing | `lib/core/routing/app_routes.dart`, `app_navigation.dart` |

---

## Conclusione

Il loop **cliente → piano → calendario → diario** è solido; i gap più costosi sono **primo save/autosave**, **incoerenza follow-up**, **dead-end template**, e **confusione sandbox vs cliente**. Le fasi 1–2 offrono il miglior ROI prima di investire in wizard o layout desktop.

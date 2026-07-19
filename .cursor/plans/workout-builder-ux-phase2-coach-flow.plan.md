---
name: workout-builder-ux-phase2-coach-flow
overview: "Fase 2 — Flusso coach: scelta nuovo piano, sandbox chiara, tab Workout cliente, log sessione in builder, duplica giorno/settimana, read-only, hint calendario, test E2E (WB-06 … WB-12, WB-21)."
todos:
  - id: wb06-new-plan-picker
    content: "WB-06 — CustomerWorkoutsScreen FAB + overview assign: sheet Vuoto / Da template / Duplica piano esistente"
    status: completed
  - id: wb07-sandbox-label
    content: "WB-07 — Standalone builder: banner 'Bozza locale', rename drawer copy, CTA 'Assegna a cliente' (picker cliente → duplicate/import)"
    status: completed
  - id: wb08-customer-workout-tab
    content: "WB-08 — CustomerDetailScreen: tab Workout con CustomerWorkoutsScreen body embedded o route nested /customers/:id/workouts as tab"
    status: completed
  - id: wb09-session-log-builder
    content: "WB-09 — TrainingWeekDayPanel header o Dettagli: azione 'Registra sessione' → showSessionLogSheet per week/day corrente"
    status: completed
  - id: wb10-duplicate-day-week
    content: "WB-10 — Duplica struttura giorno → altro giorno; duplica settimana intera (menu settimana + confirm dialog)"
    status: completed
  - id: wb11-readonly-archived
    content: "WB-11 — WorkoutBuilderMobilityScreen: se plan archived/completed → banner + disable FAB/mutations (view-only export ok)"
    status: completed
  - id: wb12-schedule-strip-hint
    content: "WB-12 — PlanScheduleStrip: se events empty → testo + tap apre Dettagli o date picker"
    status: completed
  - id: wb21-e2e-journey-test
    content: "WB-21 — Widget/integration test: customer → new plan → save → loadedPlanId → optional schedule marker"
    status: completed
  - id: wb-phase2-qa
    content: "flutter analyze + test + QA checklist responsive pass"
    status: completed
isProject: false
---

# Workout Builder UX — Fase 2: Coach Flow

## Obiettivo prodotto

Ridurre il tempo e i passaggi per **creare e gestire schede per un atleta**, eliminando dead-end e confusione sandbox/cliente. Avvicinare **logging sessione** al momento in cui il coach compone la scheda.

**Prerequisito:** [Fase 1](workout-builder-ux-phase1-trust.plan.md) mergiata (minimo WB-01).

## WB-06 — Scelta vuoto / template / duplica (P1 · M)

### Problema

FAB “nuovo piano” apre sempre editor vuoto. Coach spesso parte da template o duplica ciclo precedente.

### Design

Bottom sheet su FAB (lista piani cliente):

```
Nuova scheda
─────────────────
○ Scheda vuota
○ Da template libreria   → /workouts/templates?customerId=
○ Duplica piano esistente → picker piani cliente → duplicate → editor
```

Overview “Assegna workout” può aprire lo stesso sheet invece di andare diretto a `/new`.

### File

| File | Azione |
|------|--------|
| `customer_workouts_screen.dart` | Sheet + routing |
| `customer_detail_overview_tab.dart` o `customer_detail_workout_plans_section.dart` | Stesso entry |
| `workout_plan_templates_screen.dart` | Query `customerId` pre-seleziona assign |
| Nuovo `customer_new_workout_sheet.dart` | UI sheet |
| `app_*.arb` | Stringhe sheet |

### Acceptance

- [ ] Tre percorsi funzionanti da lista piani
- [ ] Template assign + WB-03 open plan ancora valido

### Branch

`feat/workout-new-plan-picker`

---

## WB-07 — Sandbox builder etichettato (P1 · M)

### Problema

Dashboard → `/workouts/builder` sembra “la scheda ufficiale”; dati in SharedPreferences, non sul cliente.

### Design

- App bar subtitle o banner: **“Bozza locale — non assegnata a un cliente”**
- Drawer: rinominare voce (es. “Builder bozza” vs “Schede clienti”)
- CTA secondaria: **Assegna a cliente** → picker cliente → `importRoutineToCustomer` o save-as-new-plan flow

### File

| File | Azione |
|------|--------|
| `workout_builder_mobility_screen.dart` | Banner when !editorMode |
| `workout_builder_editor_shell.dart` | Subtitle |
| `dashboard_drawer.dart` | Copy |
| `dashboard_summary_footer.dart` | Tooltip/hint |
| `workout_builder_routine_coordinator.dart` | Assign draft to customer method |
| `app_*.arb` | `workoutBuilderSandboxBanner`, `workoutBuilderAssignToCustomer` |

### Rischi

- Import JSON vs struttura routine — riusare path export/import esistente
- Validazione cliente selezionato (auth scope)

### Branch

`feat/workout-sandbox-assign-cta`

---

## WB-08 — Tab Workout su dettaglio cliente (P1 · M)

### Problema

Piani solo in overview (max 5) + link “Vedi tutti”. Tab attuali: overview, measurements, records — **no Workout**.

### Opzioni

| Opzione | Pro | Contro |
|---------|-----|--------|
| **A — Nuovo tab** | UX chiara | +1 tab bar |
| **B — Overview slim + tab dedicato** | Meno scroll overview | Refactor overview |

**Raccomandazione:** Tab **Workout** con body = estratto da `CustomerWorkoutsScreen` (widget condiviso `CustomerWorkoutPlansBody`).

### File

| File | Azione |
|------|--------|
| `customer_detail_screen.dart` | TabController + tab |
| Estrarre body da `customer_workouts_screen.dart` | Widget riusabile |
| `app_*.arb` | `customerTabWorkouts` |

### Routing

Mantenere `/customers/:id/workouts` per deep link; tab sincronizza con `navigateTo` oppure embed senza route change (preferire embed + “Apri full screen” opzionale).

### Branch

`feat/customer-workout-tab`

---

## WB-09 — Log sessione dal builder (P2 · M)

### Problema

`showSessionLogSheet` solo da schedule/calendar. Coach in editor non può segnare sessione.

### Design

Su header giorno in `TrainingWeekDayPanel`:

- Icon button “Registra esecuzione” (se piano ha date / sessione pianificata)
- Richiede `planId`, `weekIndex`, `dayIndex`, `customerId`

Alternativa: voce in tab Dettagli “Sessione di oggi”.

### File

| File | Azione |
|------|--------|
| `training_week_day_panel.dart` | Action button |
| `workout_builder_mobility_screen.dart` | Pass planId, execution service |
| `session_log_sheet.dart` | Verificare params esistenti |
| `app_*.arb` | `workoutBuilderLogSession` |

### Dipendenze

- Piano salvato (`loadedPlanId`)
- Date/coordinate sessione da schedule service

### Branch

`feat/workout-builder-session-log`

---

## WB-10 — Duplica giorno / settimana (P2 · M)

### Problema

Coach ricopia manualmente Push A → Push B, o settimana 1 → settimana 2.

### Design

- Menu giorno: **Duplica su…** → picker altro giorno (replace o merge)
- Menu settimana: **Duplica settimana** → insert week copy con nomi “Settimana N (copia)”

### File

| File | Azione |
|------|--------|
| `workout_builder_training_handlers.dart` | Mutations |
| `workout_exercise_mutations.dart` o domain | Copy routine slice |
| `training_week_day_panel.dart` | Menu entries |
| `app_*.arb` | Dialog copy |

### Test

- Unit test copy week/day structure preserves exercise ids / superset groups

### Branch

`feat/workout-duplicate-day-week`

---

## WB-11 — Read-only archiviati/completati (P2 · M)

### Problema

Piani archived/completed ancora fully editable.

### Soluzione

In `WorkoutBuilderMobilityScreen` load: flags `_planArchived`, `_planCompleted` (già parziali?) → disable handlers + banner “Solo lettura — duplica per modificare”.

Export PDF/JSON resta enabled.

### File

| File | Azione |
|------|--------|
| `workout_builder_mobility_screen.dart` | Read-only mode |
| `workout_builder_training_handlers.dart` | Guard clauses |
| `workout_builder_editor_shell.dart` | Hide/disable save mutations |

### Branch

`feat/workout-plan-readonly-status`

---

## WB-12 — Hint calendario vuoto (P2 · S)

### Problema

`PlanScheduleStrip` → `SizedBox.shrink()` se nessun evento; piano sembra “rotto”.

### Soluzione

Placeholder: “Imposta data di inizio” → `onTap` callback parent apre tab Dettagli o date picker.

### File

| File | Azione |
|------|--------|
| `plan_schedule_strip.dart` (o equivalente in customers) | Empty UI |
| `customer_workout_plan_list_tile.dart` | Pass callback |

### Branch

`feat/workout-schedule-empty-hint`

---

## WB-21 — Test journey E2E (P2 · M)

### Scope

Widget test con GoRouter fake:

1. Navigate `/customers/c1/workouts/new`
2. Tap save (mock repository)
3. Assert URL `/customers/c1/workouts/plan-x`
4. Assert autosave timer armed

Non full integration Drift — usare fake `WorkoutPlanRepository` se esiste pattern test.

### File

| File | Azione |
|------|--------|
| `test/features/workouts/workout_customer_journey_test.dart` | Nuovo |
| `test/features/customers/` | Eventuali fake |

### Branch

Incluso in PR rilevanti o `test/workout-customer-journey`

---

## Sequenza PR consigliata

| Ordine | ID | Rationale |
|--------|-----|-----------|
| 1 | WB-06 | Sblocca onboarding nuovo piano |
| 2 | WB-07 | Riduce confusione sandbox |
| 3 | WB-08 | Navigazione cliente |
| 4 | WB-10 | Produttività editor |
| 5 | WB-09 | Integrazione execution |
| 6 | WB-11 + WB-12 | Polish |
| 7 | WB-21 | Regression net |

## Definition of done fase 2

- Coach tipico: cliente → tab Workout → nuovo piano (template o vuoto) → editor → save → calendario hint se no date
- Sandbox chiaramente etichettata
- Test journey verde
- Roadmap todo `phase2-coach-flow` → completed

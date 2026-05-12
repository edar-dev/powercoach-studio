---
name: feature-04-workout-plan-templates
overview: Introdurre piani modello riusabili (senza cliente o con flag template), duplicazione rapida verso un cliente, e gestione libreria template nel builder o schermata dedicata.
todos:
  - id: domain-template-model
    content: Estendere WorkoutPlanApiModel o payload JSON con isTemplate templateSourceId; oppure OfflineEntityType dedicato templateWorkoutPlan
    status: pending
  - id: repository-api
    content: WorkoutPlanRepository metodi listTemplates createTemplate duplicateFromPlan assignToCustomer con scopeId coerente
    status: pending
  - id: ui-library-screen
    content: Nuova schermata o tab Libreria template sotto /workouts o /customers; lista, anteprima nome, azioni Duplica / Assegna
    status: pending
  - id: assign-flow
    content: Dialog scelta cliente + creazione piano copia (nuovo id, customerId target, planData copiato, nome suggerito)
    status: pending
  - id: router-and-guard
    content: Aggiungere route in app.dart se protetta; allineare isProtectedRoute se nuovo path
    status: pending
  - id: l10n
    content: Stringhe IT/EN per template, duplica, assegna, vuoto
    status: pending
  - id: backup-compat
    content: Se nuovo tipo entità o campi payload, aggiornare regola backup JSON e test codec se necessario
    status: pending
isProject: false
---

# Feature 04 — Template piani allenamento

## Obiettivo prodotto

- Il coach crea **modelli** di scheda (es. “Upper/Lower base”, “Mobilità mattina”) riutilizzabili.
- Con pochi tap **duplica** un template verso un **cliente** reale come nuovo piano attivo (o bozza).
- Riduce tempo rispetto a ricreare blocchi nel [`WorkoutBuilderMobilityScreen`](lib/features/workouts/presentation/screens/workout_builder_mobility_screen.dart).

## Stato attuale

- Piani persistiti come `OfflineEntityType.workoutPlan` via [`WorkoutPlanRepository`](lib/features/workouts/data/workout_plan_repository.dart) con `customerId`, `planData`, `name`, ecc.
- Nessun concetto esplicito di “template” nel modello attuale.

## Decisione di design (scegliere una prima implementazione)

### Opzione A — Template = piano con `customerId` sentinella

- Es. `customerId: '__template__'` o stringa cost in [`lib/core/constants`](lib/core/) (meglio cost condivisa con filtri).
- **Pro**: zero nuovo enum Drift; tutte le query `getByCustomerId` escludono sentinella; `getAll()` filtra o aggiunge `listTemplates()`.
- **Contro**: rischio di confusione se il sentinella compare in UI cliente — da filtrare ovunque.

### Opzione B — Campo `isTemplate` + `templateCustomerId` nullable

- Ogni template legato a un “cliente fittizio” creato automaticamente alla prima installazione.
- **Pro**: meno hack su `customerId`.
- **Contro**: più complessità (bootstrap cliente template).

**Raccomandazione MVP**: **Opzione A** con costante `kTemplateScopeId` e repository che espone `Future<List<WorkoutPlanApiModel>> getTemplates()`.

## Flussi utente

### Creare template da piano esistente

- Dal dettaglio piano o editor: azione **“Salva come template”** → dialog nome → `WorkoutPlanRepository.createTemplate(name, planDataJson, meta...)`.

### Assegnare template a cliente

- Da lista template: **“Assegna a…”** → picker cliente (`CustomerRepository.getAll()`) → `duplicateToCustomer(templateId, customerId, newName)`.

### Modificare template

- Riaprire in editor in modalità `editorMode: true` con `planId` del template (stesso flusso piani normali ma `customerId` sentinella).

## Architettura repository

Nuovi metodi suggeriti in [`workout_plan_repository.dart`](lib/features/workouts/data/workout_plan_repository.dart):

- `Future<List<WorkoutPlanApiModel>> listTemplates()` — filtra `customerId == kTemplateScopeId` o `payload['isTemplate'] == true`.
- `Future<WorkoutPlanApiModel> createTemplate({required String name, required String planDataJson, ...})` — crea entità con id temp/new.
- `Future<WorkoutPlanApiModel> duplicateToCustomer({required String sourcePlanId, required String customerId, String? name})` — deep copy `planData`, nuovo id, timestamps.

## Routing e UI

- Nuova route es. `/workouts/templates` (lista) + eventuale `/workouts/templates/:id` editor riuso builder con query `template=1`.
- Aggiornare [`lib/app.dart`](lib/app.dart) `isProtectedRoute` se il path è sotto `/workouts` (già coperto da `path.startsWith('/workouts')` — verificare).

## Coerenza PDF / export

- Template potrebbero non avere PDF generabile senza cliente: disabilitare export PDF finché non assegnato, o usare header generico.

## i18n e accessibilità

- Tutte le etichette in ARB; icona distintiva (es. `Icons.bookmark_outline`).

## Test

- Unit: `duplicateToCustomer` produce nuovo `id`, `customerId` corretto, `planData` uguale al sorgente.
- Repository fake: lista template vuota / con elementi.

## Rischi

- **Doppioni** di template dopo import backup — accettabile MVP.
- **Dimensione planData** — copia profonda JSON per evitare riferimenti mutabili condivisi.

## Definition of done

- Creazione, lista, assegnazione template funzionanti su device.
- Nessun template mostrato nella lista piani del cliente reale.
- Analyze + test unitari base.

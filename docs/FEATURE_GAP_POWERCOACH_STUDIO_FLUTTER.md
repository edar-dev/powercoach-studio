# Analisi feature: powercoach-studio-flutter vs powercoach-studio

Analisi delle funzionalità **presenti in powercoach-studio-flutter** ma **non (o non ancora) in powercoach-studio**, con piano di implementazione ordinato per priorità.

---

## 1. Riepilogo progetti

| Aspetto | powercoach-studio | powercoach-studio-flutter |
|--------|-------------------|---------------------------|
| **State management** | Nessuno (setState / callback) | Riverpod (providers, notifier) |
| **Entry post-login** | `/dashboard` (Coach Dashboard) | `/customers` |
| **Landing** | Landing Stitch (Simplified Startup) | Welcome (Hero + Features + How it works) |
| **Workout** | Workout Builder (mobility/superset) + SharedPreferences | Workout Plan Editor (tab Description/Mobility/Weeks/PDF) + API + export |
| **Temi** | Stitch M3 light/dark fissi | 4 temi (Light, Dark, Nord, Rose Gold) + switcher |
| **Lingua** | Locale fisso/it da app | Locale provider (sistema / en / it) + persistenza |

---

## 2. Feature in powercoach-studio-flutter NON in powercoach-studio

### 2.1 Export piani

| Feature | Dettaglio | Riferimento (flutter) |
|--------|-----------|------------------------|
| **Export Excel** | Use case `export_excel_usecase.dart`: layout readable / compact / notesFirst, salvataggio in temp, path per condivisione | `domain/usecases/export_excel_usecase.dart`, `export_options_dialog.dart` |
| **Export PDF** | Use case `export_pdf_usecase.dart`: header personalizzato (`pdfHeader`, `useCustomPdfHeader`), tabella esercizi | `domain/usecases/export_pdf_usecase.dart` |
| **Share** | Integrazione `share_plus` per condividere file generati | WorkoutPlanEditorScreen (Export → share) |

In powercoach-studio: landing e home menzionano “Export to PDF” ma non c’è implementazione; il modello `Customer` ha già `pdfHeader` e `useCustomPdfHeader`.

---

### 2.2 Workout Plan Editor (modello e flusso)

| Feature | Dettaglio | Riferimento (flutter) |
|--------|-----------|------------------------|
| **Modello WorkoutPlan** | Freezed: `id`, `name`, `weeks` (WorkoutWeek con phase, tags, weekNotes), `mobilityExercises`, `pdfHeader`, `useCustomPdfHeader`, `phase`, `tags`, `planNotes`, date | `data/models/workout_plan.dart` |
| **WorkoutExercise** | `exerciseId`, `exerciseName`, `isCustom`, `sets`, `reps`, `loadOrRPE`, `setBlocks`, `supersetGroup`, `supersetOrder`, `notes` | idem |
| **PlanPhase** | accumulation, intensification, peaking, deload, offseason | idem |
| **ExportOptions / CustomBranding** | Layout, branding, logo, coach name, contact | idem |
| **Workout Plan Editor screen** | Tab: Description, Mobility, Weeks, PDF; Undo/Redo; creazione/modifica piano per customer; link da customer detail | `workout_plans/presentation/screens/workout_plan_editor_screen.dart` |
| **Route editor** | `/editor/:customerId` (nuovo piano), `/editor/:customerId/:planId` (modifica) | `app_router.dart` |
| **WorkoutPlanProvider** | Caricamento da API, stato corrente, undo/redo | `workout_plan_provider.dart` |
| **WorkoutPlanRepository** | API per piani (get, save, list) | `workout_plan_repository_impl.dart` |

In powercoach-studio: c’è il Workout Builder (mobility, multiset, superset, intuitive superset) con modello `WorkoutRoutine` (nome, mobilityItems, weeks/days/exercises) e salvataggio in SharedPreferences; non c’è editor “piano” con tab Description/Mobility/Weeks/PDF né route `/editor/...`.

---

### 2.3 Exercise library e GraphQL

| Feature | Dettaglio | Riferimento (flutter) |
|--------|-----------|------------------------|
| **ExerciseRepository** | `getExercises()`, `searchExercises()`, `getCategories()`, `getLanguages()`, `getEquipment()` | `domain/repositories/exercise_repository.dart` |
| **GraphQL datasource** | Chiamate GraphQL per esercizi, categorie, lingue, equipment | `data/datasources/remote/graphql_datasource.dart` |
| **Exercise model** | Modello esercizio (id, name, category, ecc.) | `data/models/exercise.dart` |
| **Exercise selector panel** | UI per cercare e aggiungere esercizi dalla library al piano | `workout_plans/presentation/widgets/exercise_selector_panel.dart` |
| **Recent exercises** | Repository + provider per “esercizi usati di recente” | `recent_exercises_repository.dart`, `recent_exercises_provider.dart` |
| **Exercise favorites** | Repository + provider per preferiti | `exercise_favorites_repository.dart`, `exercise_favorites_provider.dart` |
| **Local blocks** | Repository + provider per blocchi/template locali | `local_blocks_repository.dart`, `local_blocks_provider.dart` |

In powercoach-studio: nessuna exercise library da API, nessun GraphQL, nessun pannello di selezione esercizi da catalogo.

---

### 2.4 Customer measurements

| Feature | Dettaglio | Riferimento (flutter) |
|--------|-----------|------------------------|
| **CustomerMeasurement** | Freezed: date, 1RM (squat/bench/deadlift), pliche (triceps, biceps, subscapular, iliac, abdominal, thigh), bodyFatPercent, muscleMassKg, waterPercent, fatMassKg, circonferenze (chest, waist, arms, thighs), notes | `data/models/customer_measurement.dart` |
| **CreateMeasurementPayload** | Payload per creazione misura | idem |
| **Tab Measurements** | Tab nel Customer Detail per visualizzare/gestire misure | `customer_detail_screen.dart` (_MeasurementsTab) |

In powercoach-studio: il customer detail ha Progress Overview (grafico placeholder) e statistiche parziali (peso da `customer.weightKg`); non c’è modello né tab “Measurements” con 1RM, pliche, circonferenze.

---

### 2.5 Welcome screen e onboarding

| Feature | Dettaglio | Riferimento (flutter) |
|--------|-----------|------------------------|
| **WelcomeScreen** | Hero (badge, titolo, sottotitolo, CTA “Start” / “Learn more”), sezione Features, How it works, CTA finale; navigazione a `/login` | `welcome/presentation/screens/welcome_screen.dart` |
| **L10n welcome** | Chiavi per hero, features, how it works, CTA | `l10n/app_localizations_*.dart` |

In powercoach-studio: c’è la Landing Stitch (Simplified Startup Landing Page); il contenuto e la struttura (Hero vs Features vs How it works) possono differire.

---

### 2.6 Temi e lingua in Settings

| Feature | Dettaglio | Riferimento (flutter) |
|--------|-----------|------------------------|
| **Theme provider** | AppThemeMode: light, dark, nord, roseGold; persistenza `theme_mode` in SharedPreferences | `core/theme/app_theme.dart` |
| **ThemeState / ThemeNotifier** | Riverpod Notifier, light/dark ThemeData per ogni tema | idem |
| **Settings: tema** | Radio per scegliere tra i 4 temi | `settings_screen.dart` |
| **Locale provider** | Locale (null = sistema, en, it), persistenza | `core/locale/locale_provider.dart` |
| **Settings: lingua** | Radio Sistema / English / Italiano | `settings_screen.dart` |

In powercoach-studio: tema Stitch M3 (light/dark) fissi, `themeMode: ThemeMode.dark`; nessuno switcher tema/lingua in Settings (c’è Personal Info e Subscription).

---

### 2.7 Architettura e infrastruttura (flutter)

| Feature | Dettaglio | Note per powercoach-studio |
|--------|-----------|-----------------------------|
| **Riverpod** | Auth, customer, workout plan, theme, locale, settings providers | powercoach-studio non usa Riverpod |
| **Result/Failure** | Domain entity per error handling (Result<T>, Failure) | Pattern utile per API e export |
| **Undo/Redo** | Nel Workout Plan Editor | Potenziale estensione builder |
| **Drift** | In pubspec (SQLite); uso in lib da verificare | Flutter ha dipendenza; powercoach-studio no |
| **Freezed + JSON** | Modelli WorkoutPlan, Customer, CustomerMeasurement, Exercise, ecc. | powercoach-studio usa modelli Dart “manuali” |

---

## 3. Piano di implementazione (ordine di importanza)

Le priorità sono state ordinate in base a: valore per l’utente (coach), riuso del codice esistente, dipendenze tra feature e sforzo stimato.

---

### Priorità 1 – Alta (core product)

1. **Export piano a PDF**
   - **Perché**: già promesso in landing (“Export to PDF”); i clienti si aspettano di poter esportare/condividere il piano.
   - **Cosa fare**: introdurre un use case (o funzione) che, dato il modello usato dal Workout Builder (es. `WorkoutRoutine` o un DTO “piano”), generi un PDF (nome piano, settimane/giorni, tabella esercizi). Opzionale: header personalizzato usando `Customer.pdfHeader` / `useCustomPdfHeader` se il piano è associato a un cliente.
   - **Dipendenze**: modello piano (già presente come `WorkoutRoutine`); pacchetto `pdf` in pubspec.
   - **Riferimento**: `powercoach-studio-flutter/lib/domain/usecases/export_pdf_usecase.dart`.

2. **Export piano a Excel**
   - **Perché**: molti coach usano Excel per analisi, stampa o condivisione; completa l’offerta export.
   - **Cosa fare**: use case che esporti lo stesso “piano” in .xlsx (layout semplice: nome, settimane, giorni, colonne Exercise/Sets/Reps/Load-RPE/Notes). Opzionale: layout readable/compact/notesFirst come in flutter.
   - **Dipendenze**: modello piano; pacchetto `excel` in pubspec; `path_provider` (già usato o da aggiungere).
   - **Riferimento**: `powercoach-studio-flutter/lib/domain/usecases/export_excel_usecase.dart`, `export_options_dialog.dart`.

3. **Condivisione file (share)**
   - **Perché**: export senza condivisione ha valore limitato.
   - **Cosa fare**: dopo aver generato PDF/Excel, usare `share_plus` (o equivalente) per aprire il sheet di condivisione con il file generato.
   - **Dipendenze**: export PDF e/o Excel implementati.

---

### Priorità 2 – Alta (esperienza coach)

4. **Workout Plan Editor dedicato (route e flusso)**
   - **Perché**: in flutter l’editor è la schermata principale per creare/modificare piani con tab (Description, Mobility, Weeks, PDF); in powercoach-studio il builder è già ricco ma non ha lo stesso “flusso piano” con tab e opzioni PDF.
   - **Cosa fare**: (a) introdurre route tipo `/workouts/editor?customerId=...` e `/workouts/editor/:planId?customerId=...`; (b) una schermata “Editor piano” che riusa/incapsula il Workout Builder esistente e aggiunge: nome piano, note, opzioni PDF (header), eventuale tab “Description”/“PDF”; (c) collegare “Assign Workout” dal customer detail a questa route. Non è obbligatorio allineare subito il modello a WorkoutPlan Freezed; si può partire da `WorkoutRoutine` e poi evolvere.
   - **Dipendenze**: nessuna bloccante; integrazione con customer detail già presente.

5. **Exercise library (API)**
   - **Perché**: senza catalogo esercizi, l’editor dipende da nomi liberi; la library permette ricerca, consistenza e future funzioni (preferiti, recenti).
   - **Cosa fare**: (a) definire contratto API (REST o GraphQL) per lista esercizi, ricerca, categorie, equipment (se l’API backend lo supporta); (b) client in app (Dio) e repository; (c) modello `Exercise`; (d) UI minima: pannello o bottom sheet “Aggiungi esercizio” con ricerca e lista. Se il backend non espone ancora l’API, implementare solo modello + UI con lista mock/local e lasciare il repository pronto per l’API.
   - **Dipendenze**: backend (ExerciseGraphQL.API o altro) per dati reali.

6. **Customer measurements (modello + tab)**
   - **Perché**: 1RM, pliche e circonferenze sono dati tipici per powerlifting e body composition; oggi in powercoach-studio c’è solo peso e placeholder.
   - **Cosa fare**: (a) modello `CustomerMeasurement` (e payload creazione) allineato a flutter dove possibile; (b) tab “Measurements” nel customer detail con lista date + dettaglio (view/edit); (c) salvataggio via GymBlog.API quando l’endpoint esiste, altrimenti solo UI e modello locale.
   - **Dipendenze**: API backend per persistenza (opzionale per prima iterazione).

---

### Priorità 3 – Media (UX e coerenza)

7. **Temi multipli (Light, Dark, Nord, Rose Gold)**
   - **Perché**: in flutter ci sono 4 temi e switcher; migliora preferenze utente e coerenza tra app.
   - **Cosa fare**: (a) definire 4 ThemeData (o estendere Stitch M3 con Nord e Rose Gold); (b) persistenza tema in SharedPreferences; (c) in Settings, sezione “Tema” con radio (o dropdown). Non è obbligatorio usare Riverpod: si può usare un singleton o callback che ricostruisce MaterialApp.
   - **Riferimento**: `powercoach-studio-flutter/lib/core/theme/app_theme.dart`, `app_colors.dart`.

8. **Scelta lingua (sistema / it / en)**
   - **Perché**: allineamento a flutter e utenti multilingua.
   - **Cosa fare**: (a) persistenza locale scelta (SharedPreferences); (b) in Settings, sezione “Lingua” con Sistema / Italiano / English; (c) applicare `locale` e `supportedLocales` in `MaterialApp` in base alla scelta; (d) assicurare che le stringhe usate in Settings e nelle nuove schermate siano in l10n (en + it).
   - **Riferimento**: `powercoach-studio-flutter/lib/core/locale/locale_provider.dart`.

9. **Welcome screen (opzionale)**
   - **Perché**: in flutter è la landing con Hero + Features + How it works; in powercoach-studio c’è già la Landing Stitch.
   - **Cosa fare**: decidere se (a) mantenere solo la Landing Stitch e aggiornare testi/immagini per allineare “Export”, “Piani”, “Clienti”, oppure (b) introdurre una Welcome separata (Hero + Features + How it works) e usarla come `/` prima del login. Priorità più bassa perché la landing esiste già.

---

### Priorità 4 – Bassa / Backlog

10. **Recent exercises e Exercise favorites**
    - Dopo aver introdotto l’exercise library: repository/provider per “usati di recente” e “preferiti” (locale o API); chip o sezioni nell’exercise selector.

11. **Local blocks / template**
    - Blocchi riutilizzabili (es. “Upper A”, “Lower B”) e eventuali template piano; richiede modello e UI in editor (flutter: `local_blocks_repository`, `PlanTemplate`, `ExerciseBlock`).

12. **Undo/Redo nel Workout Builder**
    - Stack di stati nel builder per annullare/ripetere modifiche; migliora UX in editor complessi.

13. **Allineamento modello piano a WorkoutPlan (Freezed)**
    - Se si vuole piena parità con flutter: modello con `PlanPhase`, `ExportOptions`, `CustomBranding`, `SetBlock`, ecc.; utile quando si integra con API piani e export avanzato.

14. **Riverpod (o altro state management)**
    - Migrazione graduale a provider per auth, customer, workout plan, theme, locale: riduce prop drilling e semplifica test; da pianificare come refactor separato.

---

## 4. Dipendenze tecniche (powercoach-studio)

Da aggiungere in `pubspec.yaml` per le feature sopra:

- **Export PDF**: `pdf: ^3.11.0` (e eventualmente `path_provider` se non già presente).
- **Export Excel**: `excel: ^4.0.0`, `path_provider`.
- **Share**: `share_plus: ^12.0.1`.

Opzionale per exercise library (se si usa GraphQL): `graphql_flutter` (o client GraphQL scelto).

---

## 5. File di riferimento in powercoach-studio-flutter

- Export: `lib/domain/usecases/export_excel_usecase.dart`, `export_pdf_usecase.dart`; `lib/features/workout_plans/presentation/widgets/export_options_dialog.dart`.
- Modello piano: `lib/data/models/workout_plan.dart` (WorkoutPlan, WorkoutWeek, WorkoutDay, WorkoutExercise, PlanPhase, ExportOptions, MobilityExercise, ecc.).
- Editor: `lib/features/workout_plans/presentation/screens/workout_plan_editor_screen.dart`; provider `workout_plan_provider.dart`.
- Router: `lib/core/router/app_router.dart` (route `/editor/:customerId`, `/editor/:customerId/:planId`).
- Exercise: `lib/domain/repositories/exercise_repository.dart`; `lib/data/datasources/remote/graphql_datasource.dart`; `lib/features/workout_plans/presentation/widgets/exercise_selector_panel.dart`.
- Measurements: `lib/data/models/customer_measurement.dart`; tab in `lib/features/customers/presentation/screens/customer_detail_screen.dart`.
- Temi/lingua: `lib/core/theme/app_theme.dart`, `lib/core/locale/locale_provider.dart`; `lib/features/settings/presentation/screens/settings_screen.dart`.
- Welcome: `lib/features/welcome/presentation/screens/welcome_screen.dart`.

---

## 6. Validazione

- Dopo ogni feature: build (`flutter build apk` o `flutter build ios`) e test manuali su schermata interessata.
- Per export: verificare generazione file e condivisione su dispositivo reale.
- Per API (exercise, measurements): verificare con backend reale o mock; documentare endpoint in `README` o `docs`.

Fine del documento.

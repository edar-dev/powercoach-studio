> **Obsoleto (2026-07)** — descrive l'architettura pre local-first (GymBlog API, sync remoto).  
> Per lo stato attuale vedi `README.md`, `docs/sync-strategy.md` e `.cursor/rules/07-local-data-and-integrations.mdc`.

# Analisi feature mancanti – PowerCoach Studio

Analisi delle funzionalità **documentate o presenti in UI** ma **non ancora implementate** (placeholder, link vuoti, schermate assenti, assenza di backend), più **improvements tecnici** implementati o da fare.

---

## 1. Schermate Stitch

| Feature | Riferimento | Stato |
|--------|-------------|--------|
| **Forgot Password** | Stitch ID `3563377ad3864dfca42385fcd5ea0840` | **Implementato.** `ForgotPasswordScreen`, route `/forgot-password`, `resetPasswordForEmail` Supabase. |
| **Coach Dashboard** | Stitch ID `285387f9d39c459a989d6060a1c486b0` | **Implementato.** `CoachDashboardScreen`, route `/dashboard`; post-login redirect a `/dashboard`. Weekly progress, Total Clients (API), Active Programs (placeholder), Add Client / Create Program, Today's Schedule (mock). |
| **Workout Builder – Intuitive Super Set** | Stitch ID `7ce630e5879044e7bdc10852d9b5adb1` | **Implementato.** Variante `intuitiveSuperset`, route `/workouts/builder/intuitive-superset`; UI condivisa con superset. |

---

## 2. Navigazione e route

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Landing vs Home** | Route `/` usa `LandingScreen` (Stitch "Simplified Startup Landing Page"). | **Implementato.** Route `/` → `LandingScreen`; `HomeScreen` non più usato alla root. |
| **Post-login → Dashboard** | Dopo login redirect alla home autenticata. | **Implementato.** Redirect a `/dashboard`; route protette (dashboard, customers, workouts, profile, settings) richiedono login. |
| **Workout Builder – bottom nav** | Library, Builder, Diary, Stats, Profile nella bottom bar del Workout Builder. | **Implementato.** Library → `/workouts/library`, Builder → `/workouts/builder`, Diary → `/workouts/diary`, Stats → `/workouts/stats`, Profile → `/profile`. Placeholder screen per Library/Diary/Stats (`WorkoutPlaceholderScreen`). |
| **Assign Workout → Builder** | Pulsante "Assign Workout" nel Customer Detail. | **Implementato.** `context.push('/workouts/builder?customerId=${c.id}')`. |

---

## 3. Clienti (Customers) – azioni e dati

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Import from contacts** | Pulsante nella lista clienti (stato vuoto). | **Implementato.** `flutter_contacts`: richiesta permesso, `openExternalPick()`, nome e telefono prefilled in Customer Creation via query params (`/customers/new?name=...&phone=...`). Permessi: Android `READ_CONTACTS`, iOS `NSContactsUsageDescription`. |
| **View All (Recent Workouts)** | Link "View All" nella sezione Recent Workouts del Customer Detail. | **Implementato.** Route `/customers/:id/workouts` → `CustomerWorkoutsScreen`; lista placeholder (stessi dati mock); link da Customer Detail. |
| **Recent Workouts** | Due card esempio ("Heavy Upper Body A", "Leg Day Focus") nel Customer Detail. | **Dati fissi.** Nessuna chiamata API o modello; dati hardcoded. |
| **Progress Overview** | Grafico a barre (Mon–Sun) nel Customer Detail. | **Placeholder.** Altezze barre e label fissi; nessun dato da backend. |
| **Statistiche cliente** | Current Weight (da `customer.weightKg`), Muscle Mass, trend (+1.2%, +0.5%). | **Parziale.** Peso da modello; "Muscle Mass" e percentuali sono fissi. |
| **Welcome email** | Testo in Customer Creation: "By adding a client, they will receive a welcome email automatically." | **Backend.** Comportamento dipende da GymBlog.API; non controllabile dall’app. |

---

## 4. Workout Builder – logica e persistenza

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Save routine** | Pulsante "Save" in AppBar. | **Implementato.** Salvataggio in SharedPreferences (`WorkoutRoutineStorage.save`); SnackBar di conferma. |
| **Add / Add Exercise / Add Set** | Pulsanti "Add", "Add Exercise", "New Week", "Add Day to Week N". | **Implementato.** Modello `WorkoutRoutine` (mobility, weeks, days, exercises); Add mobility, New Week, Add Day, Add Exercise aggiornano lo stato. |
| **Edit / Delete** | Edit/Delete su tab mobility, week, day, esercizi. | **Implementato.** Delete su mobility item ed esercizi (icona delete); Edit testuale: dialog per mobility (title, subtitle) e per esercizi (name, sets, reps, rpe, note); salvataggio nello stato e al Save. |
| **Clone week** | Pulsante "Clone" nella week accordion. | **Implementato.** Duplica la settimana con nuovi id e giorni/esercizi. |
| **Drag & drop** | Icone `drag_indicator` su mobility. | **Implementato.** `ReorderableListView` per mobility items con `ReorderableDragStartListener`; reorder persistito al Save. |
| **API workout/routine** | Nessun endpoint chiamato per routine o workout. | **Assente.** Persistenza solo locale (SharedPreferences); GymBlogApiClient da integrare quando l’API sarà disponibile. |

---

## 5. Auth e sicurezza

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Forgot Password** | Flow completo: schermata + invio email reset (Supabase). | **Implementato.** `ForgotPasswordScreen`, route `/forgot-password`, link da Login; `resetPasswordForEmail` Supabase, SnackBar successo/errore. |

---

## 6. Dashboard – azioni e dati

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Weekly Progress (88)** | Card "Workouts This Week". | **Mock.** Valore fisso 88; nessun dato da API o da routine salvate. |
| **Active Programs** | Stat card. | **Placeholder.** Valore fisso 15. |
| **Today's Schedule – See All** | Link "See All" sotto Today's Schedule. | **Implementato.** Route `/dashboard/schedule` → `ScheduleScreen`; lista completa sessioni (mock). |
| **Today's Schedule – tap sessione** | Tap su una card (es. Marcus Wright, Hypertrophy - Legs). | **Implementato.** Navigazione a `/dashboard/schedule/detail` con query (time, period, client, program); `ScheduleDetailScreen` mostra dettaglio placeholder. |
| **Dati schedule** | Le 4 sessioni (orario, cliente, programma). | **Mock.** Lista hardcoded; nessuna API schedule/sessioni. |

---

## 7. Backend / API (GymBlog.API)

| Area | Dettaglio | Stato |
|------|-----------|--------|
| **Customers** | GET list, GET :id, POST, PUT(?), DELETE. | **Implementato** (lato app) per CRUD clienti. |
| **Workouts / Routine** | Endpoint per routine, piani, esercizi, superset. | **Non usati.** Nessuna chiamata da app; API da definire/espandere se si vuole persistenza. |
| **Progress / Stats** | Metriche cliente (peso, muscle mass, trend, grafici). | **Non usati.** Dati in Customer Detail sono mock o da singolo campo `customer.weightKg`. |
| **Welcome email** | Invio email al creare cliente. | **Backend.** Se previsto, va implementato lato server. |

---

## 8. Improvements tecnici (rete, cache, retry)

| Area | Dettaglio | Stato |
|------|-----------|--------|
| **Cache client-side** | Cache in-memory per GET (GymBlog API). | **Implementato.** `ApiCache` + `CacheInterceptor`; TTL 5 min, max 100 entry, invalidazione per prefisso su POST/PUT/DELETE; `GymBlogApiClient.clearCache()` al logout (Profile, Settings). |
| **Retry automatico (Polly-like)** | Retry su errori transitori. | **Implementato.** `RetryPolicy` + `RetryInterceptor`; max 3 retry, exponential backoff + jitter; retry su timeout, connection error, 408, 429, 5xx. File: `retry_policy.dart`, `retry_interceptor.dart`. |
| **Skip cache per richiesta** | Opzione per bypassare la cache (es. pull-to-refresh "forza reload"). | **Implementato.** `options.extra['skip_cache'] = true` in `CacheInterceptor`; `GymBlogApiClient.getList(path, skipCache: true)` e `get(path, skipCache: true)`. Pull-to-refresh e pulsante Retry nella lista clienti usano `skipCache: true`. |
| **Cache persistente** | Persistere cache su disco (SharedPreferences o file) per sopravvivere al kill dell’app. | **Implementato.** `PersistentApiCache` (wrapper su `ApiCache`): persiste chiavi `/api/customers*` in SharedPreferences; `PersistentApiCache.restore(apiCache)` in `main()` all'avvio; max 30 chiavi; invalidazione e clear sincronizzati. |
| **TTL per endpoint** | TTL diverso per path (es. lista clienti 2 min, dettaglio 5 min). | **Implementato.** `CacheInterceptor.pathTtl`: callback `Duration? Function(String path)?`; nel client lista `/api/customers` usa 2 min, resto default 5 min. |
| **Metriche / logging retry** | Log o metriche su numero di retry e fallimenti. | **Implementato.** `RetryInterceptor.onRetry` callback; in debug `debugPrint` con attempt/path/delay; in client `onRetry` invia breadcrumb a Sentry (`Sentry.addBreadcrumb` con category `http.retry`). |

---

## 9. Riepilogo priorità suggerite

1. **Alta (completate)**  
   - ~~Forgot Password~~ · ~~Assign Workout~~ · ~~Post-login Dashboard~~ · ~~Workout Builder Save/Clone/Reorder~~ · ~~Cache e retry API~~.

2. **Media (completate)**  
   - ~~Customer Detail – View All~~ · ~~Dashboard – See All + tap sessione~~ · ~~Skip cache / TTL per endpoint~~.

3. **Bassa / Backlog (completate)**  
   - ~~Import from contacts~~ · ~~Edit testuale Workout Builder~~ · ~~Cache persistente~~ · ~~Metriche/logging retry~~.

4. **Rimasto in backlog**  
   - Dati reali per Recent Workouts, Progress Overview, statistiche (dipende da API backend).

---

## 10. File utili per estendere

- **Auth:** `forgot_password_screen.dart`, `login_screen.dart`, `profile_screen.dart`, `settings_screen.dart` (logout + `GymBlogApiClient.clearCache()`).
- **Dashboard:** `coach_dashboard_screen.dart`, `schedule_screen.dart`, `schedule_detail_screen.dart`; route `/dashboard`, `/dashboard/schedule`, `/dashboard/schedule/detail` in `lib/app.dart`.
- **Customer workouts (View All):** `customer_workouts_screen.dart`; route `/customers/:id/workouts`; link in `customer_detail_screen.dart`.
- **Workout Builder:** `workout_builder_mobility_screen.dart` (varianti mobility, multiset, superset, intuitiveSuperset); `workout_routine_model.dart`, `workout_routine_storage.dart`; route `/workouts/builder`, `/workouts/builder/intuitive-superset`.
- **Rete:** `lib/core/network/gymblog_api_client.dart` (Dio + cache + retry); `api_cache.dart`, `cache_interceptor.dart`, `persistent_api_cache.dart` (restore in `main.dart`), `retry_policy.dart`, `retry_interceptor.dart` (onRetry + Sentry breadcrumb).
- **Import from contacts:** `customer_list_screen.dart` (`_importFromContacts`, `FlutterContacts.requestPermission` + `openExternalPick`); `customer_creation_screen.dart` (prefill da `GoRouterState.uri.queryParameters`: `name`, `phone`); permessi in `AndroidManifest.xml` e `ios/Runner/Info.plist`.
- **Customer Detail – Assign Workout:** `context.push('/workouts/builder?customerId=${c.id}')` in `customer_detail_screen.dart`.

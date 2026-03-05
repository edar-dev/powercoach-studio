# Analisi feature mancanti – PowerCoach Studio

Analisi delle funzionalità **documentate o presenti in UI** ma **non ancora implementate** (placeholder, link vuoti, schermate assenti, assenza di backend).

---

## 1. Schermate Stitch non implementate

| Feature | Riferimento | Stato |
|--------|-------------|--------|
| **Forgot Password** | Stitch ID `3563377ad3864dfca42385fcd5ea0840`, `STITCH_SCREENS.md` "(da creare)" | **Mancante.** In Login c’è il link "Password dimenticata?" che mostra solo `showNotImplementedAlert`. Manca la schermata e l’integrazione con Supabase (reset password / magic link). |

---

## 2. Navigazione e route

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Landing vs Home** | Route `/` usa `LandingScreen` (Stitch "Simplified Startup Landing Page"). | **Implementato.** Route `/` → `LandingScreen`; `HomeScreen` non più usato alla root. |
| **Workout Builder – bottom nav** | Library, Builder, Diary, Stats, Profile nella bottom bar del Workout Builder. | **Implementato.** Library → `/workouts/library`, Builder → `/workouts/builder`, Diary → `/workouts/diary`, Stats → `/workouts/stats`, Profile → `/profile`. Placeholder screen per Library/Diary/Stats (`WorkoutPlaceholderScreen`). |
| **Assign Workout → Builder** | Pulsante "Assign Workout" nel Customer Detail. | **Implementato.** `context.push('/workouts/builder?customerId=${c.id}')`. |

---

## 3. Clienti (Customers) – azioni e dati

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Import from contacts** | Pulsante nella lista clienti (stato vuoto). | **Placeholder.** `onPressed` con commento "Import from contacts - not implemented". Richiederebbe integrazione con contacts (es. platform channel / plugin). |
| **View All (Recent Workouts)** | Link "View All" nella sezione Recent Workouts del Customer Detail. | **Vuoto.** `onPressed: () {}`; nessuna lista workout reale né route. |
| **Recent Workouts** | Due card esempio ("Heavy Upper Body A", "Leg Day Focus") nel Customer Detail. | **Dati fissi.** Nessuna chiamata API o modello; dati hardcoded. |
| **Progress Overview** | Grafico a barre (Mon–Sun) nel Customer Detail. | **Placeholder.** Altezze barre e label fissi; nessun dato da backend. |
| **Statistiche cliente** | Current Weight (da `customer.weightKg`), Muscle Mass, trend (+1.2%, +0.5%). | **Parziale.** Peso da modello; "Muscle Mass" e percentuali sono fissi. |
| **Welcome email** | Testo in Customer Creation: "By adding a client, they will receive a welcome email automatically." | **Backend.** Comportamento dipende da GymBlog.API; non controllabile dall’app. |

---

## 4. Workout Builder – logica e persistenza

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Save routine** | Pulsante "Save" in AppBar. | **Vuoto.** Nessun salvataggio (locale o API). |
| **Add / Add Exercise / Add Set** | Pulsanti "Add", "Add Exercise", "Add Set", "New Week", "Add Day to Week 1". | **Solo UI.** Nessun stato (es. lista esercizi, settimane, giorni) né persistenza. |
| **Edit / Delete** | Edit/Delete su tab mobility, week, day, esercizi. | **Solo UI.** Nessuna logica di rimozione o modifica dati. |
| **Clone week** | Pulsante "Clone" nella week accordion. | **Vuoto.** `onPressed: () {}`. |
| **Drag & drop** | Icone `drag_indicator` su esercizi/mobility. | **Solo visivo.** Nessun reorder (es. `ReorderableListView` o integrazione con stato). |
| **API workout/routine** | Nessun endpoint chiamato per routine o workout. | **Assente.** GymBlogApiClient non espone route per workout builder; serve definizione API e modelli. |

---

## 5. Auth e sicurezza

| Feature | Dettaglio | Stato |
|--------|-----------|--------|
| **Forgot Password** | Flow completo: schermata + invio email reset (Supabase). | **Mancante.** Solo SnackBar "Funzionalità non ancora implementata" dal link in Login. |

---

## 6. Backend / API (GymBlog.API)

| Area | Dettaglio | Stato |
|------|-----------|--------|
| **Customers** | GET list, GET :id, POST, PUT(?), DELETE. | **Implementato** (lato app) per CRUD clienti. |
| **Workouts / Routine** | Endpoint per routine, piani, esercizi, superset. | **Non usati.** Nessuna chiamata da app; API da definire/espandere se si vuole persistenza. |
| **Progress / Stats** | Metriche cliente (peso, muscle mass, trend, grafici). | **Non usati.** Dati in Customer Detail sono mock o da singolo campo `customer.weightKg`. |
| **Welcome email** | Invio email al creare cliente. | **Backend.** Se previsto, va implementato lato server. |

---

## 7. Riepilogo priorità suggerite

1. **Alta**  
   - **Forgot Password:** schermata + integrazione Supabase reset (magic link / reset password).  
   - **Assign Workout:** da Customer Detail navigare a `/workouts` (o `/workouts/builder`) passando `customerId` se serve.

2. **Media**  
   - **Workout Builder – Save:** stato locale (es. in-memory o storage) e/o API per salvare routine.  
   - **Workout Builder – bottom nav:** route e schermate placeholder per Library, Diary, Stats, Profile (o `showNotImplementedAlert`).  
   - **Customer Detail – View All:** route (es. `/customers/:id/workouts`) e schermata lista workout (anche solo placeholder).

3. **Bassa / Backlog**  
   - Import from contacts (dipende da plugin/permessi).  
   - Dati reali per Recent Workouts, Progress Overview, statistiche (dipende da API).  
   - Clone week, drag & drop, edit/delete nel Workout Builder (dipende da modello dati e API).  
   - Allineamento Landing vs Home (scelta UX e rimozione duplicati).

---

## 8. File utili per estendere

- **Nuova schermata Forgot Password:** `lib/features/auth/presentation/screens/forgot_password_screen.dart` (da creare); route in `lib/app.dart`; link in `login_screen.dart` → `context.push('/forgot-password')`.
- **Assign Workout:** in `customer_detail_screen.dart` sostituire `onPressed: () { }` con `context.push('/workouts/builder')` (o con query param `?customerId=...` se l’API lo richiederà).
- **Workout Builder – Save:** aggiungere stato (es. `ChangeNotifier` o bloc) in `workout_builder_mobility_screen.dart` e chiamata API quando l’endpoint sarà disponibile.
- **Bottom nav Workout Builder:** in `_WorkoutBuilderBottomNav` usare `context.go('/workouts/...')` o `showNotImplementedAlert(context)` per Library / Diary / Stats / Profile.

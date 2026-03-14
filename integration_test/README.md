# E2E tests – PowerCoach Studio

Test end-to-end che avviano l’app, simulano tap e navigazione e verificano la UI.

## Requisiti

- File **`.env`** nella root del progetto con almeno:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`

Senza questi, il router potrebbe non inizializzare correttamente e i test possono fallire.

## Esecuzione

Dalla root di **powercoach-studio**:

```bash
# Tutti i test integration
flutter test integration_test/

# Singolo file
flutter test integration_test/app_test.dart
flutter test integration_test/landing_flow_test.dart
```

Su desktop (Windows/macOS/Linux) Flutter chiederà su quale dispositivo eseguire; scegliere il desktop per esecuzione locale veloce. Su Windows può essere richiesto **Developer Mode** (impostazioni di sistema) per la build con plugin.

## Contenuto dei test

- **app_test.dart**: avvio app, navigazione Login → Registrati / Password dimenticata, ritorno indietro, validazione form login (submit vuoto).
- **landing_flow_test.dart**: verifica schermata login (campi e link) e, se visibile, landing (hero e sezione funzionalità).

## Widget test

I test in `test/widget_test.dart` usano la stessa inizializzazione (dotenv + Supabase) e verificano che l’app si costruisca mostrando landing o login.

```bash
flutter test test/
```

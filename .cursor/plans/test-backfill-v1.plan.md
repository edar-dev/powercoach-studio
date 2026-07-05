---
name: test-backfill-v1
overview: "Colmare i gap di test prioritari: repository clienti, auth redirect, settings backup, shell builder, e (opzionale) integration_test su main in CI."
todos:
  - id: customer-repository-crud
    content: "test/features/customers/customer_repository_test.dart — create, update, delete, list scoped by userId"
    status: pending
  - id: customer-measurement-repo
    content: "test/features/customers/customer_measurement_repository_test.dart — add/list measurements"
    status: pending
  - id: auth-login-widget-smoke
    content: "test/features/auth/login_screen_test.dart — pump widget, tap login, verify redirect guard mock"
    status: pending
  - id: route-redirect-extended
    content: "Estendere test/core/routing/route_redirect_test.dart — tutti i protected prefixes"
    status: pending
  - id: settings-backup-smoke
    content: "test/features/settings/settings_screen_backup_test.dart — sezione backup visibile, tap export mock"
    status: pending
  - id: builder-shell-widget
    content: "test/features/workouts/workout_builder_editor_shell_test.dart — layout tabs smoke"
    status: pending
  - id: hevy-api-client-parse
    content: "test/features/integrations/hevy/hevy_api_client_test.dart — mock Dio, error mapping (no network)"
    status: pending
  - id: integration-test-ci-job
    content: "Aggiungere job integration_test in flutter-ci.yml (main only, secrets Supabase test)"
    status: pending
  - id: coverage-baseline
    content: "Documentare in docs/testing.md quali area sono covered vs intentional gaps"
    status: pending
isProject: false
---

# Test Backfill v1

## Punti coperti

| # roadmap | Descrizione |
|-----------|-------------|
| **8** | Test mirati dove mancano |

## Obiettivo

Coprire i flussi ad alto rischio di regressione **senza** puntare a 80% coverage. Focus su repository e auth guard.

## Matrice gap attuale

| Area | Test oggi | Priorità |
|------|-----------|----------|
| Workouts domain/data | 30+ file | ✅ OK |
| Dashboard loaders | 4 file | ✅ OK |
| Hevy mappers | 4 file | ✅ OK |
| Routing redirect | 2 file | 🟡 estendere |
| Customer repositories | smoke only | 🔴 CRUD |
| Auth screens | 0 | 🔴 smoke |
| Settings / backup UI | 0 | 🟡 smoke |
| Builder mega-screen | widget parziali | 🟡 shell |
| HevyApiClient HTTP | 0 | 🟡 mock Dio |
| integration_test/ | 2 file, no CI | 🟢 optional |

## Implementazione

### Tier 1 — Repository (no widget)

**Harness:** riusare pattern da `test/local_only/local_only_repositories_smoke_test.dart` + `fake_path_provider_platform.dart`.

```dart
// customer_repository_test.dart
setUp(() async {
  await OfflineLocalStore.instance.initializeForTest(userId: 'test-user');
});
test('createCustomer persists and lists', () async { ... });
test('deleteCustomer removes from store', () async { ... });
```

File:

- `lib/features/customers/data/customer_repository.dart`
- `lib/features/customers/data/customer_measurement_repository.dart`

### Tier 2 — Auth & routing

| Test | File sorgente |
|------|---------------|
| `route_redirect_test.dart` | Aggiungere casi `/customers`, `/workouts`, `/settings` unauthenticated → login |
| `login_screen_test.dart` | `lib/features/auth/presentation/screens/login_screen.dart` — pump + find widgets |

Mock Supabase: `Supabase.instance` non in unit test — testare redirect con `resolveAppRouteRedirect` isolato (già fatto parzialmente).

### Tier 3 — Settings backup smoke

```dart
testWidgets('settings shows backup section', (tester) async {
  await tester.pumpWidget(testApp(SettingsScreen()));
  expect(find.text(l10n.settingsBackupTitle), findsOneWidget);
});
```

Mock `UserDataBackupService` via callback injection se necessario — o verificare solo presenza UI.

### Tier 4 — Builder shell

Dopo [`presentation-split-v1`](presentation-split-v1.plan.md) PR1:

- Test `WorkoutBuilderEditorShell` con tab fake — no full mobility screen.

### Tier 5 — Integration CI (optional)

```yaml
# .github/workflows/flutter-ci.yml — job aggiuntivo
integration:
  if: github.ref == 'refs/heads/main'
  needs: [analyze, test]
  steps:
    - uses: ./.github/actions/setup-flutter-app
      env:
        SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
        SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
    - run: flutter test integration_test/
```

Richiede secrets test project Supabase — documentare in `integration_test/README.md`.

## Ordine PR

1. `test/customer-repository-crud`
2. `test/route-redirect-extended`
3. `test/auth-login-smoke`
4. `test/settings-backup-smoke`
5. `test/hevy-api-client-mock`
6. `ci/integration-test-main` (optional)

## Verifica

```bash
flutter test test/features/customers/customer_repository_test.dart
flutter test test/
flutter analyze
```

## Rischi

- Drift in-memory DB in test — assicurare `initializeForTest` isolato per test
- Widget test auth richiede `MaterialApp.router` setup — riusare helper da `test/widget_test.dart`

## Dipendenze

- Customer repo tests: indipendenti — **iniziare subito**
- Builder shell test: dopo primo split mobility ([`presentation-split-v1`](presentation-split-v1.plan.md))
- Settings backup test: dopo [`local-first-ux-v1`](local-first-ux-v1.plan.md) se UI sync rimossa

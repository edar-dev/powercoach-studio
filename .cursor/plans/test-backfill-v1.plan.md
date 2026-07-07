---
name: test-backfill-v1
overview: "Colmare i gap di test prioritari: repository clienti, auth redirect, settings backup, shell builder, e (opzionale) integration_test su main in CI."
todos:
  - id: customer-repository-crud
    content: "test/features/customers/customer_repository_test.dart — create, update, delete, list scoped by userId"
    status: completed
  - id: customer-measurement-repo
    content: "test/features/customers/customer_measurement_repository_test.dart — add/list measurements"
    status: completed
  - id: auth-login-widget-smoke
    content: "test/features/auth/login_screen_test.dart — pump widget, tap login, verify redirect guard mock"
    status: completed
  - id: route-redirect-extended
    content: "Estendere test/core/routing/route_redirect_test.dart — tutti i protected prefixes"
    status: completed
  - id: settings-backup-smoke
    content: "test/features/settings/settings_screen_backup_test.dart — sezione backup visibile, tap export mock"
    status: completed
  - id: builder-shell-widget
    content: "test/features/workouts/workout_builder_editor_shell_test.dart — layout tabs smoke"
    status: completed
  - id: hevy-api-client-parse
    content: "test/features/integrations/hevy/hevy_api_client_test.dart — mock Dio, error mapping (no network)"
    status: completed
  - id: integration-test-ci-job
    content: "Aggiungere job integration_test in flutter-ci.yml (main only, secrets Supabase test)"
    status: cancelled
  - id: coverage-baseline
    content: "Documentare in docs/testing.md quali area sono covered vs intentional gaps"
    status: completed
isProject: false
---

# Test Backfill v1

## Punti coperti

| # roadmap | Descrizione |
|-----------|-------------|
| **8** | Test mirati dove mancano |

## Obiettivo

Coprire i flussi ad alto rischio di regressione **senza** puntare a 80% coverage. Focus su repository e auth guard.

## Stato (completato)

Tutti i tier 1–4 e la documentazione `docs/testing.md` sono implementati. Il job CI integration_test resta opzionale (richiede secrets Supabase test).

## Verifica

```bash
flutter test test/
flutter analyze
```

## Dipendenze

- Builder shell test: completato insieme a [`presentation-split-v1`](presentation-split-v1.plan.md) PR1

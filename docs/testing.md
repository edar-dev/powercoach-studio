# Testing guide — PowerCoach Studio

This document describes what the test suite covers and intentional gaps. The goal is **targeted regression protection**, not high line coverage.

## Running tests

```bash
flutter analyze
flutter test test/
```

Optional integration tests (require `.env` with Supabase credentials):

```bash
flutter test integration_test/
```

Integration tests are **not** run in CI by default (no test-project secrets in the repo).

## Covered areas

| Area | Location | Notes |
|------|----------|-------|
| Workouts domain/data | `test/features/workouts/` | Repositories, codecs, mutations, list helpers, builder controllers |
| Customers | `test/features/customers/` | Repository CRUD, measurements, progress metrics |
| Dashboard | `test/features/dashboard/` | Snapshot, calendar loader, session detail |
| Exercise library | `test/features/exercise_library/` | Pinned/recent stores, picker, autocomplete |
| Hevy integration | `test/features/integrations/hevy/` | Mappers, parsers, **API client (mock Dio)** |
| Auth & routing | `test/features/auth/`, `test/core/routing/` | Login smoke, route redirect guards |
| Settings | `test/features/settings/` | User preferences repo, backup section UI |
| Storage / sync | `test/core/storage/`, `test/core/sync/` | Pending ops, offline migration, backup codec |
| Notifications | `test/core/notifications/` | Reminder model, calendar scheduler |
| PDF export | `test/core/pdf/` | Formatting helpers |
| Widget smoke | `test/widget_test.dart` | Registration, forgot password |

## Intentional gaps

| Area | Reason |
|------|--------|
| Full Supabase auth flow | Requires live auth; covered by integration tests locally |
| Drift schema migrations | Validated manually + smoke tests via `initializeForTest` |
| Mega-screens (builder, customer workouts) | Split in progress ([presentation-split-v1](../.cursor/plans/presentation-split-v1.plan.md)); shell/tab widget tests added incrementally |
| End-to-end backup file I/O | Export/import UI smoke only; codec tested in unit tests |
| Hevy live HTTP | Mock Dio only; no network in CI |

## Test harness patterns

- **Drift / offline:** `OfflineLocalStore.instance.initializeForTest(userId: '…')` with `fake_path_provider_platform.dart`
- **SharedPreferences:** `SharedPreferences.setMockInitialValues({})` in `setUp`
- **macOS notifications in widget tests:** `registerFakeMacOSNotificationsPlatform()` in `test/support/`
- **Hevy API:** inject `Dio` with interceptors into `HevyApiClient`

## When adding tests

1. Prefer repository/domain unit tests over full widget trees.
2. Reuse l10n + `StitchM3Theme` wrappers from existing widget tests.
3. Run `flutter test test/` before opening a PR.

See also [test-backfill-v1 plan](../.cursor/plans/test-backfill-v1.plan.md).

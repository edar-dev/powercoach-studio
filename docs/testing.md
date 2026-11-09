# Testing guide — PowerCoach Studio

This document describes what the test suite covers and intentional gaps. The goal is **targeted regression protection**, not high line coverage.

## Running tests

```bash
flutter analyze
flutter test test/
```

### Integration / emulator smokes

**Phase B phone UI smokes** (no Supabase secrets — local harnesses):

```bash
flutter test integration_test/phone_smokes/ -d <deviceId>
```

These run on **Codemagic nightly only** (`android_integration_nightly` in `codemagic.yaml`). They are **not** part of GitHub PR CI (`flutter test test/` remains the required gate). Schedule the workflow in the Codemagic UI (Scheduled builds → `Android Integration Smokes (Nightly)` on `main`).

Optional login/landing E2E (require `.env` with Supabase credentials):

```bash
flutter test integration_test/app_test.dart
flutter test integration_test/landing_flow_test.dart
```

Those login/landing files are **not** run in CI (no test-project secrets in the repo). Details: `integration_test/README.md`.

## Covered areas

| Area | Location | Notes |
|------|----------|-------|
| Workouts domain/data | `test/features/workouts/` | Repositories, codecs, mutations, list helpers, builder controllers |
| Customers | `test/features/customers/` | Repository CRUD, measurements, progress metrics |
| Dashboard | `test/features/dashboard/` | Snapshot, calendar loader, session detail |
| Exercise library | `test/features/exercise_library/` | Pinned/recent stores, picker, autocomplete, import/tree helpers |
| Auth & routing | `test/features/auth/`, `test/core/routing/` | Login smoke, route redirect guards |
| Settings | `test/features/settings/` | User preferences repo, backup section UI |
| Storage / sync | `test/core/storage/`, `test/core/sync/` | Pending ops, offline migration, backup codec |
| Notifications | `test/core/notifications/` | Reminder model, calendar scheduler |
| PDF export | `test/core/pdf/` | Formatting helpers |
| Widget smoke | `test/widget_test.dart` | Registration, forgot password |

## Intentional gaps

| Area | Reason |
|------|--------|
| Full Supabase auth flow | Requires live auth; covered by local login/landing integration tests only |
| Drift schema migrations | Validated manually + `debugCloseForTest` / `upsertEntityForUser` round-trips |
| Mega-screens (builder, customer workouts) | Split in progress ([presentation-split-v1](../.cursor/plans/presentation-split-v1.plan.md)); shell/tab widget tests added incrementally |
| End-to-end backup file I/O | Export/import UI smoke only; codec tested in unit tests |

## Test harness patterns

- **Drift / offline:** `FakePathProviderPlatform` + `OfflineLocalStore.instance.clear()` / `upsertEntityForUser` / `debugCloseForTest()` (see `test/support/fake_path_provider_platform.dart`)
- **Phone UI smokes:** `integration_test/support/phone_smoke_harness.dart` (shell router + day editor + Modifica blocco fixtures; no live auth)
- **SharedPreferences:** `SharedPreferences.setMockInitialValues({})` in `setUp`
- **macOS notifications in widget tests:** `registerFakeMacOSNotificationsPlatform()` in `test/support/`

## When adding tests

1. Prefer repository/domain unit tests over full widget trees.
2. Reuse l10n + `StitchM3Theme` wrappers from existing widget tests.
3. Run `flutter test test/` before opening a PR.

See also [test-backfill-v1 plan](../.cursor/plans/test-backfill-v1.plan.md).

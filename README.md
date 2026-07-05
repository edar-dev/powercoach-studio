# PowerCoach Studio

Flutter app (Material 3) for gym coaches: clients, workout plans, measurements, calendar, and session tracking.

**Architecture:** local-first — business data lives in Drift/SQLite and SharedPreferences, scoped per authenticated user. **Supabase** is used for authentication only. Optional **Hevy** export uses Dio against the Hevy API (user-provided API key in app settings).

## Environment

Copy `.env.example` to `.env` and fill in Supabase credentials for local auth, then sync into the bundled asset:

```bash
cp .env.example .env
# Edit .env: SUPABASE_URL, SUPABASE_ANON_KEY
bash scripts/ensure-env.sh   # copies .env -> .env.example for flutter run/build
```

`flutter analyze` and `flutter test test/` work without this step (placeholder values in `.env.example`).

| Variable | Required | Purpose |
|----------|----------|---------|
| `SUPABASE_URL` | Yes | Supabase project URL (auth) |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon key (auth) |
| `SENTRY_DSN` | No | Error monitoring (release builds only) |
| `SENTRY_ENVIRONMENT` | No | Sentry environment tag (default `development`) |

## Monitoring (Sentry)

When `SENTRY_DSN` is set, release builds send errors and navigation traces to [Sentry](https://sentry.io). Leave empty to disable.

## Local data

- **Drift/SQLite** (`powercoach_offline.sqlite`): customers, workout plans, pending ops, sync metadata.
- **SharedPreferences**: settings, drafts, exercise pins/recents, reminders, locale.
- **Backup/restore**: JSON export/import via Settings — see `docs/` and `.cursor/rules/13-user-data-backup-json-compat.mdc`.

Coach profile fields (display name, phone, bio, etc.) are stored locally per user, not in Supabase tables.

## Dev environment

CI pins **Flutter 3.35.6** (see `.flutter-version` and `.github/workflows/flutter-ci.yml`). Use the same version locally to avoid analyze/build drift:

```bash
# With FVM (optional)
fvm use

# Or install Flutter 3.35.6 and verify
flutter --version
```

Before opening a PR: `flutter analyze` and `flutter test test/`.

## Testing

- **Unit & widget tests** (no backend):  
  `flutter test test/`
- **Integration tests** (full app; run `bash scripts/ensure-env.sh` after setting `.env`):  
  `flutter test integration_test/`  
  See `integration_test/README.md` for platform notes (Windows Developer Mode, etc.).

## Local notifications & reminders

Scheduled client/session reminders use `flutter_local_notifications`. See **`docs/local-notifications-reminders.md`**.

## CI/CD

| Trigger | Pipeline | Output |
|---------|----------|--------|
| PR → `main` | GitHub **Flutter CI** (`.github/workflows/flutter-ci.yml`) | analyze + `test/` |
| Push → `main` | GitHub **Vercel Deploy** | web production |
| Push → `main` | Codemagic **`android_release`** | signed APK + AAB |
| Tag `v*` | Codemagic **`android_play_store`** | Play internal track |

PR quality checks run on **GitHub Actions only** (Codemagic `pr_quality_gate` removed to avoid duplicate work).

## Codemagic CI/CD

Two Android workflows in `codemagic.yaml` (Flutter **3.35.6**):

- **`android_release`** (push → `main`): signed release APK + AAB
- **`android_play_store`** (tag `v*`): AAB upload to Google Play internal track

Configure Codemagic group **`google_credentials`** with:

- `SUPABASE_URL`, `SUPABASE_ANON_KEY` (required)
- `SENTRY_DSN`, `SENTRY_ENVIRONMENT` (optional)
- Android keystore vars (release / Play Store workflows)
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (Play Store publish only)

See `docs/play-store-release-guide.md` for the full setup.

## Privacy Policy (GitHub Pages)

Static page: `docs/privacy-policy/index.html`  
Workflow: `.github/workflows/privacy-policy-pages.yml`

After enabling GitHub Pages (Actions source), Play Console URL:

- `https://edar-dev.github.io/powercoach-studio/privacy-policy/`

## Web deploy (Vercel)

See `docs/vercel-web-deploy.md`. Build scripts: `scripts/ci-build-web.sh`, `scripts/vercel-build.sh`.

## Project layout

```
lib/
├── core/           # auth, storage, routing, theme, ui widgets, backup, notifications…
│   ├── routing/    # app_routes.dart, route_redirect.dart
│   ├── theme/      # StitchM3Theme
│   └── ui/widgets/ # shared Stitch components (AppBar, Card, sheets…)
├── features/       # auth, landing, dashboard, customers, workouts, settings, integrations/hevy
├── app.dart        # MaterialApp.router + configureAppRouter()
└── main.dart       # bootstrap
```

Feature modules follow `presentation/` · `data/` · `domain/` under `lib/features/<name>/`.

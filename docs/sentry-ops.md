# Sentry ops — releases, symbols, alerts

PowerCoach Studio uses opt-in `sentry_flutter` in **release** builds when `SENTRY_DSN` is set (`lib/main.dart`). This doc is the ops checklist for release naming, symbol upload, and alert rules.

## Release / environment contract

| Field | Value | Source |
|-------|--------|--------|
| `release` | `powercoach-studio@<version>` | `SentryReleaseInfo` + `--dart-define=APP_VERSION` (pubspec version **without** `+build`) |
| `dist` | `<build>` | `--dart-define=APP_BUILD` (pubspec number **after** `+`) |
| `environment` | from `SENTRY_ENVIRONMENT` | Defaults to **`production`** when unset (Sentry only runs in release). Local release tests: set `SENTRY_ENVIRONMENT=development` in `.env`. |
| DSN | `SENTRY_DSN` | Empty = Sentry disabled (keep opt-in) |

Example for `version: 1.0.7+8` in `pubspec.yaml`:

- release: `powercoach-studio@1.0.7`
- dist: `8`

Keep CI upload (`scripts/sentry-upload.sh`) on the **same** `SENTRY_RELEASE` / `SENTRY_DIST` strings so stack traces resolve.

## Secrets (CI)

### GitHub Actions (web deploy — `.github/workflows/vercel-deploy.yml`)

| Secret | Required | Purpose |
|--------|----------|---------|
| `SENTRY_DSN` | No | Embed DSN into web release build |
| `SENTRY_ENVIRONMENT` | No | Default `production` |
| `SENTRY_AUTH_TOKEN` | No* | Auth token with **Release** + **Organization: Read** (and project write for artifacts) |
| `SENTRY_ORG` | No* | Sentry org slug |
| `SENTRY_PROJECT` | No* | Sentry project slug |

\* All three of `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` are required for symbol/source-map upload. If any is missing, `scripts/sentry-upload.sh` **skips** (exit 0) and deploy still succeeds.

Create the token in Sentry → **Settings → Auth Tokens** (or User Settings → Auth Tokens) with scopes that allow uploading release artifacts / debug files.

### Codemagic (Android — `codemagic.yaml`)

In group `google_credentials` (or a dedicated group), optionally add:

- `SENTRY_DSN`, `SENTRY_ENVIRONMENT` (already documented)
- `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` for debug-symbol upload after APK/AAB build

Android builds pass `APP_VERSION` / `APP_BUILD` and `--split-debug-info=build/app/symbols`.

### Never in the Flutter app

- Do **not** put `SENTRY_AUTH_TOKEN` (or any service-role secret) in `.env` / app assets.
- App only needs the public **DSN**.

## What CI already does

1. **Web** (`scripts/ci-build-web.sh`, `scripts/vercel-build.sh`): `flutter build web --source-maps` + dart-defines, then `scripts/sentry-upload.sh`.
2. **Android** (Codemagic `android_release` / `android_play_store`): release build with split debug info + optional upload.
3. Plugin config lives in `pubspec.yaml` under `sentry:` (`upload_source_maps`, `upload_debug_symbols`; `upload_sources: false` to avoid shipping full Dart sources).

## Alert rules — Edoardo must click in Sentry UI

No Sentry management API token is available to agents for this repo. Create these under **Alerts → Create Alert** (project → Alerts):

### 1) New high-priority issue

- **Type:** Issues
- **Condition:** A new issue is created
- **Filter (recommended):** `environment:production` and level error/fatal (or “is not handled” if available)
- **Action:** Email (and Slack if connected) to the owner
- **Why:** First signal when something new starts crashing in prod

### 2) Regression

- **Type:** Issues
- **Condition:** An issue changes state from resolved → unresolved (regression)
- **Filter:** `environment:production`
- **Action:** Email / Slack
- **Why:** Catches “we thought this was fixed” after a release

### 3) Error spike

- **Type:** Metric / Number of errors (wording varies by Sentry plan)
- **Condition:** Error count rises above a baseline (e.g. > N events in 1 hour) **or** use the built-in “spike” / anomaly template if present
- **Filter:** `environment:production`
- **Action:** Email / Slack
- **Why:** Catches volume jumps even when issues are already known

### Optional follow-ups

- Crash-free session drop (if Sessions / Release Health is enabled for the project).
- Connect **Slack** under Sentry → Settings → Integrations so alerts are not email-only.
- Confirm production DSN is the live project DSN (GitHub `SENTRY_DSN` + Codemagic + Vercel env).

## Manual verification after first upload

1. Deploy web with upload secrets set.
2. In Sentry → **Releases**, confirm `powercoach-studio@<version>` exists with artifacts / source maps.
3. Trigger a test error in a staging release (or temporary intentional throw) and confirm the stack is symbolicated.
4. Confirm alert emails fire with a test rule or Sentry’s “Send test notification”.

## Related paths

- Init: `lib/main.dart`, `lib/core/monitoring/sentry_release.dart`
- Upload: `scripts/sentry-upload.sh`, `sentry_dart_plugin` in `pubspec.yaml`
- Web CD: `.github/workflows/vercel-deploy.yml`, `docs/vercel-web-deploy.md`
- Android CD: `codemagic.yaml`, `docs/play-store-release-guide.md`

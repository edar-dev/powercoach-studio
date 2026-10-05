# Deploy PowerCoach Studio Web on Vercel

## Prerequisites

- Vercel project linked to this GitHub repository
- Supabase project with auth redirect URLs for your Vercel domain

## Environment variables (Vercel → Settings → Environment Variables)

| Variable | Required | Notes |
|----------|----------|-------|
| `SUPABASE_URL` | Yes | Supabase project URL (auth) |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon key (auth) |
| `SENTRY_DSN` | No | Optional error monitoring |
| `SENTRY_ENVIRONMENT` | No | e.g. `production` |
| `POSTHOG_API_KEY` | No | Optional web product analytics (empty = off) |
| `POSTHOG_HOST` | No | Local/default: `https://eu.i.posthog.com`. **Vercel production web:** `/pcs-ph` (first-party reverse proxy; baked by CI when secret unset) |
| `FLUTTER_VERSION` | No | Defaults to `3.35.6` in `scripts/vercel-build.sh` |

## Supabase auth

Add your Vercel URL(s) under **Authentication → URL configuration**:

- Site URL: `https://your-app.vercel.app`
- Redirect URLs: `https://your-app.vercel.app/**`

## Build

Vercel uses `vercel.json`:

- **Install command:** `bash scripts/vercel-install.sh` — Flutter SDK (`.flutter_sdk/`), `pub get`
- **Build command:** `bash scripts/vercel-build.sh` — Drift web assets, `.env`, `flutter build web`
- **Output:** `build/web`
- SPA rewrites route unmatched paths to `index.html`
- **PostHog reverse proxy** (before SPA): `/pcs-ph/static/*` and `/pcs-ph/array/*` → `eu-assets.i.posthog.com`; `/pcs-ph/*` → `eu.i.posthog.com`

Production CI uses `vercel deploy --prebuilt`, so the same PostHog routes are written into `.vercel/output/config.json` by `scripts/package-vercel-prebuilt.sh` (do not rely on `vercel.json` alone for prod).

### Build speed

| Phase | First deploy | Warm deploy (cache hit) |
|-------|--------------|-------------------------|
| Flutter SDK | ~60–90 s (clone + precache) | ~0 s (restored from cache) |
| `pub get` | ~15–30 s | ~5–10 s if `pubspec.lock` unchanged |
| `flutter build web` | ~60–90 s | ~60–90 s (always recompiles) |

Warm deploys are faster because:

1. Flutter SDK lives in `.flutter_sdk/` (not `/tmp`) and is restored via `build.json` cache.
2. Pub packages live in `.pub-cache/` and are restored between builds.
3. Drift `sqlite3.wasm` / `drift_worker.js` are downloaded only on the first build.

The compile step (`flutter build web`) still runs every time — that is expected for Flutter web.

### GitHub Actions (recommended)

Production deploys run via `.github/workflows/vercel-deploy.yml`:

1. `subosito/flutter-action` builds Flutter web (cached SDK, pub, and `.dart_tool`)
2. `scripts/package-vercel-prebuilt.sh` creates `.vercel/output`
3. `vercel deploy --prebuilt --prod` uploads static files only (~30–60 s on Vercel)

Vercel Git auto-deploy is disabled (`git.deploymentEnabled: false` in `vercel.json`) to avoid double builds.

**Required GitHub secrets** (Settings → Secrets and variables → Actions):

| Secret | Value |
|--------|-------|
| `VERCEL_TOKEN` | **Classic** personal access token from [Vercel account tokens](https://vercel.com/account/tokens) (OAuth/CLI session tokens do not work in CI) |
| `SUPABASE_URL` | Same value as Vercel Production env |
| `SUPABASE_ANON_KEY` | Same value as Vercel Production env |
| `SENTRY_DSN` | Optional |
| `SENTRY_ENVIRONMENT` | e.g. `production` |
| `POSTHOG_API_KEY` | Optional (web analytics) |
| `POSTHOG_HOST` | Optional; default `/pcs-ph` (first-party proxy). Set to absolute EU host only for non-proxy debugging. If an old secret still has `https://eu.i.posthog.com`, update it to `/pcs-ph` or delete the secret so the workflow default applies. |
| `VERCEL_ORG_ID` | Team/user ID from `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | Project ID from `.vercel/project.json` |

Manual CLI deploy still works with `npx vercel deploy --prod`.

## Web limitations

- Local notifications are disabled on web
- Import from device contacts is hidden on web
- Offline Drift uses IndexedDB (slower than native SQLite; adequate for coach workflows)

## Local web test

Drift web assets (`web/sqlite3.wasm`, `web/drift_worker.js`) are version-pinned in the repo. Build scripts only download them if missing (e.g. after a manual delete).

```bash
flutter run -d chrome
```

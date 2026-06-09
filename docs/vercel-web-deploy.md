# Deploy PowerCoach Studio Web on Vercel

## Prerequisites

- Vercel project linked to this GitHub repository
- Supabase project with auth redirect URLs for your Vercel domain

## Environment variables (Vercel → Settings → Environment Variables)

| Variable | Required | Notes |
|----------|----------|-------|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon key |
| `GYMBLOG_API_URL` | Yes | GymBlog.API base URL (CORS must allow the Vercel origin) |
| `SENTRY_DSN` | No | Optional error monitoring |
| `SENTRY_ENVIRONMENT` | No | e.g. `production` |
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
- SPA rewrites route all paths to `index.html`

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

1. `subosito/flutter-action` builds Flutter web (cached SDK + pub)
2. `scripts/package-vercel-prebuilt.sh` creates `.vercel/output`
3. `vercel deploy --prebuilt --prod` uploads static files only (~30–60 s on Vercel)

Vercel Git auto-deploy is disabled (`git.deploymentEnabled: false` in `vercel.json`) to avoid double builds.

**Required GitHub secrets** (Settings → Secrets and variables → Actions):

| Secret | Value |
|--------|-------|
| `VERCEL_TOKEN` | **Classic** personal access token from [Vercel account tokens](https://vercel.com/account/tokens) (OAuth/CLI session tokens do not work in CI) |
| `SUPABASE_URL` | Same value as Vercel Production env |
| `SUPABASE_ANON_KEY` | Same value as Vercel Production env |
| `GYMBLOG_API_URL` | Same value as Vercel Production env |
| `SENTRY_DSN` | Optional |
| `SENTRY_ENVIRONMENT` | e.g. `production` |
| `VERCEL_ORG_ID` | Team/user ID from `.vercel/project.json` |
| `VERCEL_PROJECT_ID` | Project ID from `.vercel/project.json` |

Manual CLI deploy still works with `npx vercel deploy --prod`.

## Web limitations

- Local notifications are disabled on web
- Import from device contacts is hidden on web
- Offline Drift uses IndexedDB (slower than native SQLite; adequate for coach workflows)

## Local web test

```bash
# Download drift web assets once
curl -fsSL -o web/sqlite3.wasm https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm
curl -fsSL -o web/drift_worker.js https://github.com/simolus3/drift/releases/download/drift-2.31.0/drift_worker.js

flutter run -d chrome
```

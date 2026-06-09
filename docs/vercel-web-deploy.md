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

- **Build command:** `bash scripts/vercel-build.sh`
- **Output:** `build/web`
- SPA rewrites route all paths to `index.html`

The build script installs Flutter, downloads Drift `sqlite3.wasm` / `drift_worker.js`, writes `.env` from Vercel env vars, and runs `flutter build web --release`.

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

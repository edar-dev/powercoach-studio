# Phase C — Mobile screenshot QA (optional)

Playwright harness that captures **mobile viewport** (default **390×844**) screenshots of authenticated hubs after a Supabase password-grant + `localStorage` session inject.

This **complements** Phase A (widget phone harness) and Phase B (`integration_test` emulator smokes). It does **not** replace them.

## Why capture + artifact (not hard pixel-diff)

Flutter web serves **CanvasKit**. Screenshots are useful for shell / hub chrome review, but pixel-perfect goldens flake on:

- CanvasKit antialiasing / GPU differences across machines
- Font metric drift between CI images and local hosts
- Transient overlays (`CloudRecoveryDialog`, analytics consent, empty vs seeded data)

So this tool **captures PNGs** (and uploads them as CI artifacts). Committed `baselines/` are **reference** shots. A soft **file-size advisory** warns when an artifact looks blank/broken relative to a baseline; it never fails the job for pixel noise.

## Hubs captured

| File | Route | Notes |
|------|-------|--------|
| `mobile-dashboard.png` | `/dashboard` | Today hub; may show cloud-recovery dialog if local cache empty |
| `mobile-customers.png` | `/customers` | Clients list |
| `mobile-builder.png` | `/workouts/builder` | Workout builder hub (day editor only if data exists) |
| `mobile-settings.png` | `/settings` | Settings shell — primary bottom bar **hidden** by design |

## Prerequisites

- Node **≥ 20**
- Flutter **3.35.6** (local serve) **or** a reachable web build (`QA_BASE_URL`)
- Env (never commit passwords):

| Variable | Required | Notes |
|----------|----------|--------|
| `SUPABASE_URL` | yes | From `.env` / CI secret |
| `SUPABASE_ANON_KEY` | yes | Anon/publishable key only |
| `NAV_QA_PASSWORD` | yes | Project QA password (preferences) — **not** in git |
| `NAV_QA_EMAIL` | no | Default `nav.qa@powerstudio.com` |
| `QA_BASE_URL` | no | Default `http://127.0.0.1:8080` |
| `QA_OUT_DIR` | no | Default `tool/qa/artifacts` |
| `QA_VIEWPORT_WIDTH` / `QA_VIEWPORT_HEIGHT` | no | Default `390` / `844` |

The script also reads repo-root `.env` for Supabase keys when present.

## Local run

```bash
# 1) Env
cp .env.example .env   # if needed; fill Supabase keys
export NAV_QA_PASSWORD='…'   # from project preferences — do not commit

# 2) Serve Flutter web (CanvasKit). Prefer a release build + SPA static server
#    (path URLs like /dashboard need index.html fallback).
flutter build web --release --no-wasm-dry-run
cd tool/qa && npm ci && npm run serve
# Alternative (debug): flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
# Do not wait for Playwright networkidle — DWDS websockets never go idle.

# 3) Capture (separate shell)
export NAV_QA_PASSWORD  # ensure set; never commit
cd tool/qa
npm run capture
```

Artifacts land in `tool/qa/artifacts/` (gitignored).

### Update committed baselines

After a known-good capture:

```bash
cd tool/qa
npm run capture:update-baselines
# or: node capture-mobile-hubs.mjs --update-baselines
```

Review the PNGs under `baselines/`, then commit.

## Optional CI

Workflow: `.github/workflows/mobile-screenshot-qa.yml`

- Triggers: `workflow_dispatch`, weekly schedule
- **Not** required on every PR
- Skips when `NAV_QA_PASSWORD` (or Supabase secrets) are unset
- Uploads `mobile-screenshot-qa` artifacts
- `continue-on-error: true` so the suite stays non-gating

Required GitHub Actions secrets (repository): `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `NAV_QA_PASSWORD`. Optional: `QA_BASE_URL` to point at a pre-deployed web build instead of building in the job.

## Limitations

- CanvasKit: DOM / XPath clicks on painted CTAs are weak — use **session inject + `goto` routes**, not Accedi automation.
- Screenshot diffs can flake — prefer human review of artifacts over blocking gates.
- Native safe-area / keyboard / touch geometry belong to Phase A/B, not this web capture.
- Day editor / Modifica blocco deep screens need seeded plans; empty builder hub is still a useful chrome check.

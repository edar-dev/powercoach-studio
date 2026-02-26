# powercoach_studio

PowerCoach Studio – Flutter app (Material 3) with landing, registration, login, coach profile, settings, and customers. Uses Supabase Auth and `public.profiles`; customers are managed via **GymBlog.API** when `GYMBLOG_API_URL` is set in `.env`.

## Environment

Copy `.env.example` to `.env` and fill in the values. Use the same `SUPABASE_URL` and `SUPABASE_ANON_KEY` as in **powercoach-studio-flutter** (same Supabase project). Optional: `GYMBLOG_API_URL` (base URL of GymBlog.API) for the customers section; if unset, the customers screen shows "API not configured".

```bash
cp .env.example .env
# Edit .env and set SUPABASE_URL and SUPABASE_ANON_KEY
```

## Monitoring (Sentry)

Logs, errors, and performance tracing are sent to [Sentry](https://sentry.io) when `SENTRY_DSN` is set in `.env`. Optional: `SENTRY_ENVIRONMENT` (default `development`).

- **Errors**: unhandled exceptions and `Sentry.captureException()` in auth/profile flows.
- **Tracing**: `tracesSampleRate: 1.0` and `SentryNavigatorObserver` for navigation spans.
- **Profiling**: `profilesSampleRate: 1.0` for performance profiles.
- **Screenshots**: attached to error events when supported.

Get the DSN from Sentry: **Project Settings → Client Keys (DSN)**. Leave `SENTRY_DSN` empty to disable Sentry.

## Database (Supabase)

The profile screen reads and writes `public.profiles` (columns: `display_name`, `contact_phone`, `bio`, `avatar_url`, `website`, etc.). The schema is managed by **GymBlog.API** via EF Core: when the API starts, it applies migrations that create or update the `profiles` table (including `contact_phone` and `website`). No separate Supabase SQL migration is required. If you use only the Flutter app and never start GymBlog.API, start the API once against your Supabase DB so EF applies the migrations, or add the columns manually in the Supabase SQL Editor (`contact_phone text`, `website text`).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

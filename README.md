# powercoach_studio

PowerCoach Studio – Flutter app (Material 3) with landing, registration, login, and coach profile. Uses Supabase Auth and `public.profiles`.

## Environment

Copy `.env.example` to `.env` and fill in the values. Use the same `SUPABASE_URL` and `SUPABASE_ANON_KEY` as in **powercoach-studio-flutter** (same Supabase project):

```bash
cp .env.example .env
# Edit .env and set SUPABASE_URL and SUPABASE_ANON_KEY
```

## Database (Supabase)

The profile screen reads and writes `public.profiles` (RLS: users can only access their own row). To add coach fields **phone** and **website**, run the migration in the Supabase SQL Editor or via `supabase db push`:

- `supabase/migrations/20260225000001_profiles_add_phone_website.sql`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

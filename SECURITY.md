# Security Policy

## Supported versions

Security fixes target the latest `main` branch of PowerCoach Studio (Flutter multi-platform app).

## Reporting a vulnerability

Please report sensitive vulnerabilities **privately** via [GitHub Security Advisories](https://github.com/edar-dev/powercoach-studio/security/advisories/new).

Do **not** open a public issue for secrets, auth bypasses, or data-exposure bugs.

We aim to acknowledge valid reports within a few business days and coordinate disclosure after a fix is available.

## In scope

- Flutter application code (`lib/`, platform shells)
- Authentication via Supabase (session only)
- Local backup/export/import and optional cloud snapshot flows
- User-supplied integration credentials (e.g. Hevy API keys stored locally), when present in the product

## Out of scope / expectations

- **Local-first business data:** customers, workouts, measurements, and related entities live on-device (Drift/SQLite + SharedPreferences). There is no remote business sync API; compromise of a device or exported backup file is outside “cloud SaaS” guarantees.
- **Supabase tables:** the product does not use Supabase for coach/client CRUD; table RLS on unused schemas is not a product security boundary for app data.
- **Self-hosted forks / modified builds:** no security guarantee for unofficial distributions.
- **Third-party services** (Supabase, Stripe, Vercel, Sentry, etc.): report issues to those vendors when the flaw is in their platform.

## Hardening notes for maintainers

See [docs/quality-security.md](docs/quality-security.md) for Dependabot, pinned GitHub Actions, and the human GitHub Security settings checklist.

# PowerCoach Studio - Agent Operating Guide

## Goal
- Deliver production-ready Flutter changes with minimal regressions.
- Prefer small, testable edits over broad refactors.
- Keep UX behavior stable unless the task explicitly asks for a behavior change.

## Architecture constraints (non-negotiable)
- **Cloud SoT (coach entities):** business entities live in Supabase `public.coach_entities` (JSONB). Writes require an authenticated session and a successful remote upsert/soft-delete before the UI treats the change as saved. No offline outbox in v1.
- **Drift = cache:** `OfflineLocalStore` / SQLite holds a per-user cache; after pull, replace cache per entity type. Reads may prefer cache then refresh.
- **Prefs / PDF brand / pins:** stay on SharedPreferences (not Postgres) in v1.
- **Supabase client:** anon key + user JWT only — never embed the service role in the app. RLS on `coach_entities` is `user_id = auth.uid()` for SELECT/INSERT/UPDATE/DELETE.
- **No GymBlog.API**, no `GYMBLOG_API_URL`, no remote sync replay / outbox unless an approved plan explicitly reintroduces it.
- **No third-party workout APIs** (Hevy and similar integrations were removed; do not reintroduce without an approved plan).
- **Backup/restore:** JSON export/import remains disaster recovery; restore must write to Supabase and refresh Drift cache (see `docs/sync-strategy.md`).
- **Data catalog:** in-repo registry at `lib/core/data_catalog/` — see `docs/data-catalog.md`. Optional OM spike under `tool/openmetadata/`. Read-only quality scanner: `lib/core/data_quality/` (run against pulled/backup data).
- **Removed product surfaces (do not reintroduce without a plan):** gym hub, plan-diff, coach stats, release notes, density/EMOM blocks, progression chips, session check-in RPE/pain, Day coaching notes, manual ReminderStore, exercise PR records, Hevy.
- **Entity types in `coach_entities`:** `customer`, `workoutPlan`, `measurement`, `customExercise`, `customerNote` (legacy `exerciseRecord` was removed from Drift and is not uploaded).

## CI / Flutter version
- CI pins **Flutter 3.35.6** (`.flutter-version`, GitHub Actions, Codemagic).
- Match this version locally before substantive work (`fvm use` or equivalent).
- After edits: `flutter analyze` and `flutter test test/`.
- If Drift tables or ARB files change: `dart run build_runner build --delete-conflicting-outputs`.

## Branch policy
- Implement approved plans on a **new branch from `main`** — never commit plan work directly on `main`.
- Branch format: `<type>/<scope>-<short-description>` (e.g. `refactor/split-mobility-builder-screen`).

## Required Workflow
1. Map the target area before editing (files, state flow, dependencies).
2. Implement with existing architecture and naming patterns.
3. Run validation commands after substantive edits.
4. Report what changed, why, and how it was verified.

## Flutter Guardrails
- Follow existing feature-based structure under `lib/features/*`.
- **Routing:** important screens use dedicated top-level paths; constants in `lib/core/routing/app_paths.dart` (see `.cursor/rules/15-dedicated-routes.mdc`).
- Keep business logic outside widgets when complexity grows.
- Reuse theme tokens and shared UI components before adding new styles.
- Avoid introducing new dependencies unless clearly justified.

## Verification Checklist
- Run `flutter analyze`.
- Run focused tests for touched features when available.
- If models/schema changed, run required code generation.

## Team Quality Gates (Definition of Done)
- Behavior is validated for happy path plus key edge states (loading, empty, error).
- New logic is covered by focused tests when testable in reasonable scope.
- No architecture drift: changes align with existing module boundaries.
- Handoff includes explicit risk notes and clear verification evidence.

## Subagent Delegation Defaults
- Use `flutter-explorer` before implementation when touching unfamiliar or multi-file areas.
- Use `flutter-implementer` for multi-file feature work, refactors, and bug fixes.
- Use `flutter-test-runner` after substantive edits to run analyze/tests/codegen.
- Use `flutter-reviewer` before final handoff for regression/risk checks.
- For files **>300 lines** or multi-file refactors: explorer → implementer → test-runner → reviewer.

## Active implementation plans
See `.cursor/plans/README.md` for the current plan index and execution order.

## Commit and PR Hygiene
- Keep commits scoped to one logical change.
- Use imperative commit titles and explain "why" in body when non-obvious.
- Before opening a PR, include: scope summary, risk assessment, and test evidence.
- Prefer small PRs over large mixed refactors.

## Output Expectations
- Explain changes by file path and intent.
- Call out risks, assumptions, and follow-up actions.
- Keep responses concise and actionable.

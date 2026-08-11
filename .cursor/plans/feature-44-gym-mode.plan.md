---
name: feature-44-gym-mode
overview: "Wave 2 PR1 — Gym mode: full-screen session runner at `/gym`, today list, large tap targets, reuse session log path (no new persist layer)."
todos:
  - id: route-path
    content: "AppPaths.gym + top-level GoRoute `/gym`; auth guard; entry from dashboard/settings shortcut"
    status: completed
  - id: today-list
    content: "GymModeScreen — lista sessioni oggi da DashboardSnapshot/CalendarEventLoader; card tap grandi"
    status: completed
  - id: session-runner
    content: "Runner full-screen per sessione selezionata — checklist esercizi, CTA Registra apre session_log_sheet"
    status: completed
  - id: reuse-log-path
    content: "Salvataggio via showSessionLogSheet + SessionExecutionService esistenti; nessun fork codec"
    status: completed
  - id: l10n-tests
    content: "l10n gymMode*; widget test today list + log CTA; route redirect test"
    status: completed
isProject: false
---

# Feature 44 — Gym mode (full-screen session runner)

## Obiettivo

UI **sala dedicata** per il coach in sessione: tap grandi, lista **oggi**, runner full-screen — estende il session log esistente senza nuova persistenza.

## Routing

- Top-level path: **`/gym`** (`AppPaths.gym`)
- Registrare in [`app_routes.dart`](../../lib/core/routing/app_routes.dart) con `parentNavigatorKey: appRootNavigatorKey` (copre shell)
- Proteggere in [`route_redirect.dart`](../../lib/core/routing/route_redirect.dart)
- Entry points: shortcut da dashboard today section, optional tile settings/coach tools

## Schermata principale

Nuovo [`gym_mode_screen.dart`](../../lib/features/workouts/presentation/screens/gym_mode_screen.dart) (o sotto `dashboard/` se preferito discoverability):

1. **Header** — titolo + data odierna + back/exit gym mode
2. **Today list** — riusa dati come [`dashboard_today_section.dart`](../../lib/features/dashboard/presentation/widgets/dashboard_today_section.dart) / `DashboardSnapshot.todayItems`
3. **Card sessione** — cliente, piano/giorno, tap target min 48dp; tap → runner

## Session runner (full-screen)

- Mostra esercizi del giorno (read-only checklist) con progress indicator
- CTA primaria **Registra sessione** → `showSessionLogSheet` ([`session_log_sheet.dart`](../../lib/features/workouts/presentation/widgets/session_log_sheet.dart))
- Post-save: snackbar + opzione apri diario; resta in gym mode
- Riutilizzare [`exercise_add_compact_sheet.dart`](../../lib/features/workouts/presentation/widgets/exercise_add_compact_sheet.dart) solo se serve add-on-the-fly (optional scope cut)

## Riuso session log path

**Non** duplicare persistenza:

- Draft: `buildSessionLogDrafts` + `SessionLogResult`
- Save: `SessionExecutionService` esistente
- Check-in RPE/pain (F40) e set enriched (F35) restano nel sheet

## UX constraints

- Large targets, high contrast, minimal chrome
- Offline-first (solo Drift locale)
- Mobile-first; desktop OK con layout centrato max-width

## Test

- Route redirect authenticated `/gym`
- Widget: today list empty vs populated
- Integration: tap session → sheet mock → save callback

## Branch

`feat/identity-wave2`

## Dipendenze

- Wave 1 ✅ (session log enriched + check-in)
- Indipendente da F45 (plan diff)

## Scope escluso

- Nuova tabella Drift o schema JSON piano
- Timer EMOM/circuit (Wave 3 density)
- App atleta / sync live

## Definition of done

- Coach naviga a `/gym`, vede sessioni di oggi, completa log via sheet esistente
- `flutter analyze` + test routing/widget rilevanti

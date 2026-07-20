---
name: feature-39-release-notes-screen
overview: "Feature post-v5 — Schermata statica Novità / Release notes in-app con catalogo versioni e storico retroattivo (1.0.1 → 1.0.7)."
todos:
  - id: release-notes-model
    content: "release_notes_catalog.dart — modello ReleaseNoteEntry (version, date, highlight keys) + lista ordinata"
    status: completed
  - id: retroactive-content
    content: "Popolare catalogo retroattivo 1.0.1–1.0.7 (vedi appendix) + allineare kAppVersionLabel / pubspec"
    status: completed
  - id: release-notes-screen
    content: "release_notes_screen.dart — timeline scrollabile, badge versione corrente, sezioni per release"
    status: completed
  - id: route-settings-entry
    content: "Route /settings/release-notes + ListTile in settings_screen_content + route_redirect protetta"
    status: completed
  - id: l10n
    content: "releaseNotesTitle, releaseNotesCurrentVersion, releaseNotesEmpty; chiavi bullet per ogni release IT/EN"
    status: completed
  - id: tests
    content: "Widget test schermata + unit test catalog sort/filter; smoke tap da settings"
    status: completed
isProject: false
---

# Feature 39 — Release notes screen

## Obiettivo prodotto

Il coach può consultare **cosa è cambiato** nell’app senza uscire da PowerCoach Studio: una pagina statica, leggibile, con **storico retroattivo** delle release principali.

Use case:

- Dopo un aggiornamento Play Store / web deploy → “Cosa c’è di nuovo?”
- Onboarding leggero per coach che tornano dopo mesi
- Trasparenza su feature v3/v4/v5 già rilasciate

## Stato attuale

| Esiste | Manca |
|--------|--------|
| `kAppVersionLabel` in [`app_info.dart`](lib/core/constants/app_info.dart) (`1.0.7`) | Schermata release notes |
| Versione in `pubspec.yaml` (`1.0.7+8`) | Catalogo changelog in-app |
| Settings con sezioni backup / lingua / Hevy | Entry “Novità” o “Release notes” |
| Play Store guide (`docs/play-store-release-guide.md`) menziona release notes **store** | Contenuto user-facing in-app |

Nessuna pagina “About” oggi; **entry point consigliato: Impostazioni** (coerente con backup, lingua, integrazioni).

## Design — Information architecture

```
Impostazioni
  └── Novità / Release notes  →  /settings/release-notes

┌─────────────────────────────────────┐
│ ←  Novità                           │
├─────────────────────────────────────┤
│ Versione installata: 1.0.7          │
├─────────────────────────────────────┤
│ ▼ 1.0.7 · Lug 2026                  │
│   • Hub coach: diario e statistiche │
│   • Export progresso cliente (CSV)    │
│   • ...                             │
│ ▼ 1.0.6 · Giu 2026                  │
│   • Backup selettivo                  │
│   • ...                             │
│ ...                                 │
└─────────────────────────────────────┘
```

- **Ordine:** più recente in alto
- **Highlight:** 3–6 bullet per release (non changelog git completo)
- **Lingua:** IT primaria + EN via l10n (come resto app)
- **Statico:** nessuna API; contenuto bundled nel binary/web asset

## Design — Implementazione tecnica

### Catalogo (single source of truth)

Nuovo modulo `lib/core/release_notes/`:

```dart
class ReleaseNoteEntry {
  const ReleaseNoteEntry({
    required this.version,
    required this.releaseDate, // DateTime UTC o locale-neutral Y-M-D
    required this.highlightKeys, // List<String> → AppLocalizations getters
  });

  final String version;
  final DateTime releaseDate;
  final List<String> highlightKeys;
}

/// Ordinato desc per semver (1.0.7, 1.0.6, …).
const kReleaseNotesCatalog = <ReleaseNoteEntry>[ ... ];
```

**Perché l10n keys e non stringhe inline:** IT/EN già obbligatori; evita duplicazione in widget.

Alternativa accettabile per MVP: `ReleaseNoteEntry` con `highlightsIt` / `highlightsEn` in un unico file Dart (meno boilerplate ARB). **Preferenza piano: ARB** per coerenza progetto.

Helper:

```dart
String? currentReleaseNoteVersion() => kAppVersionLabel;

ReleaseNoteEntry? entryForInstalledVersion() =>
    kReleaseNotesCatalog.where((e) => e.version == kAppVersionLabel).firstOrNull;
```

### Schermata

- `lib/features/settings/presentation/screens/release_notes_screen.dart`
- `StitchSecondaryAppBar` + `ListView` di card espandibili (prima release expanded by default se = versione installata)
- Widget riusabile: `ReleaseNoteCard` in `lib/features/settings/presentation/widgets/`

### Routing

In [`app_routes.dart`](lib/core/routing/app_routes.dart):

```dart
GoRoute(
  path: 'release-notes',
  parentNavigatorKey: appRootNavigatorKey,
  builder: (context, state) => const ReleaseNotesScreen(),
),
```

Sotto `/settings` (come `personal-info`, `subscription`).

[`route_redirect.dart`](lib/core/routing/route_redirect.dart): già coperto da prefix `/settings`.

### Entry UI

In [`settings_screen_content.dart`](lib/features/settings/presentation/widgets/settings_screen_content.dart):

- `ListTile` con icona `Icons.new_releases_outlined` **prima** del divider backup o in fondo sezione “Info app”
- Subtitle opzionale: `releaseNotesSettingsSubtitle` → “Versione 1.0.7”

### Versione installata

Allineare sempre:

| File | Campo |
|------|--------|
| `pubspec.yaml` | `version: 1.0.7+8` |
| `lib/core/constants/app_info.dart` | `kAppVersionLabel` |
| `kReleaseNotesCatalog` | entry `1.0.7` presente |

Opzionale: leggere versione da `package_info_plus` (già in pubspec) per display runtime — **non obbligatorio v1** se `kAppVersionLabel` basta.

## Release notes retroattive (contenuto da implementare)

Appendice operativa per popolare catalogo + l10n. Date indicative (milestone prodotto / merge main).

### 1.0.7 — Luglio 2026 (v5 complete)

**Tema:** discoverability + polish coach quotidiano

- Hub coach: card Diario e Statistiche dalla dashboard; menu su agenda completa
- Da scheda cliente: apri diario filtrato per cliente
- Export CSV riepilogo progresso (aderenza, PR, misure) da overview cliente
- Pannello superset dedicato nel workout builder (anteprima compatta + editor)
- Session log arricchito: reps e carico per serie nel foglio sessione

### 1.0.6 — Giugno 2026 (v5 core)

**Tema:** profondità dati coach

- Backup: restore selettivo per categorie + metadata export (`exportedAt`, conteggi entità)
- Diario workout v2: filtri data/stato, dettaglio sessione navigabile
- Statistiche coach: grafico aderenza giornaliera + export CSV KPI
- Miglioramenti presentation-split builder (sheet esercizi, tab training)

### 1.0.5 — Maggio 2026 (v4 intelligence)

**Tema:** esecuzione sessioni e aderenza

- Modello esecuzione sessione (completata / saltata / pianificata) persistito in locale
- Diario workout e statistiche coach (MVP)
- Pannello progresso cliente: aderenza 30 giorni, PR recenti, strip 4 settimane
- Promemoria sessioni collegati al calendario piani
- Follow-up cliente basato su dati di esecuzione reali
- Backup/restore account v2 (envelope JSON esteso)

### 1.0.4 — Aprile 2026 (v3 workflow)

**Tema:** affidabilità flusso coach

- Overview cliente con metriche reali da misure (sparkline, trend 30 gg)
- Picker esercizi: recenti e preferiti in libreria
- Dettaglio sessione calendario con dati piano reali
- Override per singola occorrenza sessione (ripianifica senza mutare il piano)
- Ciclo di vita piano (bozza, attivo, completato, archiviato)
- Refactor builder fase 2–3 (tab, handler, dialog sheet)

### 1.0.3 — Marzo 2026 (local-first)

**Tema:** architettura locale-first

- Dati business solo locali (Drift); Supabase solo autenticazione
- Rimozione UX sync cloud obsoleta; test backfill tier 2/3
- Repository prefs e profilo coach locali
- Migrazione offline store modulare

### 1.0.2 — Febbraio 2026

**Tema:** builder e template

- Libreria template piani workout
- Autosave editor piano + guard uscita con modifiche non salvate
- Export piano PDF / JSON / Excel
- Integrazione Hevy (export verso calendario / libreria)

### 1.0.1 — Gennaio 2026

**Tema:** MVP coach

- Dashboard “Oggi” e agenda sessioni
- Gestione clienti, misure, record esercizi
- Workout builder (settimane/giorni/esercizi, superset base)
- Calendario coach e assegnazione piani
- Notifiche locali e promemoria
- Localizzazione IT/EN end-to-end
- Backup export/import JSON account

> **Nota editoriale:** i numeri 1.0.1–1.0.6 sono **raggruppamenti prodotto** allineati a roadmap v3/v4/v5; solo `v1.0.1` e `v1.0.3` esistono come tag git. Il catalogo in-app usa semver marketing coerente con `pubspec.yaml`; non serve taggare retroattivamente ogni versione.

## l10n — chiavi suggerite

| Key | IT | EN |
|-----|----|----|
| `releaseNotesTitle` | Novità | What's new |
| `releaseNotesInstalledVersion` | Versione installata: {version} | Installed version: {version} |
| `releaseNotesSettingsSubtitle` | Scopri le ultime funzionalità | See the latest features |
| `releaseNotesHighlightsLabel` | In evidenza | Highlights |

Bullet per release (pattern):

- `releaseNotes_v107_1` … `releaseNotes_v107_5`
- `releaseNotes_v106_1` …
- (oppure un ARB file dedicato `app_release_notes_it.arb` se troppe chiavi)

## Test

| Test | Scope |
|------|--------|
| `release_notes_catalog_test.dart` | Ordine semver desc; ogni entry ha ≥1 highlight; versione 1.0.7 presente |
| `release_notes_screen_test.dart` | Render titolo + almeno N release; versione installata visibile |
| `settings_screen_test.dart` (opz.) | Tap “Novità” → route release-notes |

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Drift contenuto vs store listing | Checklist release: aggiornare catalogo + Play Console notes insieme |
| Explosion chiavi l10n | Max 5 bullet/release; file ARB dedicato opzionale |
| Version mismatch pubspec vs kAppVersionLabel | Test unit che assertano uguaglianza major.minor.patch |
| Pagina “statica” obsoleta | Processo: ogni bump `pubspec` → nuova entry catalogo (documentare in `docs/play-store-release-guide.md`) |

## Definition of done

- Route `/settings/release-notes` navigabile da Impostazioni
- Catalogo retroattivo **1.0.1 → 1.0.7** visibile in UI
- Versione installata mostrata in header
- i18n IT/EN per titoli e bullet
- `flutter analyze` + test mirati verdi
- (Opzionale follow-up) Badge “Novità” su ListTile finché l’utente non apre la pagina dopo upgrade — **out of scope v1**

## Branch suggerito

`feat/release-notes-screen`

## Follow-up (non in scope v1)

- Deep link `powercoach://release-notes`
- Markdown renderer per note lunghe
- `package_info_plus` per versione runtime
- Highlight automatico release corrente post-update (SharedPreferences `lastSeenReleaseNotesVersion`)
- Sezione release notes in drawer dashboard

## Riferimenti

- Roadmap completate: [`feature-roadmap-v5.plan.md`](feature-roadmap-v5.plan.md), v4, v3
- Play Store process: [`docs/play-store-release-guide.md`](../../docs/play-store-release-guide.md)
- Version constant: [`lib/core/constants/app_info.dart`](../../lib/core/constants/app_info.dart)

---
name: platform-ci-docs-v1
overview: "Allineare Flutter/CI tra GitHub e Codemagic, eliminare riferimenti GymBlog obsoleti nella documentazione e nei workflow, e rendere la doc coerente con l'architettura local-first."
todos:
  - id: flutter-version-pin
    content: "Aggiungere .flutter-version (3.35.6) e documentare in README la regola dev=CI"
    status: pending
  - id: codemagic-flutter-pin
    content: "Sostituire flutter: stable con versione pinata 3.35.6 in codemagic.yaml (tutti e 3 workflow)"
    status: pending
  - id: dedupe-pr-ci
    content: "Rimuovere pr_quality_gate da Codemagic o disabilitarlo — GitHub Actions resta unico gate PR"
    status: pending
  - id: purge-gymblog-vercel
    content: "Rimuovere GYMBLOG_API_URL da vercel-deploy.yml e docs/vercel-web-deploy.md"
    status: pending
  - id: update-play-store-guide
    content: "Aggiornare docs/play-store-release-guide.md — rimuovere GYMBLOG, allineare env vars a README"
    status: pending
  - id: archive-feature-gap
    content: "Spostare design/FEATURE_GAP_ANALYSIS.md in docs/archive/ con banner obsolescenza + link README"
    status: pending
  - id: readme-ci-section
    content: "Estendere README sezione CI con pin Flutter, matrice workflow, link guide aggiornate"
    status: pending
  - id: verify-ci
    content: "Push su branch test → verificare Flutter CI + Vercel Deploy + android_release Codemagic verdi"
    status: pending
isProject: false
---

# Platform, CI & Docs v1

## Punti coperti

| # roadmap | Descrizione |
|-----------|-------------|
| **6** | Allineare Flutter ovunque |
| **9** | Pulizia documentazione |

## Obiettivo

Eliminare drift tra CI, dev locale e documentazione. Prevenire regressioni come `onReorderItem` vs `onReorder` (Flutter 3.35.6 vs 3.44+).

## Stato attuale

| Fonte | Flutter | Problema |
|-------|---------|----------|
| GitHub Actions | `3.35.6` pinato | OK |
| Codemagic | `stable` | Può divergere |
| Dev locale | Nessun pin | Drift silenzioso |
| Docs | GymBlog, cache API, sync remoto | Contraddicono README |

## Implementazione

### 1) Pin Flutter

```text
.flutter-version          → 3.35.6
README.md                 → sezione "Dev environment"
codemagic.yaml            → environment.flutter: 3.35.6 (×3 workflow)
```

Opzionale: aggiungere nota FVM in README (`fvm use`).

### 2) Deduplicare CI PR

**Prima:** PR → GitHub `flutter-ci.yml` + Codemagic `pr_quality_gate` (doppio analyze/test).

**Dopo:**

- **GitHub Actions** — gate PR: analyze + `flutter test test/`
- **Codemagic** — solo `android_release` (push main) + `android_play_store` (tag `v*`)

Rimuovere o commentare `pr_quality_gate` in `codemagic.yaml` con nota che punta a GitHub.

### 3) Purge GymBlog da docs e CI

| File | Azione |
|------|--------|
| `.github/workflows/vercel-deploy.yml` | Rimuovere `GYMBLOG_API_URL` env |
| `docs/vercel-web-deploy.md` | Aggiornare tabella env (solo Supabase + Sentry) |
| `docs/play-store-release-guide.md` | Rimuovere `GYMBLOG_API_URL` da sezione 4 |
| `design/FEATURE_GAP_ANALYSIS.md` | Archiviare in `docs/archive/FEATURE_GAP_ANALYSIS.md` con banner |

Banner esempio:

```markdown
> **Obsoleto (2026-07)** — descrive architettura pre local-first. Vedi README.md e docs/sync-strategy.md.
```

### 4) README — matrice CI aggiornata

| Trigger | Pipeline | Output |
|---------|----------|--------|
| PR → main | GitHub Flutter CI | analyze + test |
| Push → main | GitHub Vercel Deploy | web production |
| Push → main | Codemagic android_release | APK + AAB |
| Tag `v*` | Codemagic android_play_store | Play internal |

## Ordine PR suggerito

1. `chore/flutter-version-pin` — `.flutter-version` + Codemagic + README
2. `chore/dedupe-codemagic-pr-gate` — rimuove `pr_quality_gate`
3. `docs/purge-gymblog-ghosts` — docs + vercel workflow + archive

## Verifica

```bash
flutter analyze
flutter test test/
# Su branch: verificare Actions + (opzionale) trigger Codemagic android_release
```

## Rischi

- Codemagic `stable` → pin può richiedere re-run manuale per validare Android build.
- Secret `GYMBLOG_API_URL` in GitHub/Vercel — rimuovere solo dalla doc/workflow; eliminare secret manualmente in dashboard se presente.

## Dipendenze

- Nessuna. **Eseguire per primo** — sblocca agent e dev accurati.
- Piano [`agent-tooling-v1`](agent-tooling-v1.plan.md) può procedere in parallelo.

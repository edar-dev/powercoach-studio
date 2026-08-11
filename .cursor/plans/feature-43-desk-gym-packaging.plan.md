---
name: feature-43-desk-gym-packaging
overview: "Wave 1 PR4 — Packaging claim + desk→gym: FAQ, landing, settings backup subtitle, onboarding (solo l10n, niente sync)."
todos:
  - id: landing-faq
    content: "Nuova FAQ desk→gym + raffinare landingFaqLocalData*"
    status: completed
  - id: settings-copy
    content: "Settings backup subtitle: claim + Hevy key excluded"
    status: completed
  - id: onboarding-line
    content: "Onboarding backup: una riga desk→gym"
    status: completed
  - id: no-nag-dup
    content: "Evitare doppio nag vs backup_reminder_banner"
    status: completed
  - id: tests
    content: "Smoke test stringhe landing/settings"
    status: completed
isProject: false
---

# Feature 43 — Desk→gym / claim packaging

## Obiettivo

Comunicare il claim **“Your data stays yours”** e il flusso **desk → gym** via backup/snapshot — senza nuovo sync.

## Superfici

- Landing FAQ desk→gym
- Settings: sottotitolo sezione backup (claim + Hevy key esclusa)
- Onboarding backup: riga desk→gym
- Evitare overlap con [`backup_reminder_banner.dart`](../../lib/features/dashboard/presentation/widgets/backup_reminder_banner.dart)

## Scope escluso

- Nessuna nuova integrazione sync
- Solo l10n + copy su superfici esistenti

## Test

- Smoke landing/settings stringhe

## Branch

`feat/identity-wave1-desk-gym-copy`

## Dipendenze

Parallelo a F41/F42; nessun blocco tecnico.

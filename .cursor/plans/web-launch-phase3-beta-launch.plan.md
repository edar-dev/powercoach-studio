---
name: web-launch-phase3-beta-launch
overview: "Web launch Phase 3 — landing commerciale, beta coach, polish PWA e FAQ."
todos:
  - id: landing-pricing-faq
    content: "Sezione pricing Free/Pro + FAQ local-first/beta/billing su landing"
    status: completed
  - id: landing-beta-cta
    content: "Badge beta, CTAs tier-aware, link Prezzi in app bar"
    status: completed
  - id: landing-footer-pwa
    content: "Footer legal + hint PWA web + manifest description"
    status: completed
  - id: subscription-checkout-wire
    content: "Stripe checkout buttons su subscription + snackbar ?checkout=success|cancel"
    status: completed
  - id: phase3-qa
    content: "Widget test landing pricing + flutter analyze"
    status: completed
isProject: false
---

# Web Launch Phase 3 — Beta & GTM

## Obiettivo

Rendere la landing **commerciale e chiara** per coach beta: prezzi visibili, percorso invito, FAQ su dati locali, footer legal, hint installazione PWA.

**Prerequisito:** Phase 2 billing mergiata (#90–#95).

## Deliverable

| Item | File |
|------|------|
| Pricing Free/Pro | `landing_pricing_section.dart` |
| FAQ | `landing_faq_section.dart` |
| Beta badge + CTAs | `landing_screen.dart`, `landing_screen_app_bar.dart` |
| PWA copy | `landing_pwa_hint_section.dart`, `web/manifest.json` |
| Legal footer | `landing_footer_section.dart` |
| Stripe upgrade | `subscription_upgrade_card.dart`, `subscription_screen.dart` |

## Branch

`feat/web-launch-phase3-landing` — ✅ mergiata.

## QA manuale post-deploy

- [x] Landing `/` — scroll Prezzi, FAQ, footer (shipped)
- [ ] Registrazione → Abbonamento → checkout Stripe (web) — re-check after deploys
- [ ] Richiesta codice invito beta
- [ ] Install hint visibile su web

---
name: web-launch-roadmap
overview: "Roadmap lancio web clienti paganti — Phase 1 trust (done), Phase 2 billing, Phase 3 beta/GTM."
todos:
  - id: phase1-trust-legal
    content: "Phase 1 — logout sicuro, legal in-app, onboarding backup (#89 merged)"
    status: completed
  - id: phase2-billing
    content: "Phase 2 — Stripe + paywall Free/Pro (web-launch-phase2-billing.plan.md)"
    status: completed
  - id: phase3-beta-launch
    content: "Phase 3 — landing pricing, beta coach, cross-browser polish, PWA copy"
    status: completed
isProject: false
---

# Web launch roadmap

Canale: **https://powercoach-studio.vercel.app** (web only; Android/iOS futuro).

| Fase | Piano | Stato |
|------|-------|--------|
| **1 — Trust & legal** | Merged in [#89](https://github.com/edar-dev/powercoach-studio/pull/89) | ✅ Done |
| **2 — Billing & paywall** | [web-launch-phase2-billing.plan.md](web-launch-phase2-billing.plan.md) | ✅ Done (#90–#95) |
| **3 — Beta & GTM** | [web-launch-phase3-beta-launch.plan.md](web-launch-phase3-beta-launch.plan.md) | ✅ Done |

## Modello commerciale

**Local-first a pagamento (A):** dati su IndexedDB; abbonamento Pro via **Stripe**; entitlements su Supabase (solo billing).

## Ordine implementazione

```
Phase 1 ✅ → Phase 2 (Stripe) → Phase 3 (launch beta)
```

Vedi `.cursor/rules/14-plan-implementation-branching.mdc` per policy branch.

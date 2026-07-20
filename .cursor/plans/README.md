# PowerCoach Studio — Implementation Plans

Indice dei piani attivi per miglioramenti architetturali, tech debt, test e agent tooling.

## Workout builder UX (completata)

Analisi: [`docs/workout-builder-ux-analysis.md`](../docs/workout-builder-ux-analysis.md)

| Fase | Plan | Backlog ID |
|------|------|------------|
| **Roadmap** | [workout-builder-ux-roadmap](workout-builder-ux-roadmap.plan.md) | WB-01 … WB-22 |
| **1** | [workout-builder-ux-phase1-trust](workout-builder-ux-phase1-trust.plan.md) | WB-01 … WB-05 |
| **2** | [workout-builder-ux-phase2-coach-flow](workout-builder-ux-phase2-coach-flow.plan.md) | WB-06 … WB-12, WB-21 |
| **3** | [workout-builder-ux-phase3-advanced](workout-builder-ux-phase3-advanced.plan.md) | WB-13 … WB-22 |

## Web launch

| Fase | Plan | Stato |
|------|------|-------|
| **1** | Trust/legal (#89) | ✅ |
| **2** | [web-launch-phase2-billing](web-launch-phase2-billing.plan.md) | ✅ |
| **3** | [web-launch-phase3-beta-launch](web-launch-phase3-beta-launch.plan.md) | 🚧 branch `feat/web-launch-phase3-landing` |

```mermaid
flowchart LR
  WL1[web launch phase 1]
  WL2[phase 2 billing]
  WL3[phase 3 beta GTM]
  WL1 --> WL2 --> WL3
```

---

## Plan attivi prodotto (workout builder UX) — storico dettaglio

| Fase | Plan | Backlog ID | PR stimati |
|------|------|------------|------------|
| **Roadmap** | [workout-builder-ux-roadmap](workout-builder-ux-roadmap.plan.md) | WB-01 … WB-22 | — |
| **1** | [workout-builder-ux-phase1-trust](workout-builder-ux-phase1-trust.plan.md) | WB-01 … WB-05 | 2–3 |
| **2** | [workout-builder-ux-phase2-coach-flow](workout-builder-ux-phase2-coach-flow.plan.md) | WB-06 … WB-12, WB-21 | 4–5 |
| **3** | [workout-builder-ux-phase3-advanced](workout-builder-ux-phase3-advanced.plan.md) | WB-13 … WB-22 | 5+ |

```mermaid
flowchart LR
  WB[workout-builder-ux-roadmap]
  P1[phase1-trust]
  P2[phase2-coach-flow]
  P3[phase3-advanced]
  WB --> P1 --> P2 --> P3
```

**Stato:** roadmap workout builder completata (PR #99–#103).

---

## Ordine di esecuzione consigliato

```mermaid
flowchart LR
  P1[1 platform-ci-docs-v1]
  P1b[1 agent-tooling-v1]
  P2[2 local-first-ux-v1]
  P2b[2 test-backfill-v1]
  P3[3 data-layer-v1]
  P4[4 presentation-split-v1]
  P1 --> P2
  P1b --> P2
  P1 --> P2b
  P2 --> P3
  P2 --> P4
  P3 --> P4
```

| Fase | Plan | Punti roadmap | PR stimati |
|------|------|---------------|------------|
| **1** | [platform-ci-docs-v1](platform-ci-docs-v1.plan.md) | 6, 9 | 3 |
| **1** | [agent-tooling-v1](agent-tooling-v1.plan.md) | 10, 11, 12, 13 | 3 |
| **2** | [local-first-ux-v1](local-first-ux-v1.plan.md) | 1(A), 5 | 4 |
| **2** | [test-backfill-v1](test-backfill-v1.plan.md) | 8 | 5–6 |
| **3** | [data-layer-v1](data-layer-v1.plan.md) | 3, 4 | 6 |
| **4** | [presentation-split-v1](presentation-split-v1.plan.md) | 2 | 5 |

## Mapping punti → plan

| # | Tema | Plan |
|---|------|------|
| 1 (A) | Rimuovere UX sync, backup come multi-device | local-first-ux-v1 |
| 2 | Spezzare mega-screen | presentation-split-v1 |
| 3 | God-object data layer | data-layer-v1 |
| 4 | Repository domain settings/auth | data-layer-v1 |
| 5 | Dead API (skipCache, l10n GymBlog) | local-first-ux-v1 |
| 6 | Pin Flutter CI/dev | platform-ci-docs-v1 |
| 8 | Test backfill | test-backfill-v1 |
| 9 | Doc cleanup | platform-ci-docs-v1 |
| 10 | Plan archive + AGENTS.md | agent-tooling-v1 |
| 11 | Hook cross-platform | agent-tooling-v1 |
| 12 | Regola anti-sync remoto | agent-tooling-v1 |
| 13 | Subagent routing | agent-tooling-v1 |

## Plan superseded / archived

Spostare in `archive/` (già fatto per i plan completati/superseded):

| Plan | Stato | Sostituito da |
|------|-------|---------------|
| `archive/feature-30-sync-strategy-v2.plan.md` | superseded | local-first-ux-v1 |
| `archive/local-only-auth-refactor_91727a50.plan.md` | completed | — |

I plan feature roadmap (`feature-01` … `feature-31`) restano come storico prodotto; non vanno rieseguiti se già completati.

## Come implementare un plan

1. Leggere il plan completo e i todo in frontmatter.
2. Sync `main` + creare branch (`feat/`, `refactor/`, `chore/`, `test/`, `docs/`).
3. Implementare un todo per PR quando possibile.
4. `flutter analyze` + `flutter test test/` prima del merge.
5. Aggiornare `status` dei todo nel plan (pending → completed).

Vedi anche `.cursor/rules/14-plan-implementation-branching.mdc`.

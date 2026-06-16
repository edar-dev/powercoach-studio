---
name: feature-30-sync-strategy-v2
overview: "Feature #7 v4 — Decisione e implementazione strategia sync: rafforzare local-only (semplifica UX) oppure ripristinare SyncOrchestrator con replay remoto via SyncReplayHook."
todos:
  - id: product-decision
    content: "Documentare scelta in docs/sync-strategy.md — opzione A local-only excellence vs opzione B cloud comeback"
    status: pending
  - id: option-a-simplify
    content: "Se local-only: rinominare Sync Issues → Dati in sospeso; nascondere accept-remote se mai conflict; backup come path principale multi-device"
    status: pending
  - id: option-b-orchestrator
    content: "Se cloud: reintrodurre SyncOrchestrator — replay outbox, register syncReplayHook in main.dart, conflict detection remota"
    status: pending
  - id: replay-hook-wire
    content: SyncReplayHook già chiamato post-retry — collegare a orchestrator se opzione B
    status: pending
  - id: gymblog-api-audit
    content: Inventario endpoint GymBlog ancora referenziati; rimuovere dead code o ripristinare client in DI
    status: pending
  - id: tests
    content: Test orchestrator no-op (A) o fake replay queue (B); pending_operation_resolver integration
    status: pending
  - id: migration-notes
    content: Note per utenti che usano solo backup — nessuna perdita dati
    status: pending
isProject: false
---

# Feature 30 — Strategia sync v2

## Obiettivo prodotto

L'app è **local-only** con auth Supabase ([`local-only-auth-refactor`](local-only-auth-refactor_91727a50.plan.md) completato).  
La UI sync (F18) e `SyncReplayHook` anticipano un futuro remoto.  
Serve una **decisione esplicita** per evitare complessità zombie.

## Stato attuale

| Componente | Stato |
|------------|-------|
| `SyncIssuesScreen` | keep/accept/retry/discard — locale |
| `SyncReplayHook` | No-op globale |
| `SyncOrchestrator` | Rimosso / non in bootstrap |
| `GymBlogApiClient` | Rimosso da DI |
| Outbox | `PendingOperations` ancora scritto da repository |

## Opzione A — Local-first excellence (consigliata se no backend a breve)

| Azione | Dettaglio |
|--------|-----------|
| UX | "Coda locale" invece di "Sync"; rimuovere copy "remoto" |
| Conflict | Solo se import backup duplicato — flusso dedicato |
| Multi-device | Backup/restore come path ufficiale |
| Codice | Rimuovere accept-remote se inutilizzato; tenere discard/retry per ops corrotte |

## Opzione B — Cloud comeback

| Azione | Dettaglio |
|--------|-----------|
| Bootstrap | `SyncOrchestrator.initialize()` in `main.dart` |
| Hook | `syncReplayHook = SyncOrchestratorReplayAdapter(...)` |
| API | Ripristinare `GymBlogApiClient` in DI con auth token |
| Conflict | Remote payload in `conflictRemotePayload` da server |

## Criteri decisione

| Fattore | A | B |
|---------|---|---|
| Backend GymBlog pronto | No | Sì |
| Multi-coach multi-device | Backup manuale | Sync auto |
| Tempo implementazione | 1 PR UX | 3+ PR |
| Rischio regressioni | Basso | Alto |

## Deliverable obbligatori (entrambe le opzioni)

1. `docs/sync-strategy.md` con decisione e rationale
2. UX allineata alla scelta
3. Test aggiornati
4. Issue GitHub per eventuale lavoro deferito dell'altra opzione

## Dipendenze

- Feature-18 (v3) — conflict UI (**completata**)
- Feature-31 — backup v2 complementare ad opzione A

## Definition of done

- Decisione documentata e approvata team
- Codice e UI coerenti con la scelta
- Nessun hook/sync copy fuorviante
- Analyze verde

## Branch suggerito

`chore/sync-strategy-v2` (doc + UX) o `feat/sync-orchestrator-restore` (opzione B)

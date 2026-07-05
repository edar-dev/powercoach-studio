---
name: local-first-ux-v1
overview: "Opzione A sync: rimuovere/nascondere la UX sync remoto, tenere backup/restore come path multi-device, e ripulire API/contratti fuorvianti (skipCache, l10n GymBlog, commenti dead code)."
todos:
  - id: product-signoff
    content: "Confermare opzione A — no replay remoto a breve; backup JSON come multi-device ufficiale"
    status: pending
  - id: remove-sync-settings-nav
    content: "Rimuovere SyncSettingsSection e route /sync-issues da settings e app_routes.dart"
    status: pending
  - id: deprecate-sync-screens
    content: "Eliminare o spostare sync_issues_screen.dart + sync_settings_section.dart (tenere codice core/sync solo se serve outbox interna)"
    status: pending
  - id: stop-pending-ops-writes
    content: "Valutare stop scrittura PendingOperations su save locale — o rinominare copy interno 'audit log'"
    status: pending
  - id: update-sync-strategy-doc
    content: "Aggiornare docs/sync-strategy.md — decisione A registrata, rimuovere opzione B o spostarla in appendix"
    status: pending
  - id: remove-skip-cache
    content: "Rimuovere param skipCache da CustomerRepository.getAll e call site in customer_list_screen.dart"
    status: pending
  - id: purge-dead-l10n
    content: "Rimuovere customersApiNotConfigured da app_en.arb / app_it.arb + rigenerare l10n"
    status: pending
  - id: fix-model-comments
    content: "Aggiornare commenti GymBlog in customer.dart, workout_routine_model.dart, pubspec.yaml (Dio → Hevy)"
    status: pending
  - id: hide-not-implemented-ctas
    content: "Nascondere o rimuovere showNotImplementedAlert in landing_screen.dart e subscription_screen.dart"
    status: pending
  - id: tests-and-analyze
    content: "Aggiornare test routing/settings; flutter analyze + flutter test test/"
    status: pending
isProject: false
---

# Local-First UX & Dead API Cleanup v1

## Punti coperti

| # roadmap | Descrizione |
|-----------|-------------|
| **1 (A)** | Nascondere sync UI; backup/restore come path principale |
| **5** | Rimuovere API morte e contratti fuorvianti |

## Supersede

Sostituisce **opzione A** di [`feature-30-sync-strategy-v2.plan.md`](feature-30-sync-strategy-v2.plan.md).  
Marcare quel piano `status: superseded` in frontmatter al merge di questo piano.

## Obiettivo prodotto

L'utente non vede più "sync", "conflitti remoti" o "API non configurata".  
Multi-device = **Backup & restore** in Settings (già implementato).

## Stato attuale

```mermaid
flowchart LR
  save[Repository save] --> outbox[PendingOperations]
  outbox --> ui[Sync Issues Screen]
  ui --> replay[SyncReplayHook NoOp]
  backup[UserDataBackupService] --> json[JSON export/import]
```

- `SyncReplayHook` — no-op globale
- `SyncIssuesScreen` — 436 righe, copy "remoto"
- `PendingOperations` — ancora scritto su save
- `skipCache` — no-op in local-first
- `customersApiNotConfigured` — l10n morta (GYMBLOG)

## Implementazione

### Fase 1 — Rimuovere superficie UX sync

| File | Azione |
|------|--------|
| `lib/features/settings/presentation/screens/settings_screen.dart` | Rimuovere `SyncSettingsSection` |
| `lib/features/settings/presentation/widgets/sync_settings_section.dart` | Eliminare file |
| `lib/features/settings/presentation/screens/sync_issues_screen.dart` | Eliminare file |
| `lib/core/routing/app_routes.dart` | Rimuovere route sync-issues |
| `lib/core/routing/route_redirect.dart` | Verificare protected paths |

**Tenere (per ora):** `lib/core/sync/pending_operation_resolver.dart`, `sync_replay_hook.dart` — usati da test; no-op OK.

### Fase 2 — Outbox interna (decisione tecnica)

**Opzione conservativa (consigliata PR1):** non scrivere più `PendingOperations` da repository; lasciare tabella Drift per migrazione dati esistenti.

**Opzione aggressiva (PR2+):** migration Drift drop tabella — solo dopo backup export testato.

File da audit:

- `lib/core/storage/offline_local_store.dart` — metodi pending ops
- Repository che chiamano enqueue pending

### Fase 3 — Dead API & copy

```dart
// PRIMA
Future<List<Customer>> getAll({bool skipCache = false})

// DOPO
Future<List<Customer>> getAll()
```

- `lib/features/customers/presentation/screens/customer_list_screen.dart` — refresh → semplice `getAll()`
- `l10n/app_*.arb` — rimuovere `customersApiNotConfigured`
- `pubspec.yaml` — commento Dio: "Hevy export API client"

### Fase 4 — Stub UX

| File | Azione |
|------|--------|
| `lib/features/landing/presentation/screens/landing_screen.dart` | Nascondere CTA non implementate |
| `lib/features/settings/presentation/screens/subscription_screen.dart` | Idem upgrade buttons |
| `lib/core/utils/not_implemented.dart` | Tenere per dev; non usare in path produzione |

## Ordine PR

1. `refactor/remove-sync-settings-ui` — routing + settings + delete screens
2. `refactor/remove-skip-cache-dead-l10n` — API + l10n + commenti
3. `refactor/stop-pending-ops-writes` — data layer (separato, più rischioso)
4. `docs/sync-strategy-decision-a` — doc update

## Verifica manuale QA

- [ ] Settings mostra backup/restore, non sync
- [ ] Nessuna route `/sync-issues` raggiungibile
- [ ] Pull-to-refresh lista clienti funziona
- [ ] Export/import backup round-trip OK
- [ ] `flutter analyze` + `flutter test test/`

## Rischi

- Utenti con pending ops legacy in DB — considerare messaggio one-time "dati migrati" o silent discard
- Test `pending_operation_resolver_test.dart` — aggiornare se si smette di scrivere outbox

## Dipendenze

- Consigliato dopo [`platform-ci-docs-v1`](platform-ci-docs-v1.plan.md)
- Prima di [`presentation-split-v1`](presentation-split-v1.plan.md) su customer/workout screens

---
name: agent-tooling-v1
overview: "Migliorare governance agent: archiviare plan obsoleti, aggiornare AGENTS.md, hook cross-platform, regola anti-sync-remoto, routing subagent più stretto."
todos:
  - id: update-agents-md
    content: "AGENTS.md — aggiungere pin Flutter 3.35.6, local-first deny-list, branch-from-main, no GymBlog"
    status: pending
  - id: archive-completed-plans
    content: "Spostare plan completati/obsoleti in .cursor/plans/archive/ con banner; aggiornare feature-30 come superseded"
    status: pending
  - id: extend-local-data-rule
    content: "Ampliare 07-local-data-and-integrations.mdc con deny-list esplicita per agent"
    status: pending
  - id: subagent-routing-rule
    content: "Ampliare 09-custom-subagents-routing.mdc — soglia >300 righe, reviewer obbligatorio pre-handoff"
    status: pending
  - id: bash-drift-hook
    content: "Creare .cursor/hooks/check-drift-codegen.sh equivalente al .ps1"
    status: pending
  - id: bash-guard-hook
    content: "Creare .cursor/hooks/guard-dangerous-commands.sh equivalente al .ps1"
    status: pending
  - id: hooks-json-dispatch
    content: "Aggiornare hooks.json — dispatch OS-aware (bash su darwin/linux, ps1 su win32) o solo bash"
    status: pending
  - id: plan-index-readme
    content: "Creare .cursor/plans/README.md — indice plan attivi vs archiviati con ordine esecuzione"
    status: pending
isProject: false
---

# Agent Tooling & Governance v1

## Punti coperti

| # roadmap | Descrizione |
|-----------|-------------|
| **10** | Ridurre drift regole / plan / realtà |
| **11** | Fix hook cross-platform |
| **12** | Regola agent "no sync reintroduzione" |
| **13** | Subagent routing più stretto |

## Obiettivo

Agent Cursor devono ricevere contesto accurato e guardrail che impediscono regressioni architetturali (GymBlog, sync remoto, Flutter drift).

## 1) AGENTS.md — sezioni da aggiungere

```markdown
## Architecture constraints (non-negotiable)
- Local-first: business data in Drift/SQLite + SharedPreferences per userId.
- Supabase: authentication session ONLY — no table CRUD.
- No GymBlog.API, no GYMBLOG_API_URL, no remote sync replay unless explicit new plan approved.
- Hevy: only integration via lib/features/integrations/hevy/ (user API key).

## CI / Flutter version
- CI pins Flutter 3.35.6 — match locally via .flutter-version before substantive work.
- After edits: flutter analyze && flutter test test/

## Branch policy
- Implement approved plans on branch from main — never commit plan work directly on main.
- Branch format: <type>/<scope>-<short-description>
```

## 2) Archiviare plan obsoleti

### Spostare in `.cursor/plans/archive/`

| Plan | Motivo |
|------|--------|
| `local-only-auth-refactor_91727a50.plan.md` | completed |
| `feature-30-sync-strategy-v2.plan.md` | superseded by local-first-ux-v1 |
| Plan con task "restore GymBlogApiClient" | obsoleti |

### Banner frontmatter archivio

```yaml
status: archived
superseded_by: local-first-ux-v1
```

### Plan attivi (indice)

| Plan | Ordine |
|------|--------|
| `platform-ci-docs-v1` | 1 |
| `agent-tooling-v1` | 1 (parallelo) |
| `local-first-ux-v1` | 2 |
| `test-backfill-v1` | 2 (parallelo) |
| `data-layer-v1` | 3 |
| `presentation-split-v1` | 4 |

Creare `.cursor/plans/README.md` con questa tabella.

## 3) Regola 07 — deny-list agent

Aggiungere a `.cursor/rules/07-local-data-and-integrations.mdc`:

```markdown
## Agent deny-list (do not reintroduce without approved plan)
- lib/core/network/gymblog_api_client.dart or GYMBLOG_API_URL wiring
- Supabase .from('...') CRUD for business entities
- SyncOrchestrator remote replay in main.dart bootstrap
- get_it / global DI container
- Remote write path via PendingOperations expecting server ACK
```

## 4) Regola 09 — subagent routing

Aggiungere a `.cursor/rules/09-custom-subagents-routing.mdc`:

```markdown
## Mandatory delegation thresholds
| Condition | Required agents (in order) |
|-----------|----------------------------|
| Unfamiliar feature folder | flutter-explorer |
| Edit touches file >300 lines | flutter-explorer before implement |
| Multi-file feature/refactor | flutter-implementer |
| Before handoff / PR | flutter-reviewer + flutter-test-runner |
| Drift schema / ARB changed | flutter-test-runner (build_runner) |
```

## 5) Hook cross-platform

### Problema

`.cursor/hooks.json` invoca solo PowerShell — su macOS (darwin) i hook non eseguono.

### Soluzione A (consigliata): bash-only

```bash
# .cursor/hooks/check-drift-codegen.sh
#!/usr/bin/env bash
if grep -q "app_database.dart" <<< "${CURSOR_FILE_PATH:-}"; then
  echo "Drift schema changed — run: dart run build_runner build --delete-conflicting-outputs"
fi
```

```bash
# .cursor/hooks/guard-dangerous-commands.sh
#!/usr/bin/env bash
# Exit 1 if command matches dangerous patterns
```

Aggiornare `hooks.json`:

```json
"command": "bash .cursor/hooks/check-drift-codegen.sh"
```

### Soluzione B: dual dispatch script

`check-drift-codegen.cmd.sh` che rileva OS — più complesso, evitare se team è mac-first.

## Ordine PR

1. `chore/agent-governance-docs` — AGENTS.md + rules 07/09 + plans README
2. `chore/archive-obsolete-plans` — move to archive/
3. `chore/cross-platform-cursor-hooks` — bash scripts + hooks.json

## Verifica

- [ ] Aprire chat agent — regole 07/09 visibili
- [ ] Modificare `app_database.dart` — hook suggerisce build_runner
- [ ] Tentativo `git push -f` — guard hook (failClosed false = warn only)
- [ ] Plan index README linka solo plan attivi

## Rischi

- Archiviare plan può rompere link interni — grep `.cursor/plans/` e aggiornare
- Hook bash richiede `chmod +x` — documentare

## Dipendenze

- Parallelo a [`platform-ci-docs-v1`](platform-ci-docs-v1.plan.md)
- Completare **prima** di grandi refactor (presentation/data) per massimizzare guardrail

---
name: ui-refinement
description: >-
  Exhaustive UI polish from screenshots and live UI in PowerCoach Studio:
  hierarchy, density, contrast, duplication, missing/misleading state, touch
  targets, sheets/dialogs, and display↔model mismatches. Use when the user
  shares UI screenshots, asks to analyze/improve a screen, requests
  refinement/polish/miglioramenti UI, or says things like "così appare",
  "analizza", "ulteriori miglioramenti", or "fai tutte le fix".
---

# UI Refinement (exhaustive)

Run a **full pass** over the visible UI and its code wiring. Do not wait for the user to list every issue—find them.

**Out of scope:** shipping (commit/push/PR/merge/deploy). Stop after verify. The user ships manually (or via `ship-and-deploy` when they ask).

## When to apply

- Screenshots / “così appare adesso”
- “Analizza”, “miglioramenti”, “refinement”, “polish”
- “Fai tutte le fix” after an analysis
- Post-deploy visual follow-ups

If the user only wants analysis, stop after the report. If they ask to fix (or “tutte le fix”), implement the full prioritized set. **Never** commit, push, open a PR, merge, or verify deploy as part of this skill.

## Workflow

```
- [ ] 1. Capture scope (screen, mode, platform)
- [ ] 2. Read screenshot(s) + matching widgets/models
- [ ] 3. Run exhaustive checklist (see checklist.md)
- [ ] 4. Report prioritized backlog (P0–P3)
- [ ] 5. Implement when asked (smallest correct diff)
- [ ] 6. Verify (analyze + focused widget tests) — then stop
```

### 1. Scope

Note: feature/screen, editor vs read-only, empty vs filled data, mobile vs desktop width, locale (IT primary).

### 2. Evidence

- Treat screenshots as source of truth for **what users see**.
- Trace each visible string/control to the **model field** and write path (dialog/sheet/mutation).
- Prefer existing design-system tokens/components; no drive-by redesigns unless asked.

### 3–4. Checklist → backlog

Walk every section in [checklist.md](checklist.md). Output:

| Priority | Issue | Why it hurts | Fix (file/area) |
|----------|-------|--------------|-----------------|
| P0 | … | bug / wrong data / broken CTA | … |
| P1 | … | hierarchy / duplication / density | … |
| P2 | … | contrast / a11y / sheet chrome | … |
| P3 | … | nice-to-have polish | … |

**P0 always includes display↔model mismatches** (placeholder shown while another field already has the value).

Keep the report concise: verdict first, then the table, then optional “out of scope”.

### 5. Implement

- Branch from `main` when implementing an approved/asked batch (project branching rules).
- Fix **P0 → P3** unless the user scopes down.
- Match existing patterns (theme, l10n, sheets, touch targets).
- Add/adjust focused widget tests for visible regressions (placeholders, expand/collapse, note display).
- Do not invent product behavior; preserve intentional modes (e.g. editor-only actions).

### 6. Verify — then stop

- `flutter analyze`
- Focused tests for touched UI
- Call out residual risks / manual QA
- Leave uncommitted work ready for the user; do **not** ship

## Analysis report template

```markdown
## Verdict
<1–2 sentences: what’s wrong / what’s good enough>

## Issues
| P | Issue | Fix |
|---|-------|-----|
| P0 | … | … |
| P1 | … | … |

## Recommend
- Implement now: P0–P1 (or P0–P3)
- Defer: …
```

## Anti-patterns

- Stopping after the first obvious issue
- Polishing visuals while a **wrong-field** bug remains
- Adding cards/chrome that fight the current design language
- Large redesign when the ask is refinement
- Committing, opening PRs, merging, or deploying from this skill

## Project notes (PowerCoach Studio)

- Theme: `StitchM3Theme`; dark default; reuse tokens before new colors
- l10n: IT primary + EN ARB pair for user-visible strings
- Prefer flat session-sheet language over nested card stacks where that pattern is established
- Sheets: `showAppBottomSheet` — use `wrapContent` for short forms
- Touch: ≥48dp on icon actions used in lists/headers

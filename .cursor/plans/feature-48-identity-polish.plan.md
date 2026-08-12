---
name: feature-48-identity-polish
overview: "Post–Wave 3 Identity polish — Excel density l10n share, Hevy density notes, plan-diff density, gym mode density + simple timer."
todos:
  - id: a4-excel-l10n
    content: "Share densityBlockExportLabel; Excel takes PdfExportLabels; wire export actions"
    status: completed
  - id: a3-hevy-notes
    content: "Prepend density line to first Hevy exercise notes in group; unit tests"
    status: completed
  - id: a1-plan-diff
    content: "DensityBlockDiff on DayDiff; UI after coaching note; rounds added/removed tests"
    status: completed
  - id: a2-gym-timer
    content: "Gym density headers + Timer.periodic rest/interval Start/Reset"
    status: completed
isProject: false
---

# Feature 48 — Identity post–Wave 3 polish

Follow-up to Wave 3 density blocks (F46) and narrative l10n (F47). No Drift migration.

| ID | Scope |
|----|--------|
| **A4** | Shared `densityBlockExportLabel` for PDF + Excel (`PdfExportLabels`) |
| **A3** | Hevy: prepend `Circuit · 3× · 90s`-style line to first exercise notes in a group |
| **A1** | Plan diff includes `densityBlocks` keyed by `groupId` |
| **A2** | Gym session: density headers + simple rest/interval countdown |

Branch: `feat/identity-post-wave3-polish`

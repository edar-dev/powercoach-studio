# PDF import fixtures (stress / edge cases)

Import from the workout builder: **Share → Import JSON** (or equivalent import action).

Each file targets a specific PDF edge case. After import, export **dense PDF** and verify layout.

| File | What it stress-tests |
|------|----------------------|
| `01-alignment-reorder.json` | Same exercises in different order across S1–S4; row alignment by `customExerciseId` |
| `02-pyramids-supersets.json` | Long pyramids, RPE `@`, supersets, coaching notes, `shortName` |
| `03-mobility-metadata.json` | `scheduleHint`, `shortTitle`, empty subtitles, long section names, plan dates |
| `04-legacy-messy.json` | No v2 fields; legacy `reps`/`rpe` splits, typo notes, `prescriptionScope` absent |
| `05-overflow-pagination.json` | 4 weeks × 3 days × many exercises — page breaks and headers |
| `06-four-disjoint-days.json` | **4 giorni/settimana**, split classico (squat/bench/dead/shoulders), zero overlap tra giorni, 4 settimane |
| `07-rotating-day-exercises.json` | Stessi 4 slot giorno ma **esercizi diversi ogni settimana** (nessun `customExerciseId` condiviso tra S1–S4) |
| `08-asymmetric-day-count.json` | S3 ha solo **2 giorni**, S1/S2/S4 ne hanno 4 — celle vuote su slot 3–4 in S3 |
| `09-mega-day-fourteen-exercises.json` | Giorno 2 con **14 esercizi** + altri 3 giorni leggeri — paginazione intra/inter-giorno |

Validate locally:

```bash
dart run tool/validate_pdf_fixtures.dart
```

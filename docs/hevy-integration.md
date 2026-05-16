# Hevy integration (coach account)

PowerCoach Studio can sync the full Hevy exercise catalog into the local library and export a plan day as a **routine** on Hevy.

## Requirements

- [Hevy Pro](https://hevy.com) subscription
- API key from [hevy.com/settings?developer](https://hevy.com/settings?developer)

## Setup

1. Open **Settings → Hevy integration**
2. Paste your API key and tap **Save key**
3. Tap **Test connection**
4. Tap **Sync all exercises** (or use **Exercise library → Import → Sync full Hevy catalog**)

Exercises are stored locally with `hevyTemplateId` on each leaf, grouped by muscle and title family.

## Export a workout day

1. In the **workout builder**, open the export menu and choose **Export day to Hevy**
2. Or from the **coach calendar**, use the event menu → **Export to Hevy**
3. Resolve any unmapped exercises, then confirm

Export uses `POST /v1/routines` on the Hevy API. Prescriptions are best-effort parsed from PowerCoach set text.

## API stability

Hevy documents the public API as experimental. The client is isolated under `lib/features/integrations/hevy/`.

## Regenerating offline catalog asset (optional)

A maintainer script can page `GET /v1/exercise_templates` and write `lib/features/integrations/hevy/assets/hevy_exercise_catalog_v1.json` for offline tests. Primary import always uses the live API so custom exercises on the coach account are included.

# Workout Builder QA Checklist

Use this checklist for PRs that touch the workout builder UI, state flow, import/export, or exercise picker.

## Required Automated Checks

- `flutter analyze`
- Focused tests under `test/features/workouts/`
- Widget smoke tests for any changed builder widget
- Unit tests for new mutation/controller/store behavior

## Manual Responsive Pass

- Mobile width around 390 px
- Tablet/web width around 768 px
- Wide desktop/web width around 1200 px
- Large text enabled enough to catch clipped labels
- Dark theme, default app theme

## Builder Flow Smoke

- Open an existing customer plan in editor mode
- Edit plan metadata and confirm save status changes
- Add, duplicate, move, delete, and undo-delete an exercise
- Add/edit a multi-set prescription
- Assign and remove a superset
- Switch week/day tabs and verify selected state remains clear
- Leave the screen with unsaved changes and verify save/discard/cancel paths

## Robustness Smoke

- Autosave success shows saved state
- Autosave failure shows retry state and manual retry works
- Standalone builder warns before losing unsaved changes
- Import valid JSON succeeds
- Import malformed JSON shows an error
- Export PDF/Excel/JSON actions still complete

## Accessibility

- Icon-only actions have tooltips or semantics labels
- Buttons remain at least 44 px high/tappable
- Error and retry states are reachable with keyboard/screen reader focus
- Text does not truncate critical action labels at large text scale

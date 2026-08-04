# Exhaustive UI refinement checklist

Walk **every** item against the current screenshot + code. Skip only with an explicit reason (N/A).

## A. Information architecture

- [ ] One primary job per section / viewport region
- [ ] Brand/product chrome does not compete with content (unless landing)
- [ ] Clear hierarchy: title → primary data → secondary → actions
- [ ] No duplicate facts (same prescription/title/count shown twice nearby)
- [ ] Collapsed vs expanded: expanded must not repeat the collapsed summary unless useful
- [ ] Empty vs filled states are distinct and honest

## B. Data honesty (display ↔ model)

- [ ] Every visible value maps to the correct model field
- [ ] Placeholders (“Aggiungi…”, “Add…”) only when **all** relevant fields are empty
- [ ] Edit dialogs/sheets read/write the **same** fields the list displays
- [ ] Legacy vs new fields (e.g. exercise-level vs per-set) both surfaced or clearly separated
- [ ] Truncation does not hide the only copy of critical data without expand/tooltip
- [ ] Saved state / status badges match actual persistence

## C. Actions & affordances

- [ ] Primary CTA is obvious; secondary actions quieter
- [ ] Destructive actions visually distinct and confirm when needed
- [ ] Placeholder/CTA text that implies action is actually tappable (or not styled as CTA)
- [ ] Icon-only actions have tooltips / semantic labels
- [ ] Mode-gated actions (editor vs standalone) are intentional and consistent
- [ ] FABs vs inline CTAs: prefer inline near content; avoid redundant FAB + inline
- [ ] Menus don’t steal expand/collapse taps (header vs trailing isolation)

## D. Density & layout

- [ ] No large empty regions in short sheets/dialogs (prefer wrap-content)
- [ ] Consistent horizontal rhythm (alignment of names, values, icons)
- [ ] Related fields grouped; unrelated gaps removed
- [ ] Desktop max-width / readable measure respected where established
- [ ] Lists: comfortable row height without sparse waste
- [ ] Sticky toolbars don’t eat disproportionate vertical space

## E. Typography & contrast

- [ ] Secondary text readable on dark/light surfaces (≥ ~0.7 alpha on dark, or theme tokens)
- [ ] Placeholders italic/secondary; real values normal weight/color
- [ ] No overlong titles crushing trailing metadata—use flexible layout
- [ ] Numbers/prescriptions scannable (tabular feel, right-aligned when comparing)

## F. Components & chrome

- [ ] Prefer existing shared widgets/theme over one-off styles
- [ ] Cards only when they aid interaction; flat rows OK for session sheets
- [ ] Dividers/spacing consistent within the screen
- [ ] Bottom sheets: title size matches complexity; footer button not stranded by empty Expanded body
- [ ] Inputs in editors: `isDense` / sensible contentPadding for short forms

## G. Touch & a11y

- [ ] Icon buttons ≥ 44–48dp effective target
- [ ] Hit targets don’t overlap competing gestures
- [ ] Focus order / autofocus sensible (e.g. focus note when opening from note CTA)
- [ ] Screen reader: expand/collapse hints; menu labels; don’t rely on color alone for state

## H. Motion & state feedback

- [ ] Expand/collapse feedback is immediate and local
- [ ] Loading / saving / error / empty covered for the screen
- [ ] No layout jump when toggling minor chrome (title bar, actions)

## I. Cross-surface consistency

- [ ] Same entity looks consistent in list, detail, dialog, PDF/export if applicable
- [ ] Sibling tabs (e.g. Training / Mobility / Details) share language and density
- [ ] Superset/group variants get the same note/prescription fixes as singles

## J. Platform & locale

- [ ] IT + EN strings for new user-visible copy
- [ ] Weekday/date formatting via locale APIs, not hard-coded
- [ ] Web + narrow mobile: no critical action only in hover
- [ ] Safe areas / keyboard insets on sheets

## Severity guide

| Priority | Examples |
|----------|----------|
| **P0** | Wrong/missing data shown; dead CTA; unblocker bug; a11y blocker |
| **P1** | Duplication, hierarchy, misleading chrome, density that hurts scan |
| **P2** | Contrast, sheet height, touch target polish, tooltip gaps |
| **P3** | Micro-copy, optional collapse, visual niceties |

## Screenshot pass (quick)

For each screenshot region ask:

1. What is the user trying to do here?
2. What looks incomplete, duplicated, or low-contrast?
3. If I tap this label/placeholder, does anything happen?
4. Does the detail/edit surface agree with the summary?

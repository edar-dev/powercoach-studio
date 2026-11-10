/// Remaps workout-builder shell tab index when mobility-tab visibility flips.
///
/// With mobility: 0=training, 1=mobility, 2=details.
/// Without: 0=training, 1=details.
int remapTabIndexAfterMobilityVisibilityChange({
  required bool showingMobility,
  required int previousIndex,
}) {
  if (showingMobility) {
    // 2 tabs → 3 tabs: details shifts from 1 → 2.
    if (previousIndex >= 1) return previousIndex + 1;
    return 0;
  }
  // 3 tabs → 2 tabs: mobility → training; details stays on details.
  if (previousIndex <= 0) return 0;
  if (previousIndex == 1) return 0;
  return 1;
}

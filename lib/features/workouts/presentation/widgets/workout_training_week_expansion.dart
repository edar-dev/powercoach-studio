// Pure helpers for training-tab week accordion expansion.
// On desktop (singleExpand = true), only one week grid should be expanded
// at a time to limit simultaneous day-card build cost on web long lists.

/// Next expanded set after the user toggles [globalWeek].
///
/// When collapsing, [globalWeek] is removed. When expanding with
/// [singleExpand], the result is `{globalWeek}` only.
Set<int> nextExpandedWeeksAfterToggle({
  required Set<int> current,
  required int globalWeek,
  required bool currentlyExpanded,
  required bool singleExpand,
}) {
  if (currentlyExpanded) {
    return {...current}..remove(globalWeek);
  }
  if (singleExpand) {
    return {globalWeek};
  }
  return {...current, globalWeek};
}

/// Next expanded set when a week must be shown (selection / session open).
///
/// With [singleExpand], collapses siblings; otherwise adds [globalWeek].
Set<int> nextExpandedWeeksAfterSelect({
  required Set<int> current,
  required int globalWeek,
  required bool singleExpand,
}) {
  if (singleExpand) {
    return {globalWeek};
  }
  return {...current, globalWeek};
}

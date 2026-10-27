import 'app_paths.dart';

/// Primary shell [StatefulShellBranch] indices.
const int primaryShellBranchToday = 0;
const int primaryShellBranchCustomers = 1;
const int primaryShellBranchWorkouts = 2;
const int primaryShellBranchDiary = 3;

/// Settings lives in the shell so the rail stays visible, but is opened via the
/// trailing gear (not a 5th tab). Phone bottom nav hides on this branch.
const int primaryShellBranchSettings = 4;

/// Maps a location path to the primary shell [StatefulShellBranch] index.
///
/// Indices: 0 Today, 1 Clienti, 2 Schede, 3 Diario, 4 Settings.
int primaryShellBranchForPath(String path) {
  if (path == AppPaths.settings ||
      path.startsWith('${AppPaths.settings}/')) {
    return primaryShellBranchSettings;
  }
  if (path == AppPaths.customers) {
    return primaryShellBranchCustomers;
  }
  if (path == AppPaths.workoutBuilder ||
      path.startsWith('${AppPaths.workoutBuilder}/') ||
      path == AppPaths.exerciseLibrary ||
      path.startsWith('${AppPaths.exerciseLibrary}/')) {
    return primaryShellBranchWorkouts;
  }
  if (path == AppPaths.workoutDiary ||
      path.startsWith('${AppPaths.workoutDiary}/')) {
    return primaryShellBranchDiary;
  }
  if (path == AppPaths.dashboard ||
      path.startsWith('${AppPaths.dashboard}/')) {
    return primaryShellBranchToday;
  }
  return primaryShellBranchToday;
}

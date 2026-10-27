import 'app_paths.dart';

/// Maps a location path to the primary shell [StatefulShellBranch] index.
///
/// Indices: 0 Today, 1 Clienti, 2 Schede, 3 Diario.
int primaryShellBranchForPath(String path) {
  if (path == AppPaths.customers) {
    return 1;
  }
  if (path == AppPaths.workoutBuilder ||
      path.startsWith('${AppPaths.workoutBuilder}/') ||
      path == AppPaths.exerciseLibrary ||
      path.startsWith('${AppPaths.exerciseLibrary}/')) {
    return 2;
  }
  if (path == AppPaths.workoutDiary ||
      path.startsWith('${AppPaths.workoutDiary}/')) {
    return 3;
  }
  if (path == AppPaths.dashboard ||
      path.startsWith('${AppPaths.dashboard}/')) {
    return 0;
  }
  return 0;
}

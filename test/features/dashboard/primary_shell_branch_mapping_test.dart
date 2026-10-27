import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/primary_shell_branch.dart';

/// Drawer hubs were replaced by [PrimaryShellScaffold]. Branch mapping covers
/// the former drawer destinations (Today, calendar, customers, builder, library).
void main() {
  test('former drawer destinations map to primary shell branches', () {
    expect(primaryShellBranchForPath(AppPaths.dashboard), 0);
    expect(primaryShellBranchForPath(AppPaths.calendar), 0);
    expect(primaryShellBranchForPath(AppPaths.customers), 1);
    expect(primaryShellBranchForPath(AppPaths.workoutBuilder), 2);
    expect(primaryShellBranchForPath(AppPaths.exerciseLibrary), 2);
    expect(primaryShellBranchForPath(AppPaths.workoutDiary), 3);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/hub_chrome.dart';
import 'package:powercoach_studio/core/routing/primary_shell_scaffold.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/training_session_edit_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_edit_set_dialog.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

/// Phone surface used by Phase A widget harnesses and Phase B emulator smokes.
const Size kPhoneSmokeSize = Size(390, 844);

/// Simulated home-indicator / gesture-bar inset for geometric asserts.
const double kPhoneSmokeHomeIndicator = 34;

GoRouter buildShellSmokeRouter({String initialLocation = AppPaths.dashboard}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PrimaryShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.dashboard,
                builder: (context, state) {
                  final slimHub = primaryShellUsesRail(context);
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Today hub'),
                      actions: [
                        if (!slimHub)
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: 'Settings',
                            onPressed: () => context.go(AppPaths.settings),
                          ),
                      ],
                    ),
                    body: const Text('Today body'),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.customers,
                builder: (context, state) =>
                    const Scaffold(body: Text('Customers body')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.workoutBuilder,
                builder: (context, state) =>
                    const Scaffold(body: Text('Builder body')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.workoutDiary,
                builder: (context, state) =>
                    const Scaffold(body: Text('Diary body')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.settings,
                builder: (context, state) =>
                    const Scaffold(body: Text('Settings destination')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget shellSmokeApp(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // Match Phase A shell harness labels (Today / Customers / Plans / Diary).
    locale: const Locale('en'),
  );
}

Future<void> pumpPhoneShellSmoke(
  WidgetTester tester,
  GoRouter router, {
  double bottomPadding = kPhoneSmokeHomeIndicator,
}) async {
  tester.view.physicalSize = kPhoneSmokeSize;
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding(bottom: bottomPadding);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  await tester.pumpWidget(shellSmokeApp(router));
  await tester.pumpAndSettle();
}

WorkoutRoutine smokeRoutineWithExercise() {
  return WorkoutRoutine.empty().copyWith(
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: const [
          Week(
            id: 'w1',
            name: 'Settimana 1',
            days: [
              Day(
                id: 'd1',
                name: 'Giorno A',
                exercises: [
                  Exercise(
                    id: 'e1',
                    name: 'Squat',
                    sets: '3',
                    reps: '5',
                    rpe: '100kg',
                    setDetails: [
                      ExerciseSet(sets: '3', reps: '5', rpe: '100kg'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget wrapItalianPhone(
  Widget child, {
  Size size = kPhoneSmokeSize,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: MediaQuery(
      data: MediaQueryData(size: size, padding: padding),
      child: child,
    ),
  );
}

TrainingSessionEditBody dayEditorSmokeBody(
  BuildContext context,
  WorkoutBuilderSessionController session,
  Day day,
) {
  final theme = Theme.of(context);
  return TrainingSessionEditBody(
    theme: theme,
    cs: theme.colorScheme,
    session: session,
    day: day,
    globalWeekIndex: 0,
    dayIndex: 0,
    onRenameDay: () {},
    onDeleteDay: () {},
    onDuplicateExercise: (_, _, _) {},
    onRemoveExercise: (_, _, _) {},
    onMoveExercise: (_, _, _, {required up}) {},
    onMoveExerciseWithinSuperset: (_, _, _, {required up}) {},
    onUpdateExercise: (
      _,
      _,
      _, {
      name,
      sets,
      reps,
      rpe,
      note,
      shortName,
      prescriptionScope,
      setDetails,
      maximalRef,
      bool clearMaximalRef = false,
    }) {},
    onAddSetToExercise: (_, _, _) {},
    onUpdateExerciseSet: (
      _,
      _,
      _,
      _, {
      line,
      sets,
      reps,
      rpe,
      note,
    }) {},
    onRemoveExerciseSet: (_, _, _, _) {},
    onAssignToSuperset: (_, _, _, _) {},
    onRemoveFromSuperset: (_, _, _) {},
    onAddExerciseToSuperset: (_, _, _) {},
    onClose: () {},
  );
}

Widget editBlockSmokeHarness() {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () {
                showEditSetDialog(
                  context,
                  theme,
                  theme.colorScheme,
                  '3',
                  '5',
                  '75kg',
                  '',
                  (_, _, _, _) {},
                );
              },
              child: const Text('Open set'),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> setPhoneSmokeView(
  WidgetTester tester, {
  Size size = kPhoneSmokeSize,
  double bottomPadding = 0,
}) async {
  final view = tester.view;
  view.physicalSize = size;
  view.devicePixelRatio = 1.0;
  if (bottomPadding > 0) {
    view.padding = FakeViewPadding(bottom: bottomPadding);
    addTearDown(view.resetPadding);
  }
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
  await tester.pump();
}

TextField fieldByLabel(WidgetTester tester, String label) {
  final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
  for (final field in fields) {
    final decoration = field.decoration;
    if (decoration?.labelText == label) return field;
  }
  fail('TextField with label "$label" not found');
}

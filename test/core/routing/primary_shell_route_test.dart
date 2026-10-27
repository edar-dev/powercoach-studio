import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/primary_shell_branch.dart';
import 'package:powercoach_studio/core/routing/primary_shell_scaffold.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

GoRouter _shellHarnessRouter({String initialLocation = AppPaths.dashboard}) {
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
                builder: (context, state) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Today hub'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: 'Settings',
                        onPressed: () =>
                            context.go(AppPaths.settings),
                      ),
                    ],
                  ),
                  body: const Text('Today body'),
                ),
                routes: [
                  GoRoute(
                    path: 'calendar',
                    builder: (context, state) =>
                        const Scaffold(body: Text('Calendar body')),
                  ),
                ],
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
              GoRoute(
                path: AppPaths.exerciseLibrary,
                builder: (context, state) =>
                    const Scaffold(body: Text('Library body')),
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
        ],
      ),
      GoRoute(
        path: AppPaths.settings,
        builder: (context, state) =>
            const Scaffold(body: Text('Settings destination')),
      ),
    ],
  );
}

Widget _app(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
  );
}

/// Phone width so [PrimaryShellScaffold] uses [NavigationBar] (not rail).
Future<void> _pumpPhoneShell(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app(router));
  await tester.pumpAndSettle();
}

void main() {
  test('primaryShellBranchForPath maps hubs', () {
    expect(primaryShellBranchForPath(AppPaths.dashboard), 0);
    expect(primaryShellBranchForPath(AppPaths.calendar), 0);
    expect(primaryShellBranchForPath(AppPaths.customers), 1);
    expect(primaryShellBranchForPath('${AppPaths.customers}/abc'), 0);
    expect(primaryShellBranchForPath(AppPaths.workoutBuilder), 2);
    expect(primaryShellBranchForPath(AppPaths.exerciseLibrary), 2);
    expect(primaryShellBranchForPath(AppPaths.workoutDiary), 3);
  });

  testWidgets('tab taps update URL across primary branches', (tester) async {
    final router = _shellHarnessRouter();
    await _pumpPhoneShell(tester, router);

    expect(find.text('Today body'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, AppPaths.dashboard);

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();
    expect(find.text('Customers body'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, AppPaths.customers);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();
    expect(find.text('Builder body'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.workoutBuilder,
    );

    await tester.tap(find.text('Diary'));
    await tester.pumpAndSettle();
    expect(find.text('Diary body'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.workoutDiary,
    );
  });

  testWidgets('exercise library keeps Schede branch selected', (tester) async {
    final router = _shellHarnessRouter(
      initialLocation: AppPaths.exerciseLibrary,
    );
    await _pumpPhoneShell(tester, router);

    expect(find.text('Library body'), findsOneWidget);
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.selectedIndex, 2);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.exerciseLibrary,
    );
  });

  testWidgets('calendar path keeps Today branch selected', (tester) async {
    final router = _shellHarnessRouter(initialLocation: AppPaths.calendar);
    await _pumpPhoneShell(tester, router);

    expect(find.text('Calendar body'), findsOneWidget);
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.selectedIndex, 0);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.calendar,
    );
  });

  testWidgets('settings icon on hub navigates to settings', (tester) async {
    final router = _shellHarnessRouter();
    await _pumpPhoneShell(tester, router);

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip('Settings'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings destination'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.settings,
    );
  });

  testWidgets('re-tapping Schede from library returns to builder', (
    tester,
  ) async {
    final router = _shellHarnessRouter(
      initialLocation: AppPaths.exerciseLibrary,
    );
    await _pumpPhoneShell(tester, router);
    expect(find.text('Library body'), findsOneWidget);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Builder body'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.workoutBuilder,
    );
  });
}

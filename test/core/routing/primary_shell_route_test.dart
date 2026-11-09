import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/routing/hub_chrome.dart';
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

Widget _app(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
  );
}

/// Phone width so [PrimaryShellScaffold] uses [NavigationBar] (not rail).
Future<void> _pumpPhoneShell(
  WidgetTester tester,
  GoRouter router, {
  double bottomPadding = 0,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = FakeViewPadding(bottom: bottomPadding);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  await tester.pumpWidget(_app(router));
  await tester.pumpAndSettle();
}

Future<void> _pumpWideShell(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(1280, 800);
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
    expect(primaryShellBranchForPath(AppPaths.settings), 4);
    expect(primaryShellBranchForPath(AppPaths.personalInfo), 4);
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

  testWidgets('phone NavigationBar matches Stitch density chrome', (
    tester,
  ) async {
    final router = _shellHarnessRouter();
    await _pumpPhoneShell(tester, router);

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.height, 64);
    expect(bar.elevation, 0);
    expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
    expect(bar.destinations, hasLength(4));
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Search clients, plans, exercises...'), findsNothing);
  });

  testWidgets(
    'phone shell with home-indicator padding keeps 4 destinations and no overflow',
    (tester) async {
      final router = _shellHarnessRouter();
      await _pumpPhoneShell(tester, router, bottomPadding: 34);

      final barFinder = find.byType(NavigationBar);
      expect(barFinder, findsOneWidget);
      final bar = tester.widget<NavigationBar>(barFinder);
      expect(bar.height, 64);
      expect(bar.destinations, hasLength(4));

      // Scaffold paints the bar through the home-indicator band; chrome height
      // stays 64 while the laid-out rect includes padding.bottom (34).
      final barRect = tester.getRect(barFinder);
      expect(barRect.height, greaterThanOrEqualTo(64));
      expect(barRect.bottom, closeTo(844, 0.5));
      expect(barRect.top, lessThanOrEqualTo(844 - 34 - 64 + 1));

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsNothing);

      // Settings path still hides the bar with safe padding applied.
      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Settings'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Settings destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

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

  testWidgets('settings icon on hub navigates to settings inside shell', (
    tester,
  ) async {
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
    // Phone hides bottom nav on settings branch (not a 5th tab).
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('wide settings keeps NavigationRail visible', (tester) async {
    final router = _shellHarnessRouter(initialLocation: AppPaths.settings);
    await _pumpWideShell(tester, router);

    expect(find.text('Settings destination'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, isNull);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.settings,
    );
  });

  testWidgets('rail settings trailing opens settings branch', (tester) async {
    final router = _shellHarnessRouter();
    await _pumpWideShell(tester, router);

    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings destination'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppPaths.settings,
    );
  });

  testWidgets('wide rail is extended with brand and search chrome', (
    tester,
  ) async {
    final router = _shellHarnessRouter();
    await _pumpWideShell(tester, router);

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
    expect(rail.minExtendedWidth, kPrimaryShellRailExtendedWidth);
    expect(find.text('PowerCoach Studio'), findsWidgets);
    expect(
      find.text('Search clients, plans, exercises...'),
      findsOneWidget,
    );
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('wide shell search submits to customers with q', (tester) async {
    final router = _shellHarnessRouter();
    await _pumpWideShell(tester, router);

    await tester.enterText(find.byType(TextField), 'Rossi');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Customers body'), findsOneWidget);
    final uri = router.routeInformationProvider.value.uri;
    expect(uri.path, AppPaths.customers);
    expect(uri.queryParameters['q'], 'Rossi');
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

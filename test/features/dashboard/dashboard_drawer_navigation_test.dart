import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

GoRouter _drawerHarnessRouter({
  required List<GoRoute> extraRoutes,
}) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => Scaffold(
          drawer: const DashboardDrawer(),
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('open drawer'),
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: 'calendar',
            builder: (context, state) =>
                const Scaffold(body: Text('Calendar destination')),
          ),
        ],
      ),
      ...extraRoutes,
    ],
  );
}

void main() {
  testWidgets('DashboardDrawer workout builder updates route on web-style go', (
    tester,
  ) async {
    final router = _drawerHarnessRouter(
      extraRoutes: [
        GoRoute(
          path: '/workouts/builder',
          builder: (context, state) =>
              const Scaffold(body: Text('Workout builder destination')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Workout Builder'));
    await tester.pumpAndSettle();

    expect(find.text('Workout builder destination'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/workouts/builder');
  });

  testWidgets('DashboardDrawer calendar uses go to /dashboard/calendar', (
    tester,
  ) async {
    final router = _drawerHarnessRouter(extraRoutes: const []);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coach Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Calendar destination'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.path,
      '/dashboard/calendar',
    );
  });
}

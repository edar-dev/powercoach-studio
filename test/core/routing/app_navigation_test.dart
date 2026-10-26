import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';

void main() {
  test('customer workout editor paths are customer-scoped', () {
    expect(
      customerWorkoutEditorPath('cust-1'),
      '/customers/cust-1/workouts/new',
    );
    expect(
      customerWorkoutEditorPath('cust-1', planId: 'plan-9'),
      '/customers/cust-1/workouts/plan-9',
    );
    expect(customerWorkoutsPath('cust-1'), '/customers/cust-1/workouts');
    expect(customerPath('cust-1'), '/customers/cust-1');
  });

  test('customer workout editor path supports session deep-link query', () {
    expect(
      customerWorkoutEditorPath(
        'cust-1',
        planId: 'plan-9',
        weekIndex: 2,
        dayIndex: 4,
      ),
      '/customers/cust-1/workouts/plan-9?week=2&day=4',
    );
  });

  test('schedule session detail path serializes query params', () {
    expect(
      scheduleSessionDetailPath(
        customerId: 'cust-1',
        planId: 'plan-9',
        weekIndex: 2,
        dayIndex: 4,
        date: DateTime(2026, 6, 16),
      ),
      '/dashboard/schedule/detail?customerId=cust-1&planId=plan-9&week=2&day=4&date=2026-06-16T00%3A00%3A00.000',
    );
  });

  testWidgets(
    'navigateBackFromSubscription uses from query when present',
    (tester) async {
      late GoRouter router;
      router = GoRouter(
        initialLocation: '${AppPaths.subscription}?from=/customers',
        routes: [
          GoRoute(
            path: AppPaths.subscription,
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => navigateBackFromSubscription(context),
                child: const Text('back-from-sub'),
              ),
            ),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) =>
                const Scaffold(body: Text('customers-dest')),
          ),
          GoRoute(
            path: AppPaths.dashboard,
            builder: (context, state) =>
                const Scaffold(body: Text('dashboard-dest')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('back-from-sub'));
      await tester.pumpAndSettle();

      expect(find.text('customers-dest'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/customers');
    },
  );

  testWidgets(
    'navigateBackFromSubscription falls back to dashboard without from',
    (tester) async {
      late GoRouter router;
      router = GoRouter(
        initialLocation: AppPaths.subscription,
        routes: [
          GoRoute(
            path: AppPaths.subscription,
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => navigateBackFromSubscription(context),
                child: const Text('back-from-sub'),
              ),
            ),
          ),
          GoRoute(
            path: AppPaths.dashboard,
            builder: (context, state) =>
                const Scaffold(body: Text('dashboard-dest')),
          ),
          GoRoute(
            path: AppPaths.settings,
            builder: (context, state) =>
                const Scaffold(body: Text('settings-dest')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('back-from-sub'));
      await tester.pumpAndSettle();

      expect(find.text('dashboard-dest'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppPaths.dashboard,
      );
      expect(find.text('settings-dest'), findsNothing);
    },
  );
}

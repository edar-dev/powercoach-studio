import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_coach_tools_hints.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_coach_tools_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('DashboardCoachToolsSection navigates to History', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => DashboardCoachToolsSection(
            loadHints: () async => const DashboardCoachToolsHints(
              loggedSessions30d: 3,
            ),
          ),
        ),
        GoRoute(
          path: '/workouts/diary',
          builder: (context, state) =>
              const Scaffold(body: Text('Diary destination')),
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

    expect(find.text('3 sessions (30d)'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Coach stats'), findsNothing);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Diary destination'), findsOneWidget);
  });

  test('workoutDiaryPath adds customerId query parameter', () {
    expect(workoutDiaryPath(), '/workouts/diary');
    expect(
      workoutDiaryPath(customerId: 'cust-42'),
      '/workouts/diary?customerId=cust-42',
    );
  });
}

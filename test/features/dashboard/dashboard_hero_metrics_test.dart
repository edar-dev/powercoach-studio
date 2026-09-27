import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_hero_metrics.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_no_plan_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_shortcuts_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_stale_plans_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

DashboardSnapshot _emptySnap() => const DashboardSnapshot(
      clientCount: 4,
      activePrograms: 7,
      weeklyUpdates: 2,
      todayItems: [],
      stalePlans: [],
      customersWithoutPlan: [],
    );

void main() {
  testWidgets('DashboardHeroMetrics renders four KPI labels and values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final l10n = AppLocalizations.of(context);
              return DashboardHeroMetrics(
                theme: theme,
                colorScheme: theme.colorScheme,
                l10n: l10n,
                snapshot: _emptySnap(),
                loading: false,
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Athletes followed'), findsOneWidget);
    expect(find.text('Active plans'), findsOneWidget);
    expect(find.text('Weekly updates'), findsOneWidget);
    expect(find.text('Coach attention'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('alerts'), findsOneWidget);
  });

  testWidgets('positive empty states for no-plan and stale sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final l10n = AppLocalizations.of(context);
              final snap = _emptySnap();
              return ListView(
                children: [
                  DashboardNoPlanSection(
                    theme: theme,
                    colorScheme: theme.colorScheme,
                    l10n: l10n,
                    snapshot: snap,
                  ),
                  DashboardStalePlansSection(
                    theme: theme,
                    colorScheme: theme.colorScheme,
                    l10n: l10n,
                    snapshot: snap,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.text('Every client has at least one program.'),
      findsOneWidget,
    );
    expect(
      find.text('No athletes waiting for a first plan assignment.'),
      findsOneWidget,
    );
    expect(
      find.text('All programs were updated within the last 14 days.'),
      findsOneWidget,
    );
    expect(
      find.text('No programs older than the 14-day refresh window.'),
      findsOneWidget,
    );
  });

  testWidgets('DashboardShortcutsSection navigates to exercise library', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              body: DashboardShortcutsSection(
                theme: theme,
                colorScheme: theme.colorScheme,
                l10n: l10n,
              ),
            );
          },
        ),
        GoRoute(
          path: '/exercise-library',
          builder: (context, state) =>
              const Scaffold(body: Text('Library destination')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: StitchM3Theme.dark,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Management shortcuts'), findsOneWidget);
    await tester.tap(find.text('Exercise library'));
    await tester.pumpAndSettle();
    expect(find.text('Library destination'), findsOneWidget);
  });
}

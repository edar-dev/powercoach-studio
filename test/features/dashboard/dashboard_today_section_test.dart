import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_today_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

DashboardTodayItem _todayItem() {
  return DashboardTodayItem(
    customerId: 'cust-1',
    planId: 'plan-1',
    weekIndex: 0,
    dayIndex: 1,
    sessionLabel: 'Day B',
    clientName: 'Anna Bianchi',
    programName: 'Strength',
    date: DateTime(2026, 5, 12),
  );
}

Widget _wrapSection({
  required DashboardSnapshot snapshot,
  Future<void> Function(DashboardTodayItem item)? onSessionTap,
}) {
  return MaterialApp(
    theme: StitchM3Theme.dark,
    locale: const Locale('it'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final theme = Theme.of(context);
          return DashboardTodaySection(
            theme: theme,
            colorScheme: theme.colorScheme,
            l10n: l10n,
            snapshot: snapshot,
            loading: false,
            onSessionTap: onSessionTap,
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets(
    'today empty shows visible Apri agenda label on primary CTA',
    (tester) async {
      await tester.pumpWidget(
        _wrapSection(
          snapshot: const DashboardSnapshot(
            clientCount: 0,
            activePrograms: 0,
            weeklyUpdates: 0,
            todayItems: [],
            customersWithoutPlan: [],
            stalePlans: [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apri agenda'), findsOneWidget);
      // Gym-mode CTA removed (Wave C); agenda is the sole empty-state action.
      expect(find.text('Apri modalità sala'), findsNothing);

      // FilledButton.icon uses a private subclass; match via `is FilledButton`.
      final filled = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Apri agenda'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        ),
      );
      final style = filled.style;
      expect(style?.foregroundColor?.resolve({}), Colors.white);
      expect(style?.backgroundColor?.resolve({}), StitchM3Theme.accent);
    },
  );

  testWidgets(
    'today row tap invokes onSessionTap with item fields',
    (tester) async {
      final item = _todayItem();
      DashboardTodayItem? tapped;

      await tester.pumpWidget(
        _wrapSection(
          snapshot: DashboardSnapshot(
            clientCount: 1,
            activePrograms: 1,
            weeklyUpdates: 0,
            todayItems: [item],
            customersWithoutPlan: const [],
            stalePlans: const [],
          ),
          onSessionTap: (tappedItem) async {
            tapped = tappedItem;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Anna Bianchi'), findsOneWidget);
      await tester.tap(find.text('Anna Bianchi'));
      await tester.pumpAndSettle();

      expect(tapped, isNotNull);
      expect(tapped!.customerId, item.customerId);
      expect(tapped!.planId, item.planId);
      expect(tapped!.weekIndex, item.weekIndex);
      expect(tapped!.dayIndex, item.dayIndex);
      expect(tapped!.sessionLabel, item.sessionLabel);
      expect(tapped!.clientName, item.clientName);
      expect(tapped!.programName, item.programName);
      expect(tapped!.date, item.date);
    },
  );
}

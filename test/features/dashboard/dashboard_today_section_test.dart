import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_today_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'today empty shows visible Apri agenda label on primary CTA',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
                  snapshot: const DashboardSnapshot(
                    clientCount: 0,
                    activePrograms: 0,
                    weeklyUpdates: 0,
                    todayItems: [],
                    customersWithoutPlan: [],
                    stalePlans: [],
                  ),
                  loading: false,
                );
              },
            ),
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
}

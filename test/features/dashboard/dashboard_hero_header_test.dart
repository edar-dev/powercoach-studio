import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_hero_header.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('DashboardHeroHeader shows greeting and action labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: DashboardHeroHeader(
            displayName: 'Alex',
            dateLabel: 'Monday, 2 November',
          ),
        ),
      ),
    );

    expect(find.text('Monday, 2 November'), findsOneWidget);
    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('New customer'), findsOneWidget);
    expect(find.text('Open calendar'), findsOneWidget);
    expect(find.text('Open diary'), findsOneWidget);
  });
}

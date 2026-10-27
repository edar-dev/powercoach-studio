import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_app_bar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('showLogo false renders title without logo badge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          appBar: StitchAppBar(title: 'Hub', showLogo: false),
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Hub'), findsOneWidget);
    expect(find.byTooltip('Go to Today'), findsNothing);
  });

  testWidgets('showLogo true includes home tooltip on logo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          appBar: StitchAppBar(title: 'Hub'),
          body: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Hub'), findsOneWidget);
    expect(find.byTooltip('Go to Today'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/cloud_recovery_dialog.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('cloud recovery dialog shows copy and restores on confirm',
      (tester) async {
    CloudRecoveryChoice? choice;

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              choice = await showCloudRecoveryDialog(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Restore latest cloud backup?'), findsOneWidget);
    expect(
      find.textContaining('no clients or workout plans', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Restore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(choice, CloudRecoveryChoice.restore);
  });

  testWidgets('cloud recovery dialog not now returns notNow', (tester) async {
    CloudRecoveryChoice? choice;

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              choice = await showCloudRecoveryDialog(context);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Not now'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(choice, CloudRecoveryChoice.notNow);
  });
}

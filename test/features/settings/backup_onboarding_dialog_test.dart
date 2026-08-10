import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/settings/presentation/backup_onboarding_dialog.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'backup onboarding dialog shows the desk-to-gym hint and export action',
    (tester) async {
      var exported = false;
      var openedSettings = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showBackupOnboardingDialog(
                context,
                onOpenSettings: () => openedSettings = true,
                onExportBackup: () async {
                  exported = true;
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Protect your coach data'), findsOneWidget);
      expect(
        find.textContaining('Plan on desktop, then bring the same account'),
        findsOneWidget,
      );

      await tester.tap(find.text('Export backup now'));
      await tester.pumpAndSettle();
      expect(exported, isTrue);

      expect(openedSettings, isFalse);
    },
  );
}

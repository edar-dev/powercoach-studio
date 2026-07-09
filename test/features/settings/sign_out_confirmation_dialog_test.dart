import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/settings/presentation/sign_out_confirmation_dialog.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('sign out dialog can export backup or proceed', (tester) async {
    var exportCalled = false;
    bool? proceed;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              proceed = await showSignOutConfirmationDialog(
                context,
                onExportBackup: () async {
                  exportCalled = true;
                },
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Sign out and remove local data?'), findsOneWidget);

    await tester.tap(find.text('Export backup'));
    await tester.pumpAndSettle();
    expect(exportCalled, isTrue);
    expect(proceed, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out anyway'));
    await tester.pumpAndSettle();
    expect(proceed, isTrue);
  });
}

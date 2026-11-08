import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('showAppConfirmDialog uses bottom sheet on phone width', (
    tester,
  ) async {
    final result = <bool?>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result.add(
                      await showAppConfirmDialog(
                        context: context,
                        title: 'Elimina',
                        message: 'Confermi?',
                        confirmLabel: 'Elimina',
                        cancelLabel: 'Annulla',
                        destructive: true,
                      ),
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Elimina'), findsWidgets);
    expect(find.text('Confermi?'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();
    expect(result.single, isTrue);
  });

  testWidgets('showAppConfirmDialog keeps AlertDialog on tablet+', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(900, 700)),
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showAppConfirmDialog(
                      context: context,
                      title: 'Elimina',
                      message: 'Confermi?',
                      confirmLabel: 'Elimina',
                      cancelLabel: 'Annulla',
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}

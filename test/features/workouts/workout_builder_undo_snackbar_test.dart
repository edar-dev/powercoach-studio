import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('undo snack uses showAppSnackBar with 5s Annulla action', (
    tester,
  ) async {
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
              return Center(
                child: FilledButton(
                  onPressed: () {
                    showAppSnackBar(
                      context,
                      content: Text(l10n.workoutBuilderExerciseRemoved),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: l10n.workoutBuilderUndo,
                        onPressed: () {},
                      ),
                    );
                  },
                  child: const Text('Remove'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Remove'));
    await tester.pump();

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.duration, const Duration(seconds: 5));
    expect(snack.behavior, SnackBarBehavior.floating);
    expect(snack.action?.label, 'Annulla');
    expect(find.text('Esercizio eliminato'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
  });
}

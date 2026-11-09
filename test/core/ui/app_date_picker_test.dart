import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_date_picker.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('phone path opens bottom sheet calendar', (tester) async {
    DateTime? picked;
    final initial = DateTime(2026, 3, 15);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(
          theme: StitchM3Theme.dark,
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: FilledButton(
                    onPressed: () async {
                      picked = await showAppDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        confirmLabel: 'Conferma data',
                      );
                    },
                    child: const Text('Pick'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(DatePickerDialog), findsNothing);

    await tester.tap(find.text('Conferma data'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.year, 2026);
    expect(picked!.month, 3);
    expect(picked!.day, 15);
  });

  testWidgets('tablet path keeps Material date picker dialog', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(900, 1200)),
        child: MaterialApp(
          theme: StitchM3Theme.dark,
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: FilledButton(
                    onPressed: () {
                      showAppDatePicker(
                        context: context,
                        initialDate: DateTime(2026, 3, 15),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                    },
                    child: const Text('Pick'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });
}

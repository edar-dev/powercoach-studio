import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_edit_set_dialog.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _harness() {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () {
                showEditSetDialog(
                  context,
                  theme,
                  theme.colorScheme,
                  '3',
                  '5',
                  '75kg',
                  '',
                  (_, _, _, _) {},
                );
              },
              child: const Text('Open set'),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> _setViewSize(WidgetTester tester, Size size) async {
  final view = tester.view;
  view.physicalSize = size;
  view.devicePixelRatio = 1.0;
  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });
  await tester.pump();
}

TextField _fieldByLabel(WidgetTester tester, String label) {
  final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
  for (final field in fields) {
    final decoration = field.decoration;
    if (decoration?.labelText == label) return field;
  }
  fail('TextField with label "$label" not found');
}

void main() {
  testWidgets('phone edit-set sheet is nearly full height', (tester) async {
    const phone = Size(390, 844);
    await _setViewSize(tester, phone);

    await tester.pumpWidget(_harness());
    await tester.tap(find.text('Open set'));
    await tester.pumpAndSettle();

    expect(find.text('Modifica blocco'), findsOneWidget);
    expect(find.text('Salva'), findsOneWidget);

    // fullScreen path uses SizedBox(height: mediaHeight * 0.96).
    final tall = find.byWidgetPredicate(
      (w) =>
          w is SizedBox &&
          w.height != null &&
          w.height! > phone.height * 0.8,
    );
    expect(tall, findsWidgets);
    final sheet = tester.widget<SizedBox>(tall.first);
    expect(sheet.height!, greaterThan(phone.height * 0.8));
    expect(sheet.height!, lessThanOrEqualTo(phone.height * 0.96 + 1));
  });

  testWidgets('desktop edit-set sheet still opens', (tester) async {
    const desktop = Size(1200, 900);
    await _setViewSize(tester, desktop);

    await tester.pumpWidget(_harness());
    await tester.tap(find.text('Open set'));
    await tester.pumpAndSettle();

    expect(find.text('Modifica blocco'), findsOneWidget);
    expect(find.text('Salva'), findsOneWidget);
  });

  testWidgets('edit-set fields use Serie→Rip→Carico→Note focus actions', (
    tester,
  ) async {
    const phone = Size(390, 844);
    await _setViewSize(tester, phone);

    await tester.pumpWidget(_harness());
    await tester.tap(find.text('Open set'));
    await tester.pumpAndSettle();

    final sets = _fieldByLabel(tester, 'Serie');
    final reps = _fieldByLabel(tester, 'Rip');
    final load = _fieldByLabel(tester, 'Carico');
    final note = _fieldByLabel(tester, 'Note');

    expect(sets.textInputAction, TextInputAction.next);
    expect(reps.textInputAction, TextInputAction.next);
    expect(load.textInputAction, TextInputAction.next);
    expect(note.textInputAction, TextInputAction.done);
  });

  testWidgets('edit-set sheet shows Material drag handle chrome', (
    tester,
  ) async {
    const phone = Size(390, 844);
    await _setViewSize(tester, phone);

    await tester.pumpWidget(_harness());
    await tester.tap(find.text('Open set'));
    await tester.pumpAndSettle();

    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.showDragHandle, isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_ref.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/maximal_set_panel.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpPanel(
    WidgetTester tester, {
    required MaximalSetPanel panel,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: panel),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty maximal shows CTA and chips do not apply', (tester) async {
    String? applied;
    await pumpPanel(
      tester,
      panel: MaximalSetPanel(
        maximalRef: null,
        maximalKg: null,
        resolveMode: MaximalResolveMode.massimoStorico,
        onResolveModeChanged: (_) {},
        showResolveModeToggle: false,
        percent: 80,
        onPercentChanged: (_) {},
        incrementKg: 2.5,
        onApplyLoad: (load) => applied = load,
        onSetMaximal: () {},
      ),
    );

    expect(find.textContaining('Maximal'), findsWidgets);
    expect(find.text('Set maximal'), findsOneWidget);

    await tester.tap(find.text('80'));
    await tester.pumpAndSettle();
    expect(applied, isNull);
  });

  testWidgets('chip and slider fill load with same rounded kg', (tester) async {
    final applied = <String>[];
    var percent = 80;

    await pumpPanel(
      tester,
      panel: MaximalSetPanel(
        maximalRef: const MaximalRef.measurement(lift: MaximalLift.bench),
        maximalKg: 100,
        resolveMode: MaximalResolveMode.massimoStorico,
        onResolveModeChanged: (_) {},
        showResolveModeToggle: true,
        percent: percent,
        onPercentChanged: (p) => percent = p,
        incrementKg: 2.5,
        onApplyLoad: applied.add,
      ),
    );

    expect(find.text('Maximal: 100 kg'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('Historic max'), findsOneWidget);

    await tester.tap(find.text('80'));
    await tester.pumpAndSettle();
    expect(applied, ['80kg']);

    await tester.tap(find.text('75'));
    await tester.pumpAndSettle();
    expect(applied.last, '75kg');
  });

  testWidgets('Italian locale uses Massimale copy', (tester) async {
    await pumpPanel(
      tester,
      locale: const Locale('it'),
      panel: MaximalSetPanel(
        maximalRef: null,
        maximalKg: null,
        resolveMode: MaximalResolveMode.massimoStorico,
        onResolveModeChanged: (_) {},
        showResolveModeToggle: false,
        percent: 80,
        onPercentChanged: (_) {},
        incrementKg: 2.5,
        onApplyLoad: (_) {},
        onSetMaximal: () {},
      ),
    );

    expect(find.text('Imposta massimale'), findsOneWidget);
    expect(find.textContaining('Massimale'), findsWidgets);
  });

  testWidgets('75% of 142.5 kg rounds to 107.5kg with 2.5 increment',
      (tester) async {
    String? applied;
    await pumpPanel(
      tester,
      panel: MaximalSetPanel(
        maximalRef: const MaximalRef.measurement(lift: MaximalLift.squat),
        maximalKg: 142.5,
        resolveMode: MaximalResolveMode.massimoStorico,
        onResolveModeChanged: (_) {},
        showResolveModeToggle: false,
        percent: 80,
        onPercentChanged: (_) {},
        incrementKg: 2.5,
        onApplyLoad: (load) => applied = load,
      ),
    );

    await tester.tap(find.text('75'));
    await tester.pumpAndSettle();
    expect(applied, '107.5kg');
  });
}

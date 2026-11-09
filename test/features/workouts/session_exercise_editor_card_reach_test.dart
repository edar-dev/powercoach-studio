import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_exercise_editor_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Finder _expandCollapseButton() {
  return find.byWidgetPredicate(
    (w) =>
        w is IconButton &&
        w.constraints?.minWidth == 44 &&
        w.constraints?.minHeight == 44 &&
        (w.icon is Icon) &&
        ((w.icon as Icon).icon == Icons.expand_more ||
            (w.icon as Icon).icon == Icons.expand_less),
  );
}

void main() {
  testWidgets(
    'phone session exercise card expand/collapse hit targets are ≥44px',
    (tester) async {
      const phone = Size(390, 844);
      tester.view.physicalSize = phone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var expanded = false;
      const exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        sets: '3',
        reps: '5',
        rpe: '100kg',
        setDetails: [
          ExerciseSet(sets: '3', reps: '5', rpe: '100kg'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('it'),
          supportedLocales: const [Locale('it'), Locale('en')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: phone),
              child: StatefulBuilder(
                builder: (context, setState) {
                  final theme = Theme.of(context);
                  return SessionExerciseEditorCard(
                    theme: theme,
                    colorScheme: theme.colorScheme,
                    exercise: exercise,
                    index: 1,
                    expanded: expanded,
                    onExpandedChanged: (value) =>
                        setState(() => expanded = value),
                    onUpdateSet: (_, _, _, _, _) {},
                    onRemoveSet: (_) {},
                    onAddSet: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expandBtn = _expandCollapseButton();
      expect(expandBtn, findsOneWidget);

      // Structural: IconButton declares ≥44 constraints (plan §4 case 4).
      final expandWidget = tester.widget<IconButton>(expandBtn);
      expect(expandWidget.constraints!.minWidth, greaterThanOrEqualTo(44));
      expect(expandWidget.constraints!.minHeight, greaterThanOrEqualTo(44));

      // Title row ConstrainedBox(minHeight: 44) under the expand InkWell.
      final titleTap = find.text('Squat');
      expect(titleTap, findsOneWidget);
      final titleBox = find.ancestor(
        of: titleTap,
        matching: find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.minHeight >= 44,
        ),
      );
      expect(titleBox, findsWidgets);
      expect(tester.getSize(titleBox.first).height, greaterThanOrEqualTo(44));

      await tester.tap(expandBtn);
      await tester.pumpAndSettle();
      expect(expanded, isTrue);

      final collapseBtn = _expandCollapseButton();
      expect(collapseBtn, findsOneWidget);
      final collapseWidget = tester.widget<IconButton>(collapseBtn);
      expect(collapseWidget.constraints!.minWidth, greaterThanOrEqualTo(44));
      expect(collapseWidget.constraints!.minHeight, greaterThanOrEqualTo(44));
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_exercise_editor_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

const _exercise = Exercise(
  id: 'e1',
  name: 'Squat',
  sets: '3',
  reps: '5',
  rpe: '100kg',
  note: 'Tieni il core',
  setDetails: [
    ExerciseSet(sets: '3', reps: '5', rpe: '100kg'),
  ],
);

Widget _app({required Size size, required bool expanded}) {
  return MaterialApp(
    theme: StitchM3Theme.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return SingleChildScrollView(
              child: SessionExerciseEditorCard(
                theme: theme,
                colorScheme: theme.colorScheme,
                exercise: _exercise,
                index: 1,
                expanded: expanded,
                onExpandedChanged: (_) {},
                onEdit: (
                  a,
                  b,
                  c,
                  d,
                  e, {
                  setDetails,
                  shortName,
                  prescriptionScope,
                }) {},
                onUpdateSet: (a, b, c, d, e) {},
                onRemoveSet: (a) {},
                onAddSet: () {},
              ),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('narrow phone tucks note behind Altro disclosure', (tester) async {
    const phone = Size(390, 844);
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(size: phone, expanded: true));
    await tester.pumpAndSettle();

    expect(find.text('Altro'), findsOneWidget);
    // Note field hidden until Altro expands.
    expect(find.text('Tieni il core'), findsNothing);

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();
    expect(find.text('Tieni il core'), findsOneWidget);
  });

  testWidgets('tablet keeps note visible without Altro', (tester) async {
    const tablet = Size(800, 1024);
    tester.view.physicalSize = tablet;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(size: tablet, expanded: true));
    await tester.pumpAndSettle();

    expect(find.text('Altro'), findsNothing);
    expect(find.text('Tieni il core'), findsOneWidget);
  });
}

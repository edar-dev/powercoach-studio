import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_log_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('SessionLogSheetBody saves reps and load edits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () async {
                  await showSessionLogSheet(
                    context: context,
                    plannedExercises: const [
                      Exercise(
                        id: 'e1',
                        name: 'Squat',
                        sets: '3',
                        reps: '5',
                        rpe: '100kg',
                        setDetails: [
                          ExerciseSet(reps: '5', rpe: '100kg'),
                        ],
                      ),
                    ],
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Set 1'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Reps'), '6');
    await tester.enterText(find.widgetWithText(TextField, 'Load'), '105kg');
    await tester.tap(find.text('Save session'));
    await tester.pumpAndSettle();

    expect(find.text('Log session'), findsNothing);
  });

  testWidgets(
    'SessionLogSheetBody captures optional RPE/pain check-in',
    (tester) async {
      SessionLogResult? result;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () async {
                    result = await showSessionLogSheet(
                      context: context,
                      plannedExercises: const [
                        Exercise(
                          id: 'e1',
                          name: 'Squat',
                          sets: '3',
                          reps: '5',
                          rpe: '',
                        ),
                      ],
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Pain location field is hidden until a non-zero pain level is picked.
      expect(find.widgetWithText(TextField, 'Where? (optional)'), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, '8').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '3').last);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Where? (optional)'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Where? (optional)'),
        'left knee',
      );

      await tester.tap(find.text('Save session'));
      await tester.pumpAndSettle();

      expect(result?.sessionRpe, 8);
      expect(result?.painLevel, 3);
      expect(result?.painLocation, 'left knee');
    },
  );
}

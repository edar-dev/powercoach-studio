import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_diary_entry_body.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('WorkoutDiaryEntryBody shows exercises and notes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              body: WorkoutDiaryEntryBody(
                l10n: l10n,
                execution: SessionExecution(
                  sessionKey: '0-0',
                  weekIndex: 0,
                  dayIndex: 0,
                  sessionDate: DateTime(2026, 6, 14),
                  status: PlanSessionStatus.completed,
                  notes: 'Felt strong',
                  exercises: const [
                    ExecutedExercise(
                      exerciseId: 'e1',
                      name: 'Bench press',
                      sets: [ExecutedSet(reps: '8', load: '80kg')],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Felt strong'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.textContaining('80kg'), findsOneWidget);
  });
}

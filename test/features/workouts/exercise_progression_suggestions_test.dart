import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_progression_suggestions.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';

SessionExecution _executionWith(ExecutedExercise exercise, {DateTime? date}) {
  return SessionExecution(
    sessionKey: '0-0',
    weekIndex: 0,
    dayIndex: 0,
    sessionDate: date ?? DateTime(2026, 6, 1),
    completedAt: date ?? DateTime(2026, 6, 1),
    status: PlanSessionStatus.completed,
    exercises: [exercise],
  );
}

void main() {
  group('suggestExerciseProgression rule matrix', () {
    test('returns insufficientData when no execution matches the exercise', () {
      const exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        sets: '3',
        reps: '8',
        rpe: '100kg',
      );

      final suggestion = suggestExerciseProgression(
        plannedExercise: exercise,
        executions: const [],
      );

      expect(suggestion.type, ProgressionSuggestionType.insufficientData);
      expect(suggestion.isActionable, isFalse);
    });

    test('returns maintain when the last matching session was partial', () {
      const exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        sets: '3',
        reps: '8',
        rpe: '100kg',
      );
      final execution = _executionWith(
        const ExecutedExercise(
          exerciseId: 'e1',
          name: 'Squat',
          completed: true,
          sets: [
            ExecutedSet(reps: '8', load: '100kg', completed: true),
            ExecutedSet(reps: '', load: '', completed: false),
          ],
        ),
      );

      final suggestion = suggestExerciseProgression(
        plannedExercise: exercise,
        executions: [execution],
      );

      expect(suggestion.type, ProgressionSuggestionType.maintain);
      expect(suggestion.isActionable, isFalse);
    });

    test(
      'suggests a ~2.5%/1kg load bump when the last full session hit a numeric load',
      () {
        const exercise = Exercise(
          id: 'e1',
          name: 'Squat',
          sets: '1',
          reps: '5-8',
          rpe: '100kg',
        );
        final execution = _executionWith(
          const ExecutedExercise(
            exerciseId: 'e1',
            name: 'Squat',
            completed: true,
            sets: [ExecutedSet(reps: '6', load: '100kg', completed: true)],
          ),
        );

        final suggestion = suggestExerciseProgression(
          plannedExercise: exercise,
          executions: [execution],
        );

        expect(suggestion.type, ProgressionSuggestionType.increaseLoad);
        expect(suggestion.suggestedLoad, '102.5kg');
        expect(suggestion.isActionable, isTrue);
      },
    );

    test('applies the minimum 1-unit step for small loads', () {
      const exercise = Exercise(
        id: 'e1',
        name: 'Curl',
        sets: '1',
        reps: '10-15',
        rpe: '10kg',
      );
      final execution = _executionWith(
        const ExecutedExercise(
          exerciseId: 'e1',
          name: 'Curl',
          completed: true,
          sets: [ExecutedSet(reps: '12', load: '10kg', completed: true)],
        ),
      );

      final suggestion = suggestExerciseProgression(
        plannedExercise: exercise,
        executions: [execution],
      );

      expect(suggestion.type, ProgressionSuggestionType.increaseLoad);
      expect(suggestion.suggestedLoad, '11kg');
    });

    test(
      'suggests +1 rep when completed reps hit the top of the prescribed range',
      () {
        const exercise = Exercise(
          id: 'e1',
          name: 'Bench',
          sets: '1',
          reps: '8-10',
          rpe: '80kg',
        );
        final execution = _executionWith(
          const ExecutedExercise(
            exerciseId: 'e1',
            name: 'Bench',
            completed: true,
            sets: [ExecutedSet(reps: '10', load: '80kg', completed: true)],
          ),
        );

        final suggestion = suggestExerciseProgression(
          plannedExercise: exercise,
          executions: [execution],
        );

        expect(suggestion.type, ProgressionSuggestionType.increaseReps);
        expect(suggestion.suggestedReps, '11');
        expect(suggestion.isActionable, isTrue);
      },
    );

    test('does not suggest more reps when below the top of the range', () {
      const exercise = Exercise(
        id: 'e1',
        name: 'Bench',
        sets: '1',
        reps: '8-10',
        rpe: '80kg',
      );
      final execution = _executionWith(
        const ExecutedExercise(
          exerciseId: 'e1',
          name: 'Bench',
          completed: true,
          sets: [ExecutedSet(reps: '8', load: '80kg', completed: true)],
        ),
      );

      final suggestion = suggestExerciseProgression(
        plannedExercise: exercise,
        executions: [execution],
      );

      expect(suggestion.type, ProgressionSuggestionType.increaseLoad);
    });

    test(
      'degrades gracefully to a generic load suggestion for non-numeric load text',
      () {
        const exercise = Exercise(
          id: 'e1',
          name: 'Deadlift',
          sets: '1',
          reps: '3-5',
          rpe: '@8',
        );
        final execution = _executionWith(
          const ExecutedExercise(
            exerciseId: 'e1',
            name: 'Deadlift',
            completed: true,
            sets: [ExecutedSet(reps: '4', load: 'bodyweight', completed: true)],
          ),
        );

        final suggestion = suggestExerciseProgression(
          plannedExercise: exercise,
          executions: [execution],
        );

        expect(suggestion.type, ProgressionSuggestionType.increaseLoad);
        expect(suggestion.suggestedLoad, isNull);
        expect(suggestion.isActionable, isFalse);
      },
    );

    test('matches by name when exerciseId is blank, using the newest session', () {
      const exercise = Exercise(
        id: '',
        name: 'Overhead Press',
        sets: '1',
        reps: '5',
        rpe: '40kg',
      );
      final older = _executionWith(
        const ExecutedExercise(
          exerciseId: '',
          name: 'Overhead Press',
          completed: true,
          sets: [ExecutedSet(reps: '5', load: '40kg', completed: true)],
        ),
        date: DateTime(2026, 5, 1),
      );
      final newer = _executionWith(
        const ExecutedExercise(
          exerciseId: '',
          name: 'overhead press',
          completed: true,
          sets: [ExecutedSet(reps: '5', load: '42.5kg', completed: true)],
        ),
        date: DateTime(2026, 6, 1),
      );

      final suggestion = suggestExerciseProgression(
        plannedExercise: exercise,
        executions: [older, newer],
      );

      expect(suggestion.suggestedLoad, '43.5kg');
    });

    test('ignores non-matching exercises in the same session', () {
      const exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        sets: '1',
        reps: '5',
        rpe: '100kg',
      );
      final execution = _executionWith(
        const ExecutedExercise(
          exerciseId: 'e2',
          name: 'Lunge',
          completed: true,
          sets: [ExecutedSet(reps: '5', load: '20kg', completed: true)],
        ),
      );

      final suggestion = suggestExerciseProgression(
        plannedExercise: exercise,
        executions: [execution],
      );

      expect(suggestion.type, ProgressionSuggestionType.insufficientData);
    });
  });
}

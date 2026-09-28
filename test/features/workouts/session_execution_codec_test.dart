import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';

void main() {
  test('SessionExecution round-trips through JSON', () {
    final original = SessionExecution(
      sessionKey: '1-2',
      weekIndex: 1,
      dayIndex: 2,
      sessionDate: DateTime(2026, 6, 10),
      status: PlanSessionStatus.completed,
      completedAt: DateTime(2026, 6, 10, 18, 30),
      notes: 'Felt strong',
      exercises: const [
        ExecutedExercise(
          exerciseId: 'ex-1',
          name: 'Squat',
          completed: true,
          sets: [
            ExecutedSet(reps: '5', load: '100', completed: true),
          ],
        ),
      ],
    );

    final restored = SessionExecution.fromJson(original.toJson());
    expect(restored.sessionKey, original.sessionKey);
    expect(restored.status, PlanSessionStatus.completed);
    expect(restored.notes, 'Felt strong');
    expect(restored.exercises, hasLength(1));
    expect(restored.exercises.first.sets.first.load, '100');
  });

  test('legacy SessionExecution check-in fields are ignored on read', () {
    final restored = SessionExecution.fromJson({
      'sessionKey': '1-2',
      'weekIndex': 1,
      'dayIndex': 2,
      'sessionDate': '2026-06-10',
      'status': 'completed',
      'sessionRpe': 8,
      'painLevel': 3,
      'painLocation': 'left knee',
      'notes': 'ok',
    });
    final json = restored.toJson();
    expect(json.containsKey('sessionRpe'), isFalse);
    expect(json.containsKey('painLevel'), isFalse);
    expect(json.containsKey('painLocation'), isFalse);
    expect(restored.notes, 'ok');
  });

  test('toJson does not write check-in fields', () {
    final execution = SessionExecution(
      sessionKey: '0-0',
      weekIndex: 0,
      dayIndex: 0,
      sessionDate: DateTime(2026, 6, 1),
      status: PlanSessionStatus.completed,
    );
    final json = execution.toJson();
    expect(json.containsKey('sessionRpe'), isFalse);
    expect(json.containsKey('painLevel'), isFalse);
    expect(json.containsKey('painLocation'), isFalse);
  });

  test('parseSessionExecutions ignores invalid entries', () {
    final parsed = parseSessionExecutions({
      '0-0': {
        'sessionKey': '0-0',
        'weekIndex': 0,
        'dayIndex': 0,
        'sessionDate': '2026-06-01',
        'status': 'completed',
      },
      'bad': 'not-a-map',
    });
    expect(parsed, hasLength(1));
    expect(parsed['0-0']?.status, PlanSessionStatus.completed);
  });

  test('parseSessionExecutions returns empty map for non-map input', () {
    expect(parseSessionExecutions(null), isEmpty);
    expect(parseSessionExecutions(<dynamic>[]), isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_diary_metrics.dart';

void main() {
  group('parseRpeFromLoad', () {
    test('parses bare and combined load@rpe markers', () {
      expect(parseRpeFromLoad('@8'), 8);
      expect(parseRpeFromLoad('60@8'), 8);
      expect(parseRpeFromLoad('75kg @8.5'), 8.5);
      expect(parseRpeFromLoad('60'), isNull);
      expect(parseRpeFromLoad(''), isNull);
      expect(parseRpeFromLoad('@11'), isNull);
    });
  });

  group('parseLoadKg with @', () {
    test('reads kg before @ and ignores pure RPE', () {
      expect(parseLoadKg('60@8'), 60);
      expect(parseLoadKg('@8'), isNull);
      expect(parseLoadKg('75kg'), 75);
    });
  });

  group('computeDiaryKpis avgRpe', () {
    test('averages RPE samples across sessions', () {
      final entries = [
        SessionExecutionEntry(
          planId: 'p1',
          customerId: 'c1',
          planName: 'A',
          execution: SessionExecution(
            sessionKey: '0-0',
            weekIndex: 0,
            dayIndex: 0,
            status: PlanSessionStatus.completed,
            sessionDate: DateTime(2026, 1, 1),
            exercises: [
              ExecutedExercise(
                exerciseId: 'ex1',
                name: 'Squat',
                sets: const [
                  ExecutedSet(load: '100@8', reps: '5'),
                  ExecutedSet(load: '100@9', reps: '5'),
                ],
              ),
            ],
          ),
        ),
        SessionExecutionEntry(
          planId: 'p1',
          customerId: 'c1',
          planName: 'A',
          execution: SessionExecution(
            sessionKey: '0-1',
            weekIndex: 0,
            dayIndex: 1,
            status: PlanSessionStatus.skipped,
            sessionDate: DateTime(2026, 1, 2),
            exercises: const [],
          ),
        ),
      ];

      final kpis = computeDiaryKpis(entries);
      expect(kpis.completedCount, 1);
      expect(kpis.skippedCount, 1);
      expect(kpis.compliancePercent, 50);
      expect(kpis.hasRpeSamples, isTrue);
      expect(kpis.avgRpe, closeTo(8.5, 0.01));
      expect(kpis.hasParsableVolume, isTrue);
      expect(formatAvgRpe(kpis.avgRpe!), '8.5');
    });
  });
}

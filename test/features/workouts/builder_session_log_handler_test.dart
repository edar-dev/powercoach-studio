import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/plan_session_status_service.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/features/workouts/presentation/builder_session_log_handler.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_log_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class _FakeExecutionService extends SessionExecutionService {
  _FakeExecutionService({this.existing})
    : super(
        repository: WorkoutPlanRepository(offline: OfflineRepositorySupport()),
      );

  SessionExecution? existing;

  @override
  Future<SessionExecution?> get({
    required String planId,
    required String sessionKey,
  }) async => existing;
}

class _RecordingStatusService extends PlanSessionStatusService {
  _RecordingStatusService()
    : super(
        repository: WorkoutPlanRepository(offline: OfflineRepositorySupport()),
      );

  int callCount = 0;
  String? planId;
  int? weekIndex;
  int? dayIndex;
  PlanSessionStatus? status;
  List<ExecutedExercise>? exercises;
  String? notes;
  String? source;
  bool throwOnCall = false;

  @override
  Future<void> setSessionStatus({
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required PlanSessionStatus status,
    DateTime? sessionDate,
    List<ExecutedExercise> exercises = const [],
    String notes = '',
    String source = 'unknown',
  }) async {
    if (throwOnCall) throw StateError('save failed');
    callCount++;
    this.planId = planId;
    this.weekIndex = weekIndex;
    this.dayIndex = dayIndex;
    this.status = status;
    this.exercises = exercises;
    this.notes = notes;
    this.source = source;
  }
}

const _planned = [
  Exercise(id: 'e1', name: 'Squat', sets: '3', reps: '5', rpe: ''),
];

Future<bool> _runLog(
  WidgetTester tester, {
  required BuilderSessionLogHandler handler,
  String planId = 'plan-1',
  int weekIndex = 0,
  int dayIndex = 0,
  List<Exercise> plannedExercises = _planned,
}) async {
  late bool result;
  await tester.pumpWidget(
    MaterialApp(
      theme: StitchM3Theme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return FilledButton(
              onPressed: () async {
                result = await handler.logSession(
                  context: context,
                  planId: planId,
                  weekIndex: weekIndex,
                  dayIndex: dayIndex,
                  plannedExercises: plannedExercises,
                );
              },
              child: const Text('Log'),
            );
          },
        ),
      ),
    ),
  );
  await tester.tap(find.text('Log'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('logSession saves completed status from sheet result', (
    tester,
  ) async {
    final status = _RecordingStatusService();
    const savedExercises = [
      ExecutedExercise(exerciseId: 'e1', name: 'Squat'),
    ];
    final handler = BuilderSessionLogHandler(
      executionService: _FakeExecutionService(),
      statusService: status,
      showLogSheet:
          ({
            required BuildContext context,
            required List<Exercise> plannedExercises,
            List<ExecutedExercise>? initialExercises,
            String initialNotes = '',
          }) async {
            expect(plannedExercises, hasLength(1));
            expect(plannedExercises.first.name, 'Squat');
            return const SessionLogResult(
              exercises: savedExercises,
              notes: 'Felt strong',
            );
          },
    );

    final ok = await _runLog(tester, handler: handler);
    expect(ok, isTrue);
    expect(status.callCount, 1);
    expect(status.planId, 'plan-1');
    expect(status.weekIndex, 0);
    expect(status.dayIndex, 0);
    expect(status.status, PlanSessionStatus.completed);
    expect(status.exercises, savedExercises);
    expect(status.notes, 'Felt strong');
    expect(status.source, 'workout_builder');
    expect(find.text('Session logged.'), findsOneWidget);
  });

  testWidgets('logSession cancel does not save', (tester) async {
    final status = _RecordingStatusService();
    final handler = BuilderSessionLogHandler(
      executionService: _FakeExecutionService(),
      statusService: status,
      showLogSheet:
          ({
            required BuildContext context,
            required List<Exercise> plannedExercises,
            List<ExecutedExercise>? initialExercises,
            String initialNotes = '',
          }) async =>
              null,
    );

    final ok = await _runLog(tester, handler: handler);
    expect(ok, isFalse);
    expect(status.callCount, 0);
  });

  testWidgets('logSession prefills sheet from existing execution', (
    tester,
  ) async {
    final status = _RecordingStatusService();
    final existing = SessionExecution(
      sessionKey: WorkoutRoutine.sessionKey(0, 0),
      weekIndex: 0,
      dayIndex: 0,
      sessionDate: DateTime(2026, 5, 12),
      status: PlanSessionStatus.completed,
      exercises: const [
        ExecutedExercise(exerciseId: 'e1', name: 'Squat'),
      ],
      notes: 'Prior notes',
    );
    List<ExecutedExercise>? receivedInitial;
    var receivedNotes = '';
    final handler = BuilderSessionLogHandler(
      executionService: _FakeExecutionService(existing: existing),
      statusService: status,
      showLogSheet:
          ({
            required BuildContext context,
            required List<Exercise> plannedExercises,
            List<ExecutedExercise>? initialExercises,
            String initialNotes = '',
          }) async {
            receivedInitial = initialExercises;
            receivedNotes = initialNotes;
            return null;
          },
    );

    final ok = await _runLog(tester, handler: handler);
    expect(ok, isFalse);
    expect(status.callCount, 0);
    expect(receivedInitial, existing.exercises);
    expect(receivedNotes, 'Prior notes');
  });

  testWidgets('logSession save failure shows error snackbar', (tester) async {
    final status = _RecordingStatusService()..throwOnCall = true;
    final handler = BuilderSessionLogHandler(
      executionService: _FakeExecutionService(),
      statusService: status,
      showLogSheet:
          ({
            required BuildContext context,
            required List<Exercise> plannedExercises,
            List<ExecutedExercise>? initialExercises,
            String initialNotes = '',
          }) async =>
              const SessionLogResult(exercises: [], notes: ''),
    );

    final ok = await _runLog(tester, handler: handler);
    expect(ok, isFalse);
    expect(find.text('Could not update session status.'), findsOneWidget);
  });
}

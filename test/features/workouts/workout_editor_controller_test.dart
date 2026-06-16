import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_plan_encoder.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_editor_controller.dart';

void main() {
  group('WorkoutEditorController', () {
    late Map<String, WorkoutPlanApiModel> plans;
    late List<Map<String, dynamic>> createCalls;
    late List<Map<String, dynamic>> updateCalls;
    late WorkoutEditorController controller;

    WorkoutPlanApiModel plan({
      required String id,
      String name = 'Plan A',
      String planData = '{}',
      int initialWeekNumber = 1,
      String? phase,
      String? tags,
      String? notes,
    }) {
      final now = DateTime(2026, 1, 1);
      return WorkoutPlanApiModel(
        id: id,
        customerId: 'cust-1',
        userId: 'user-1',
        name: name,
        planData: planData,
        initialWeekNumber: initialWeekNumber,
        phase: phase,
        tags: tags,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
    }

    WorkoutEditorSession session({
      WorkoutRoutine? routine,
      String planName = 'Plan A',
      int initialWeekNumber = 1,
      String? phase,
      String? tags,
      String? notes,
    }) {
      return WorkoutEditorSession(
        routine: routine ?? WorkoutRoutine.empty().copyWith(name: planName),
        planName: planName,
        initialWeekNumber: initialWeekNumber,
        phase: phase,
        tags: tags,
        notes: notes,
      );
    }

    setUp(() {
      plans = {
        'plan-1': plan(
          id: 'plan-1',
          planData: encodeWorkoutRoutinePlanData(
            WorkoutRoutine.empty().copyWith(name: 'Plan A'),
          ),
        ),
      };
      createCalls = [];
      updateCalls = [];
      controller = WorkoutEditorController(
        getPlanById: (planId) async => plans[planId],
        createPlan:
            ({
              required customerId,
              required name,
              required planDataJson,
              pdfHeader,
              useCustomPdfHeader = false,
              initialWeekNumber = 1,
              phase,
              tags,
              notes,
            }) async {
              final created = plan(
                id: 'plan-new',
                name: name,
                planData: planDataJson,
                initialWeekNumber: initialWeekNumber,
                phase: phase,
                tags: tags,
                notes: notes,
              );
              createCalls.add({
                'customerId': customerId,
                'name': name,
                'planDataJson': planDataJson,
                'initialWeekNumber': initialWeekNumber,
                'phase': phase,
                'tags': tags,
                'notes': notes,
              });
              plans[created.id] = created;
              return created;
            },
        updatePlan:
            ({
              required planId,
              name,
              planDataJson,
              initialWeekNumber,
              phase,
              tags,
              notes,
            }) async {
              final existing = plans[planId]!;
              updateCalls.add({
                'planId': planId,
                'name': name,
                'planDataJson': planDataJson,
                'initialWeekNumber': initialWeekNumber,
                'phase': phase,
                'tags': tags,
                'notes': notes,
              });
              final updated = plan(
                id: planId,
                name: name ?? existing.name,
                planData: planDataJson ?? existing.planData,
                initialWeekNumber: initialWeekNumber ?? existing.initialWeekNumber,
                phase: phase ?? existing.phase,
                tags: tags ?? existing.tags,
                notes: notes ?? existing.notes,
              );
              plans[planId] = updated;
              return updated;
            },
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('marks dirty after metadata change', () {
      controller.markLoaded(session: session());
      expect(controller.isDirty, isFalse);

      controller.notifyContentChanged(
        session: session(planName: 'Plan B'),
        editorMode: true,
        loading: false,
      );

      expect(controller.isDirty, isTrue);
      expect(controller.saveState, WorkoutEditorSaveState.unsaved);
    });

    test('save clears dirty state for existing plan', () async {
      controller.markLoaded(
        session: session(),
        planId: 'plan-1',
        loadedInitialWeekNumber: 1,
      );
      controller.notifyContentChanged(
        session: session(
          planName: 'Plan A',
          phase: 'Strength',
        ),
        editorMode: true,
        loading: false,
      );

      final outcome = await controller.save(
        session: session(planName: 'Plan A', phase: 'Strength'),
        customerId: 'cust-1',
      );

      expect(outcome.success, isTrue);
      expect(controller.isDirty, isFalse);
      expect(controller.saveState, WorkoutEditorSaveState.saved);
      expect(updateCalls, hasLength(1));
      expect(updateCalls.single['phase'], 'Strength');
    });

    test('save creates plan when no loaded plan id', () async {
      controller.markLoaded(session: session(planName: 'New plan'));

      final outcome = await controller.save(
        session: session(planName: 'New plan'),
        customerId: 'cust-1',
      );

      expect(outcome.success, isTrue);
      expect(outcome.createdPlanId, 'plan-new');
      expect(controller.loadedPlanId, 'plan-new');
      expect(createCalls, hasLength(1));
      expect(createCalls.single['name'], 'New plan');
    });

    test('save preserves archivedAt and completedAt markers', () async {
      final routine = WorkoutRoutine.empty().copyWith(name: 'Plan A');
      final existingData = jsonEncode({
        ...routine.toJson(),
        'archivedAt': '2026-01-01T00:00:00.000',
        'completedAt': '2026-02-01T00:00:00.000',
      });
      plans['plan-1'] = plan(id: 'plan-1', planData: existingData);
      controller.markLoaded(
        session: session(routine: routine),
        planId: 'plan-1',
      );
      controller.notifyContentChanged(
        session: session(
          routine: routine.copyWith(currentWeek: 2),
        ),
        editorMode: true,
        loading: false,
      );

      await controller.save(
        session: session(
          routine: routine.copyWith(currentWeek: 2),
        ),
        customerId: 'cust-1',
      );

      final savedJson = updateCalls.single['planDataJson'] as String;
      expect(savedJson, contains('"archivedAt"'));
      expect(savedJson, contains('"completedAt"'));
      expect(savedJson, contains('"currentWeek":2'));
    });
  });
}

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
                initialWeekNumber:
                    initialWeekNumber ?? existing.initialWeekNumber,
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

    test('scheduleContentChanged defers dirty state until debounce fires', () {
      controller.markLoaded(session: session());
      controller.scheduleContentChanged(
        session: session(planName: 'Plan B'),
        editorMode: true,
        loading: false,
      );
      expect(controller.isDirty, isFalse);
      expect(controller.saveState, WorkoutEditorSaveState.saved);
    });

    test('marks dirty after debounce elapses', () async {
      final debounced = WorkoutEditorController(
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
              final updated = plan(
                id: planId,
                name: name ?? existing.name,
                planData: planDataJson ?? existing.planData,
                initialWeekNumber:
                    initialWeekNumber ?? existing.initialWeekNumber,
                phase: phase ?? existing.phase,
                tags: tags ?? existing.tags,
                notes: notes ?? existing.notes,
              );
              plans[planId] = updated;
              return updated;
            },
        dirtyDebounceDelay: const Duration(milliseconds: 50),
      );
      addTearDown(debounced.dispose);

      debounced.markLoaded(session: session());
      debounced.scheduleContentChanged(
        session: session(planName: 'Plan B'),
        editorMode: true,
        loading: false,
      );
      expect(debounced.isDirty, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(debounced.isDirty, isTrue);
      expect(debounced.saveState, WorkoutEditorSaveState.unsaved);
    });

    test(
      'coalesces rapid changes into one dirty update after debounce',
      () async {
        final debounced = WorkoutEditorController(
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
                );
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
                return plan(
                  id: planId,
                  name: name ?? existing.name,
                  planData: planDataJson ?? existing.planData,
                );
              },
          dirtyDebounceDelay: const Duration(milliseconds: 80),
        );
        addTearDown(debounced.dispose);

        debounced.markLoaded(session: session());
        debounced.scheduleContentChanged(
          session: session(planName: 'Plan A'),
          editorMode: true,
          loading: false,
        );
        debounced.scheduleContentChanged(
          session: session(planName: 'Plan B'),
          editorMode: true,
          loading: false,
        );
        debounced.scheduleContentChanged(
          session: session(planName: 'Plan C'),
          editorMode: true,
          loading: false,
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(debounced.isDirty, isTrue);
        expect(debounced.saveState, WorkoutEditorSaveState.unsaved);
      },
    );

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
        session: session(planName: 'Plan A', phase: 'Strength'),
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
        session: session(routine: routine.copyWith(currentWeek: 2)),
        editorMode: true,
        loading: false,
      );

      await controller.save(
        session: session(routine: routine.copyWith(currentWeek: 2)),
        customerId: 'cust-1',
      );

      final savedJson = updateCalls.single['planDataJson'] as String;
      expect(savedJson, contains('"archivedAt"'));
      expect(savedJson, contains('"completedAt"'));
      expect(savedJson, contains('"currentWeek":2'));
    });

    test('autosave fires once after dirty existing plan delay', () async {
      var autosaveCalls = 0;
      final autosaving = WorkoutEditorController(
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
            }) async => plan(id: 'created', name: name, planData: planDataJson),
        updatePlan:
            ({
              required planId,
              name,
              planDataJson,
              initialWeekNumber,
              phase,
              tags,
              notes,
            }) async => plans[planId]!,
        autosaveDelay: const Duration(milliseconds: 30),
      );
      addTearDown(autosaving.dispose);
      autosaving.markLoaded(session: session(), planId: 'plan-1');

      autosaving.notifyContentChanged(
        session: session(planName: 'Plan B'),
        editorMode: true,
        loading: false,
        onAutosave: () async {
          autosaveCalls++;
        },
      );
      autosaving.notifyContentChanged(
        session: session(planName: 'Plan C'),
        editorMode: true,
        loading: false,
        onAutosave: () async {
          autosaveCalls++;
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 45));

      expect(autosaveCalls, 1);
    });

    test('autosave is scheduled for new plans without id', () async {
      var autosaveCalls = 0;
      final newPlanController = WorkoutEditorController(
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
              createCalls.add({
                'customerId': customerId,
                'name': name,
                'planDataJson': planDataJson,
              });
              final created = plan(id: 'plan-new', name: name);
              plans[created.id] = created;
              return created;
            },
        autosaveDelay: const Duration(milliseconds: 30),
      );
      addTearDown(newPlanController.dispose);
      newPlanController.markLoaded(session: session());
      newPlanController.notifyContentChanged(
        session: session(planName: 'Draft'),
        editorMode: true,
        loading: false,
        onAutosave: () async {
          autosaveCalls++;
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 45));

      expect(newPlanController.isDirty, isTrue);
      expect(autosaveCalls, 1);
    });

    test('save failure leaves unsaved state', () async {
      final failing = WorkoutEditorController(
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
            }) async => throw StateError('boom'),
        updatePlan:
            ({
              required planId,
              name,
              planDataJson,
              initialWeekNumber,
              phase,
              tags,
              notes,
            }) async => throw StateError('boom'),
      );
      addTearDown(failing.dispose);
      failing.markLoaded(session: session(), planId: 'plan-1');

      final outcome = await failing.save(
        session: session(planName: 'Broken'),
        customerId: 'cust-1',
      );

      expect(outcome.success, isFalse);
      expect(failing.saving, isFalse);
      expect(failing.saveState, WorkoutEditorSaveState.failed);
    });

    test('shouldShowManualSaveButton reflects loading and editor state', () {
      expect(
        controller.shouldShowManualSaveButton(loading: true, editorMode: false),
        isFalse,
      );
      expect(
        controller.shouldShowManualSaveButton(
          loading: false,
          editorMode: false,
        ),
        isTrue,
      );

      controller.markLoaded(session: session(), planId: 'plan-1');
      expect(
        controller.shouldShowManualSaveButton(loading: false, editorMode: true),
        isFalse,
      );

      controller.notifyContentChanged(
        session: session(planName: 'Dirty'),
        editorMode: true,
        loading: false,
      );
      expect(
        controller.shouldShowManualSaveButton(loading: false, editorMode: true),
        isTrue,
      );
    });

    test('suspendTracking blocks dirty updates', () {
      controller.markLoaded(session: session());
      controller.suspendTracking();

      controller.notifyContentChanged(
        session: session(planName: 'Ignored'),
        editorMode: true,
        loading: false,
      );

      expect(controller.isDirty, isFalse);
      expect(controller.saveState, WorkoutEditorSaveState.saved);
    });
  });
}

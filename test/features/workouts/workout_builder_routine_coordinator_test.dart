import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_draft_store.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_routine_coordinator.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_editor_controller.dart';

void main() {
  group('WorkoutBuilderRoutineCoordinator', () {
    test('editorSession resolves initial week from controller text', () {
      final session = WorkoutBuilderSessionController(
        routine: WorkoutRoutine.empty(),
      );
      final nameController = TextEditingController(text: 'Plan A');
      final initialWeekController = TextEditingController(text: '3');
      final coordinator = WorkoutBuilderRoutineCoordinator(
        builderSession: session,
        editorController: WorkoutEditorController(
          planRepo: WorkoutPlanRepository(),
        ),
        planRepo: WorkoutPlanRepository(),
        customerRepo: CustomerRepository(),
        draftStore: const SharedPrefsWorkoutDraftStore(),
        routineNameController: nameController,
        initialWeekController: initialWeekController,
        phaseController: TextEditingController(text: 'Strength'),
        tagsController: TextEditingController(text: 'tag'),
        notesController: TextEditingController(text: 'note'),
      );

      final editorSession = coordinator.editorSession(initialWeekNumber: 1);
      expect(editorSession.planName, 'Plan A');
      expect(editorSession.initialWeekNumber, 3);
      expect(editorSession.phase, 'Strength');

      nameController.dispose();
      initialWeekController.dispose();
    });
  });
}

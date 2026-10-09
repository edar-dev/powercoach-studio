import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_draft_store.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_plan_encoder.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_routine_coordinator.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_editor_controller.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  group('WorkoutBuilderRoutineCoordinator', () {
    test('editorSession resolves initial week from controller text', () {
      final session = WorkoutBuilderSessionController(
        routine: WorkoutRoutine.empty(),
      );
      final nameController = TextEditingController(text: 'Plan A');
      final initialWeekController = TextEditingController(text: '3');
      final notesController = TextEditingController(text: 'note');
      final coordinator = WorkoutBuilderRoutineCoordinator(
        builderSession: session,
        editorController: WorkoutEditorController(
          planRepo: WorkoutPlanRepository(offline: OfflineRepositorySupport()),
        ),
        planRepo: WorkoutPlanRepository(offline: OfflineRepositorySupport()),
        customerRepo: CustomerRepository(offline: OfflineRepositorySupport()),
        draftStore: const SharedPrefsWorkoutDraftStore(),
        routineNameController: nameController,
        initialWeekController: initialWeekController,
        notesController: notesController,
      );

      final editorSession = coordinator.editorSession(initialWeekNumber: 1);
      expect(editorSession.planName, 'Plan A');
      expect(editorSession.initialWeekNumber, 3);
      expect(editorSession.notes, 'note');

      nameController.dispose();
      initialWeekController.dispose();
      notesController.dispose();
    });

    testWidgets(
      'silent create keeps /workouts/new; manual create navigateReplace',
      (tester) async {
        Future<WorkoutPlanApiModel> createPlan({
          required String customerId,
          required String name,
          required WorkoutRoutine routine,
          String? pdfHeader,
          bool useCustomPdfHeader = false,
          int initialWeekNumber = 1,
          String? notes,
        }) async {
          final now = DateTime(2026, 1, 1);
          return WorkoutPlanApiModel(
            id: 'plan-coord-1',
            customerId: customerId,
            userId: 'user-1',
            name: name,
            planData: encodeWorkoutRoutinePlanData(routine),
            initialWeekNumber: initialWeekNumber,
            createdAt: now,
            updatedAt: now,
          );
        }

        final session = WorkoutBuilderSessionController(
          routine: WorkoutRoutine.empty().copyWith(name: 'Plan'),
        );
        final nameController = TextEditingController(text: 'Plan');
        final initialWeekController = TextEditingController(text: '1');
        final notesController = TextEditingController();
        final editorController = WorkoutEditorController(createPlan: createPlan);
        editorController.markLoaded(
          session: WorkoutEditorSession(
            routine: session.routine,
            planName: 'Plan',
            initialWeekNumber: 1,
          ),
          planId: null,
        );
        final coordinator = WorkoutBuilderRoutineCoordinator(
          builderSession: session,
          editorController: editorController,
          planRepo: WorkoutPlanRepository(offline: OfflineRepositorySupport()),
          customerRepo: CustomerRepository(offline: OfflineRepositorySupport()),
          draftStore: const SharedPrefsWorkoutDraftStore(),
          routineNameController: nameController,
          initialWeekController: initialWeekController,
          notesController: notesController,
        );

        addTearDown(() {
          nameController.dispose();
          initialWeekController.dispose();
          notesController.dispose();
          session.dispose();
          editorController.dispose();
        });

        late WorkoutBuilderSaveOutcome silentOutcome;
        final router = GoRouter(
          initialLocation: customerWorkoutEditorPath('c1'),
          routes: [
            GoRoute(
              path: '/customers/:customerId/workouts/new',
              builder: (context, _) => Scaffold(
                body: Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        silentOutcome = await coordinator.saveRoutine(
                          context: context,
                          editorMode: true,
                          customerId: 'c1',
                          initialWeekNumber: 1,
                          editorCustomer: null,
                          selectedWeekIndex: 0,
                          selectedDayIndex: 0,
                          silent: true,
                        );
                      },
                      child: const Text('silent'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        await coordinator.saveRoutine(
                          context: context,
                          editorMode: true,
                          customerId: 'c1',
                          initialWeekNumber: 1,
                          editorCustomer: null,
                          selectedWeekIndex: 0,
                          selectedDayIndex: 0,
                        );
                      },
                      child: const Text('manual'),
                    ),
                  ],
                ),
              ),
            ),
            GoRoute(
              path: '/customers/:customerId/workouts/:planId',
              builder: (_, state) =>
                  Text('Plan ${state.pathParameters['planId']}'),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            theme: StitchM3Theme.light,
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('silent'));
        await tester.pumpAndSettle();

        expect(silentOutcome.success, isTrue);
        expect(silentOutcome.createdPlanId, 'plan-coord-1');
        expect(editorController.loadedPlanId, 'plan-coord-1');
        expect(find.text('silent'), findsOneWidget);
        expect(find.text('Plan plan-coord-1'), findsNothing);

        // Second create would update; reset to exercise manual create path.
        editorController.markLoaded(
          session: WorkoutEditorSession(
            routine: session.routine,
            planName: 'Plan',
            initialWeekNumber: 1,
          ),
          planId: null,
        );

        await tester.tap(find.text('manual'));
        await tester.pumpAndSettle();

        expect(find.text('Plan plan-coord-1'), findsOneWidget);
      },
    );
  });
}

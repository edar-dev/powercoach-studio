import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_workout_follow_up.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class _FakePlanRepo extends WorkoutPlanRepository {
  _FakePlanRepo({
    this.created,
    this.throwOnCreate = false,
  }) : super(offline: OfflineRepositorySupport());

  final WorkoutPlanApiModel? created;
  final bool throwOnCreate;
  int createFollowUpCalls = 0;
  String? lastSourcePlanId;
  String? lastName;

  @override
  Future<WorkoutPlanApiModel> createFollowUpFromPlan({
    required String sourcePlanId,
    String? name,
    DateTime? newStartDate,
    bool applyExecutedLoads = false,
  }) async {
    createFollowUpCalls++;
    lastSourcePlanId = sourcePlanId;
    lastName = name;
    if (throwOnCreate) {
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }
    return created!;
  }
}

class _FakeExecutionService extends SessionExecutionService {
  _FakeExecutionService()
    : super(repository: WorkoutPlanRepository(offline: OfflineRepositorySupport()));

  @override
  Future<List<SessionExecution>> listForPlan(String planId) async => const [];
}

WorkoutPlanApiModel _plan({
  required String id,
  required String name,
  String customerId = 'cust-1',
}) {
  final now = DateTime(2026, 5, 1);
  return WorkoutPlanApiModel(
    id: id,
    customerId: customerId,
    userId: 'coach-1',
    name: name,
    planData: jsonEncode(WorkoutRoutine.empty().toJson()),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  testWidgets(
    'createCustomerWorkoutFollowUp returns plan, shows success, opens editor',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final source = _plan(id: 'src-1', name: 'Block 1');
      final created = _plan(id: 'fu-1', name: 'Block 1 - Follow-up');
      final repo = _FakePlanRepo(created: created);
      var successCalls = 0;
      WorkoutPlanApiModel? result;
      String? navigatedTo;

      final router = GoRouter(
        initialLocation: '/customers/cust-1/workouts',
        routes: [
          GoRoute(
            path: '/customers/:customerId/workouts',
            builder: (context, _) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await createCustomerWorkoutFollowUp(
                      context,
                      customerId: 'cust-1',
                      plan: source,
                      planRepo: repo,
                      executionService: _FakeExecutionService(),
                      onSuccess: () => successCalls++,
                    );
                  },
                  child: const Text('follow-up'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/customers/:customerId/workouts/:planId',
            builder: (context, state) {
              navigatedTo = state.uri.toString();
              return Scaffold(
                body: Text('Editor ${state.pathParameters['planId']}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('follow-up'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.workoutFollowUpTitle), findsOneWidget);
      await tester.tap(find.text(l10n.workoutFollowUpCreateAction));
      await tester.pumpAndSettle();

      expect(result?.id, 'fu-1');
      expect(repo.createFollowUpCalls, 1);
      expect(repo.lastSourcePlanId, 'src-1');
      expect(successCalls, 1);
      expect(find.text(l10n.workoutFollowUpCreatedMessage), findsOneWidget);
      expect(
        navigatedTo,
        customerWorkoutEditorPath('cust-1', planId: 'fu-1'),
      );
      expect(find.text('Editor fu-1'), findsOneWidget);
    },
  );

  testWidgets(
    'createCustomerWorkoutFollowUp shows cloud error snackbar and returns null',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final source = _plan(id: 'src-1', name: 'Block 1');
      final repo = _FakePlanRepo(throwOnCreate: true);
      WorkoutPlanApiModel? result = _plan(id: 'sentinel', name: 'sentinel');

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    result = await createCustomerWorkoutFollowUp(
                      context,
                      customerId: 'cust-1',
                      plan: source,
                      planRepo: repo,
                      executionService: _FakeExecutionService(),
                      openEditor: false,
                      onSuccess: () {},
                    );
                  },
                  child: const Text('follow-up'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('follow-up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.workoutFollowUpCreateAction));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text(l10n.cloudSaveRequiresNetwork), findsOneWidget);
    },
  );

  testWidgets(
    'openEditor false skips navigation after successful create',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final source = _plan(id: 'src-1', name: 'Block 1');
      final created = _plan(id: 'fu-1', name: 'Block 1 - Follow-up');
      final repo = _FakePlanRepo(created: created);
      String? navigatedTo;

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, _) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    await createCustomerWorkoutFollowUp(
                      context,
                      customerId: 'cust-1',
                      plan: source,
                      planRepo: repo,
                      executionService: _FakeExecutionService(),
                      openEditor: false,
                      onSuccess: () {},
                    );
                  },
                  child: const Text('follow-up'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/customers/:customerId/workouts/:planId',
            builder: (context, state) {
              navigatedTo = state.uri.toString();
              return const Scaffold(body: Text('Editor'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('follow-up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.workoutFollowUpCreateAction));
      await tester.pumpAndSettle();

      expect(repo.createFollowUpCalls, 1);
      expect(navigatedTo, isNull);
      expect(find.text(l10n.workoutFollowUpCreatedMessage), findsOneWidget);
    },
  );
}

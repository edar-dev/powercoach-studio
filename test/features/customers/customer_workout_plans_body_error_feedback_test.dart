import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_workout_plans_body.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePlanRepo extends WorkoutPlanRepository {
  _FakePlanRepo({
    this.plans = const [],
    this.throwOnLoad = false,
    this.throwOnArchive = false,
    this.throwOnComplete = false,
    this.genericLoadError = false,
  }) : super(offline: OfflineRepositorySupport());

  final List<WorkoutPlanApiModel> plans;
  final bool throwOnLoad;
  final bool throwOnArchive;
  final bool throwOnComplete;
  final bool genericLoadError;

  int archiveCalls = 0;
  int completeCalls = 0;

  @override
  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    if (throwOnLoad) {
      if (genericLoadError) {
        throw Exception('raw-load-failure-xyz');
      }
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }
    return plans;
  }

  @override
  Future<WorkoutPlanApiModel> archivePlan(String planId) async {
    archiveCalls++;
    if (throwOnArchive) {
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }
    return plans.firstWhere((p) => p.id == planId);
  }

  @override
  Future<WorkoutPlanApiModel> markPlanCompleted(
    String planId, {
    DateTime? completedAt,
  }) async {
    completeCalls++;
    if (throwOnComplete) {
      throw CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      );
    }
    return plans.firstWhere((p) => p.id == planId);
  }
}

WorkoutPlanApiModel _plan({
  required String id,
  required String name,
}) {
  final now = DateTime(2026, 5, 1);
  return WorkoutPlanApiModel(
    id: id,
    customerId: 'cust-1',
    userId: 'coach-1',
    name: name,
    planData: jsonEncode(WorkoutRoutine.empty().toJson()),
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'load offline failure shows cloudSaveRequiresNetwork, not raw exception',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final repo = _FakePlanRepo(throwOnLoad: true);

      await tester.pumpWidget(
        _wrap(
          CustomerWorkoutPlansBody(
            customerId: 'cust-1',
            planRepo: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.cloudSaveRequiresNetwork), findsOneWidget);
      expect(find.textContaining('CoachEntitiesOnlineRequired'), findsNothing);
      expect(find.textContaining('Exception:'), findsNothing);
    },
  );

  testWidgets(
    'load generic failure shows workoutPlansLoadError, not raw exception',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final repo = _FakePlanRepo(throwOnLoad: true, genericLoadError: true);

      await tester.pumpWidget(
        _wrap(
          CustomerWorkoutPlansBody(
            customerId: 'cust-1',
            planRepo: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.workoutPlansLoadError), findsOneWidget);
      expect(find.textContaining('raw-load-failure-xyz'), findsNothing);
    },
  );

  testWidgets(
    'archive offline failure shows cloud save snackbar',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final plan = _plan(id: 'p1', name: 'Block A');
      final repo = _FakePlanRepo(plans: [plan], throwOnArchive: true);

      await tester.pumpWidget(
        _wrap(
          CustomerWorkoutPlansBody(
            customerId: 'cust-1',
            planRepo: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.workoutPlanArchiveAction));
      await tester.pumpAndSettle();

      expect(repo.archiveCalls, 1);
      expect(find.text(l10n.cloudSaveRequiresNetwork), findsOneWidget);
    },
  );

  testWidgets(
    'complete menu is present and offline failure shows cloud save snackbar',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final plan = _plan(id: 'p1', name: 'Block A');
      final repo = _FakePlanRepo(plans: [plan], throwOnComplete: true);

      await tester.pumpWidget(
        _wrap(
          CustomerWorkoutPlansBody(
            customerId: 'cust-1',
            planRepo: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text(l10n.workoutPlanCompleteAction), findsOneWidget);

      await tester.tap(find.text(l10n.workoutPlanCompleteAction));
      await tester.pumpAndSettle();

      expect(repo.completeCalls, 1);
      expect(find.text(l10n.cloudSaveRequiresNetwork), findsOneWidget);
    },
  );
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/list_skeleton.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_workout_plans_body.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedPlanRepo extends WorkoutPlanRepository {
  _DelayedPlanRepo(this.plans) : super(offline: OfflineRepositorySupport());

  final List<WorkoutPlanApiModel> plans;
  Completer<void>? gate;

  @override
  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    final g = gate;
    if (g != null) await g.future;
    return plans;
  }
}

WorkoutPlanApiModel _plan() {
  final now = DateTime(2026, 5, 1);
  return WorkoutPlanApiModel(
    id: 'p1',
    customerId: 'cust-1',
    userId: 'coach-1',
    name: 'Mesociclo A',
    planData: jsonEncode(WorkoutRoutine.empty().toJson()),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'refresh with existing plans keeps list (no skeleton-only flash)',
    (tester) async {
      final repo = _DelayedPlanRepo([_plan()]);

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.dark,
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CustomerWorkoutPlansBody(
              customerId: 'cust-1',
              planRepo: repo,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mesociclo A'), findsOneWidget);
      expect(find.byType(ListSkeleton), findsNothing);

      // Gate the next fetch so we can assert mid-refresh UI.
      repo.gate = Completer<void>();
      final indicator =
          tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
      final refreshFuture = indicator.onRefresh();
      await tester.pump();

      expect(find.byType(ListSkeleton), findsNothing);
      expect(find.text('Mesociclo A'), findsOneWidget);

      repo.gate!.complete();
      await refreshFuture;
      await tester.pumpAndSettle();
      expect(find.text('Mesociclo A'), findsOneWidget);
    },
  );
}

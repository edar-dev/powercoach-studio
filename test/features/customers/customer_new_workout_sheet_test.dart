import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_new_workout_sheet.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class _FakePlanRepo extends WorkoutPlanRepository {
  _FakePlanRepo({this.plans = const []})
    : super(offline: OfflineRepositorySupport());

  final List<WorkoutPlanApiModel> plans;
  int getByCustomerIdCalls = 0;

  @override
  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    getByCustomerIdCalls++;
    return plans;
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
  testWidgets('new workout sheet shows blank, follow-up, and duplicate choices', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => showCustomerNewWorkoutSheet(
                context,
                customerId: 'cust-1',
                planRepo: _FakePlanRepo(),
              ),
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.customerNewWorkoutBlank), findsOneWidget);
    expect(find.text(l10n.customerNewWorkoutFollowUp), findsOneWidget);
    expect(find.text(l10n.customerNewWorkoutDuplicateExisting), findsOneWidget);
  });

  testWidgets(
    'follow-up choice with empty plans shows no-plans snackbar',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final repo = _FakePlanRepo(plans: const []);

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => showCustomerNewWorkoutSheet(
                  context,
                  customerId: 'cust-1',
                  planRepo: repo,
                ),
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.customerNewWorkoutFollowUp));
      await tester.pumpAndSettle();

      expect(repo.getByCustomerIdCalls, 1);
      expect(find.text(l10n.customerNewWorkoutNoPlansForFollowUp), findsOneWidget);
      // Did not open the follow-up dialog.
      expect(find.text(l10n.workoutFollowUpTitle), findsNothing);
    },
  );

  testWidgets(
    'follow-up choice with plans opens plan picker titled for continue',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final repo = _FakePlanRepo(plans: [_plan(id: 'p1', name: 'Block A')]);

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => showCustomerNewWorkoutSheet(
                  context,
                  customerId: 'cust-1',
                  planRepo: repo,
                ),
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.customerNewWorkoutFollowUp));
      await tester.pumpAndSettle();

      expect(find.text(l10n.customerNewWorkoutFollowUpPickTitle), findsOneWidget);
      expect(find.text('Block A'), findsOneWidget);
    },
  );
}

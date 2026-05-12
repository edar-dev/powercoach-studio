import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Customer _customer({
  required String id,
  required String name,
  bool archived = false,
}) {
  final t = DateTime(2020, 1, 1);
  return Customer(
    id: id,
    userId: 'coach-1',
    name: name,
    createdAt: t,
    updatedAt: t,
    isArchived: archived,
  );
}

WorkoutPlanApiModel _plan({
  required String id,
  required String customerId,
  required String name,
  required DateTime updatedAt,
  required String planDataJson,
}) {
  final t = DateTime(2020, 1, 1);
  return WorkoutPlanApiModel(
    id: id,
    customerId: customerId,
    userId: 'coach-1',
    name: name,
    planData: planDataJson,
    createdAt: t,
    updatedAt: updatedAt,
  );
}

String _routineJsonWithStart(DateTime startDate) {
  final r = WorkoutRoutine.empty().copyWith(startDate: startDate);
  return jsonEncode(r.toJson());
}

PendingOperation _pending({
  required String id,
  required PendingOperationStatus status,
}) {
  final t = DateTime(2020, 1, 1);
  return PendingOperation(
    id: id,
    userId: 'coach-1',
    entityType: OfflineEntityType.workoutPlan,
    entityId: 'e1',
    scopeId: 'c1',
    operationType: OfflineOperationType.update,
    path: '/api/workouts/1',
    payload: const <String, dynamic>{},
    createdAt: t,
    updatedAt: t,
    status: status,
  );
}

void main() {
  group('buildDashboardSnapshot', () {
    final now = DateTime(2025, 6, 15, 12);

    test('empty inputs yield empty sections and zero counts', () {
      final s = buildDashboardSnapshot(
        customers: const [],
        plans: const [],
        pendingOperations: const [],
        now: now,
        unknownClientLabel: '?',
      );
      expect(s.hasError, isFalse);
      expect(s.clientCount, 0);
      expect(s.activePrograms, 0);
      expect(s.todayItems, isEmpty);
      expect(s.stalePlans, isEmpty);
      expect(s.customersWithoutPlan, isEmpty);
      expect(s.attentionPending, isEmpty);
      expect(s.queuedSyncCount, 0);
    });

    test('lists today plans matching calendar day', () {
      final start = DateTime(2025, 6, 15);
      final plan = _plan(
        id: 'p1',
        customerId: 'c1',
        name: 'Summer',
        updatedAt: now,
        planDataJson: _routineJsonWithStart(start),
      );
      final s = buildDashboardSnapshot(
        customers: [_customer(id: 'c1', name: 'Anna')],
        plans: [plan],
        pendingOperations: const [],
        now: now,
        unknownClientLabel: '?',
      );
      expect(s.todayItems, hasLength(1));
      expect(s.todayItems.single.planId, 'p1');
      expect(s.todayItems.single.clientName, 'Anna');
    });

    test('flags stale plans by updatedAt day threshold', () {
      final oldUpdate = now.subtract(const Duration(days: 20));
      final plan = _plan(
        id: 'p1',
        customerId: 'c1',
        name: 'Old',
        updatedAt: oldUpdate,
        planDataJson: _routineJsonWithStart(DateTime(2025, 1, 1)),
      );
      final s = buildDashboardSnapshot(
        customers: [_customer(id: 'c1', name: 'Bob')],
        plans: [plan],
        pendingOperations: const [],
        now: now,
        unknownClientLabel: '?',
        stalePlanDays: 14,
      );
      expect(s.stalePlans, hasLength(1));
      expect(s.stalePlans.single.planId, 'p1');
    });

    test('customers without active plan (non-archived)', () {
      final s = buildDashboardSnapshot(
        customers: [
          _customer(id: 'c1', name: 'NoPlan'),
          _customer(id: 'c2', name: 'HasPlan'),
        ],
        plans: [
          _plan(
            id: 'p1',
            customerId: 'c2',
            name: 'X',
            updatedAt: now,
            planDataJson: _routineJsonWithStart(DateTime(2025, 6, 1)),
          ),
        ],
        pendingOperations: const [],
        now: now,
        unknownClientLabel: '?',
      );
      expect(s.customersWithoutPlan, hasLength(1));
      expect(s.customersWithoutPlan.single.customerId, 'c1');
    });

    test('attention pending lists failed and counts queued', () {
      final s = buildDashboardSnapshot(
        customers: const [],
        plans: const [],
        pendingOperations: [
          _pending(id: 'a', status: PendingOperationStatus.failed),
          _pending(id: 'b', status: PendingOperationStatus.pending),
          _pending(id: 'c', status: PendingOperationStatus.syncing),
        ],
        now: now,
        unknownClientLabel: '?',
      );
      expect(s.attentionPending, hasLength(1));
      expect(s.attentionPending.single.operationId, 'a');
      expect(s.queuedSyncCount, 2);
    });
  });

  group('CoachDashboardScreen', () {
    testWidgets('shows section titles when snapshot has content', (tester) async {
      final now = DateTime(2025, 6, 15, 12);
      final snap = buildDashboardSnapshot(
        customers: [_customer(id: 'c1', name: 'Anna')],
        plans: [
          _plan(
            id: 'p1',
            customerId: 'c1',
            name: 'Today plan',
            updatedAt: now,
            planDataJson: _routineJsonWithStart(DateTime(2025, 6, 15)),
          ),
        ],
        pendingOperations: const [],
        now: now,
        unknownClientLabel: '?',
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: CoachDashboardScreen(
            loadSnapshot: (_) async => snap,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('Clients without a program'), findsOneWidget);
      expect(find.text('Plans to refresh'), findsOneWidget);
    });

    testWidgets('shows load error banner when snapshot reports error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: CoachDashboardScreen(
            loadSnapshot: (_) async => DashboardSnapshot.error('boom'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not load'), findsOneWidget);
    });
  });
}

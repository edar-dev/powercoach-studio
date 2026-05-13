import 'package:flutter/foundation.dart';

import '../../../core/sync/offline_models.dart';
import '../../customers/data/models/customer.dart';
import '../../workouts/data/workout_plan_api_model.dart';
import 'calendar_event_loader.dart';

/// Max rows shown per dashboard section before "See all".
const int kDashboardSectionRowLimit = 5;

/// Plans with [WorkoutPlanApiModel.updatedAt] older than this (by local calendar day) are "stale".
const int kStalePlanDays = 14;

/// Single row in "Today" — plan starting today.
@immutable
class DashboardTodayItem {
  const DashboardTodayItem({
    required this.customerId,
    required this.planId,
    required this.clientName,
    required this.programName,
    required this.date,
  });

  final String customerId;
  final String planId;
  final String clientName;
  final String programName;
  final DateTime date;
}

/// Stale plan row (needs refresh).
@immutable
class DashboardStalePlanItem {
  const DashboardStalePlanItem({
    required this.customerId,
    required this.planId,
    required this.clientName,
    required this.programName,
    required this.updatedAt,
  });

  final String customerId;
  final String planId;
  final String clientName;
  final String programName;
  final DateTime updatedAt;
}

/// Customer with no active workout plan in cache.
@immutable
class DashboardCustomerNoPlanItem {
  const DashboardCustomerNoPlanItem({
    required this.customerId,
    required this.name,
  });

  final String customerId;
  final String name;
}

/// Outbox row worth showing under "Attention".
@immutable
class DashboardPendingAttentionItem {
  const DashboardPendingAttentionItem({
    required this.operationId,
    required this.status,
    required this.entityType,
    required this.path,
    this.errorMessage,
  });

  final String operationId;
  final PendingOperationStatus status;
  final OfflineEntityType entityType;
  final String path;
  final String? errorMessage;
}

/// Immutable dashboard payload for the command center UI.
@immutable
class DashboardSnapshot {
  const DashboardSnapshot({
    this.errorMessage,
    required this.clientCount,
    required this.activePrograms,
    required this.weeklyUpdates,
    required this.todayItems,
    required this.stalePlans,
    required this.customersWithoutPlan,
    required this.attentionPending,
    required this.queuedSyncCount,
  });

  factory DashboardSnapshot.error(String message) => DashboardSnapshot(
        errorMessage: message,
        clientCount: 0,
        activePrograms: 0,
        weeklyUpdates: 0,
        todayItems: const [],
        stalePlans: const [],
        customersWithoutPlan: const [],
        attentionPending: const [],
        queuedSyncCount: 0,
      );

  final String? errorMessage;
  final int clientCount;
  final int activePrograms;
  final int weeklyUpdates;
  final List<DashboardTodayItem> todayItems;
  final List<DashboardStalePlanItem> stalePlans;
  final List<DashboardCustomerNoPlanItem> customersWithoutPlan;
  final List<DashboardPendingAttentionItem> attentionPending;
  final int queuedSyncCount;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}

({DateTime start, DateTime endExclusive}) dashboardWeekRangeContaining(DateTime now) {
  final dayStart = DateTime(now.year, now.month, now.day);
  final weekStart = dayStart.subtract(Duration(days: now.weekday - DateTime.monday));
  return (start: weekStart, endExclusive: weekStart.add(const Duration(days: 7)));
}

/// Pure aggregation for tests and [DashboardSnapshotLoader].
DashboardSnapshot buildDashboardSnapshot({
  required List<Customer> customers,
  required List<WorkoutPlanApiModel> plans,
  required List<PendingOperation> pendingOperations,
  required DateTime now,
  required String unknownClientLabel,
  required String untitledWorkoutLabel,
  int stalePlanDays = kStalePlanDays,
  int maxSectionRows = kDashboardSectionRowLimit,
}) {
  final customerById = <String, String>{
    for (final c in customers) c.id: c.name,
  };

  final planCountByCustomerId = <String, int>{};
  for (final p in plans) {
    planCountByCustomerId.update(p.customerId, (n) => n + 1, ifAbsent: () => 1);
  }

  final weekRange = dashboardWeekRangeContaining(now);
  final weeklyUpdates = plans.where((plan) {
    final updatedDay = DateTime(
      plan.updatedAt.year,
      plan.updatedAt.month,
      plan.updatedAt.day,
    );
    return !updatedDay.isBefore(weekRange.start) &&
        updatedDay.isBefore(weekRange.endExclusive);
  }).length;

  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final todayEvents = CalendarEventLoader.eventsForPlans(
    plans: plans,
    customerNamesById: customerById,
    rangeStart: todayStart,
    rangeEndExclusive: todayEnd,
    unknownClientLabel: unknownClientLabel,
    untitledProgramLabel: untitledWorkoutLabel,
  );
  final todayItems = todayEvents
      .map(
        (event) => DashboardTodayItem(
          customerId: event.customerId,
          planId: event.planId,
          clientName: event.customerName,
          programName: event.programName,
          date: event.day,
        ),
      )
      .toList();

  final thresholdDay =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: stalePlanDays));
  final staleCandidates = <DashboardStalePlanItem>[];
  for (final plan in plans) {
    final updatedDay = DateTime(
      plan.updatedAt.year,
      plan.updatedAt.month,
      plan.updatedAt.day,
    );
    if (!updatedDay.isBefore(thresholdDay)) continue;
    final name = customerById[plan.customerId] ?? unknownClientLabel;
    staleCandidates.add(
      DashboardStalePlanItem(
        customerId: plan.customerId,
        planId: plan.id,
        clientName: name,
        programName: plan.name.trim().isEmpty ? '' : plan.name,
        updatedAt: plan.updatedAt,
      ),
    );
  }
  staleCandidates.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  final stalePlans = staleCandidates.take(maxSectionRows).toList();

  final noPlan = <DashboardCustomerNoPlanItem>[];
  for (final c in customers) {
    if (c.isArchived) continue;
    if ((planCountByCustomerId[c.id] ?? 0) == 0) {
      noPlan.add(DashboardCustomerNoPlanItem(customerId: c.id, name: c.name));
    }
  }
  noPlan.sort((a, b) => a.name.compareTo(b.name));
  final customersWithoutPlan = noPlan.take(maxSectionRows).toList();

  final attention = <DashboardPendingAttentionItem>[];
  var queued = 0;
  for (final op in pendingOperations) {
    switch (op.status) {
      case PendingOperationStatus.pending:
      case PendingOperationStatus.syncing:
        queued++;
        break;
      case PendingOperationStatus.failed:
      case PendingOperationStatus.conflict:
      case PendingOperationStatus.deadLetter:
      case PendingOperationStatus.blockedAuth:
        attention.add(
          DashboardPendingAttentionItem(
            operationId: op.id,
            status: op.status,
            entityType: op.entityType,
            path: op.path,
            errorMessage: op.errorMessage,
          ),
        );
        break;
      case PendingOperationStatus.completed:
        break;
    }
  }
  attention.sort((a, b) => a.path.compareTo(b.path));
  final attentionPending = attention.take(maxSectionRows).toList();

  return DashboardSnapshot(
    clientCount: customers.length,
    activePrograms: plans.length,
    weeklyUpdates: weeklyUpdates,
    todayItems: todayItems,
    stalePlans: stalePlans,
    customersWithoutPlan: customersWithoutPlan,
    attentionPending: attentionPending,
    queuedSyncCount: queued,
  );
}

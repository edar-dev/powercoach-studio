import '../../dashboard/domain/plan_calendar_event.dart';
import 'session_execution_service.dart';

enum DiaryDateRange {
  last7,
  last30,
  all,
}

enum DiaryStatusFilter {
  all,
  completed,
  skipped,
}

List<SessionExecutionEntry> filterDiaryEntries(
  List<SessionExecutionEntry> entries, {
  String? customerId,
  DiaryDateRange dateRange = DiaryDateRange.all,
  DiaryStatusFilter statusFilter = DiaryStatusFilter.all,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  DateTime? from;
  switch (dateRange) {
    case DiaryDateRange.last7:
      from = today.subtract(const Duration(days: 6));
    case DiaryDateRange.last30:
      from = today.subtract(const Duration(days: 29));
    case DiaryDateRange.all:
      from = null;
  }

  return [
    for (final entry in entries)
      if (_matchesCustomer(entry, customerId) &&
          _matchesDate(entry, from, today) &&
          _matchesStatus(entry, statusFilter))
        entry,
  ];
}

bool _matchesCustomer(SessionExecutionEntry entry, String? customerId) {
  if (customerId == null || customerId.isEmpty) return true;
  return entry.customerId == customerId;
}

bool _matchesDate(
  SessionExecutionEntry entry,
  DateTime? from,
  DateTime to,
) {
  if (from == null) return true;
  final date = entry.execution.sessionDate;
  final day = DateTime(date.year, date.month, date.day);
  return !day.isBefore(from) && !day.isAfter(to);
}

bool _matchesStatus(
  SessionExecutionEntry entry,
  DiaryStatusFilter statusFilter,
) {
  return switch (statusFilter) {
    DiaryStatusFilter.all => true,
    DiaryStatusFilter.completed =>
      entry.execution.status == PlanSessionStatus.completed,
    DiaryStatusFilter.skipped =>
      entry.execution.status == PlanSessionStatus.skipped,
  };
}

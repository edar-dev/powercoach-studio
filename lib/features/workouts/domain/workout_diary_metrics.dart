import '../../dashboard/domain/plan_calendar_event.dart';
import 'session_execution.dart';
import 'session_execution_service.dart';

/// Aggregates and per-session metrics for the workout diary redesign.
class WorkoutDiaryKpis {
  const WorkoutDiaryKpis({
    required this.completedCount,
    required this.skippedCount,
    required this.compliancePercent,
    required this.volumeKg,
    required this.exerciseCount,
    required this.setCount,
    required this.hasParsableVolume,
  });

  final int completedCount;
  final int skippedCount;

  /// Completed / (completed + skipped), rounded 0–100. Null when no samples.
  final int? compliancePercent;

  /// Sum of load×reps across completed sets where both parse.
  final double volumeKg;
  final int exerciseCount;
  final int setCount;
  final bool hasParsableVolume;
}

WorkoutDiaryKpis computeDiaryKpis(List<SessionExecutionEntry> entries) {
  var completed = 0;
  var skipped = 0;
  var volume = 0.0;
  var hasVolume = false;
  var exercises = 0;
  var sets = 0;

  for (final entry in entries) {
    final execution = entry.execution;
    if (execution.status == PlanSessionStatus.completed) {
      completed++;
    } else if (execution.status == PlanSessionStatus.skipped) {
      skipped++;
    }
    final metrics = computeSessionMetrics(execution);
    volume += metrics.volumeKg;
    if (metrics.hasParsableVolume) hasVolume = true;
    exercises += metrics.exerciseCount;
    sets += metrics.setCount;
  }

  final denominator = completed + skipped;
  return WorkoutDiaryKpis(
    completedCount: completed,
    skippedCount: skipped,
    compliancePercent: denominator == 0
        ? null
        : ((completed / denominator) * 100).round(),
    volumeKg: volume,
    exerciseCount: exercises,
    setCount: sets,
    hasParsableVolume: hasVolume,
  );
}

class SessionDiaryMetrics {
  const SessionDiaryMetrics({
    required this.exerciseCount,
    required this.setCount,
    required this.volumeKg,
    required this.hasParsableVolume,
  });

  final int exerciseCount;
  final int setCount;
  final double volumeKg;
  final bool hasParsableVolume;
}

SessionDiaryMetrics computeSessionMetrics(SessionExecution execution) {
  var exerciseCount = execution.exercises.length;
  var setCount = 0;
  var volume = 0.0;
  var hasVolume = false;

  for (final exercise in execution.exercises) {
    setCount += exercise.sets.length;
    for (final set in exercise.sets) {
      final load = parseLoadKg(set.load);
      final reps = parseRepsCount(set.reps);
      if (load != null && reps != null) {
        volume += load * reps;
        hasVolume = true;
      }
    }
  }

  return SessionDiaryMetrics(
    exerciseCount: exerciseCount,
    setCount: setCount,
    volumeKg: volume,
    hasParsableVolume: hasVolume,
  );
}

/// Extracts a positive kg value from strings like "60", "75kg", "1.800 kg".
double? parseLoadKg(String raw) {
  final t = raw.trim().toLowerCase();
  if (t.isEmpty || t.contains('@')) return null;
  final match = RegExp(
    r'(\d+(?:[.,]\d+)?)',
  ).firstMatch(t);
  if (match == null) return null;
  final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (n == null || n <= 0) return null;
  return n;
}

/// Extracts a positive rep count from strings like "8", "8-10", "3x5".
double? parseRepsCount(String raw) {
  final t = raw.trim().toLowerCase();
  if (t.isEmpty) return null;
  final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(t);
  if (match == null) return null;
  final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (n == null || n <= 0) return null;
  return n;
}

String formatVolumeKg(double kg) {
  final rounded = kg.round();
  final s = rounded.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    if (i > 0 && fromEnd % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String customerInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final p = parts.first;
    return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
  }
  return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
}

/// Groups diary entries by calendar day (newest groups first).
List<MapEntry<DateTime, List<SessionExecutionEntry>>> groupDiaryEntriesByDay(
  List<SessionExecutionEntry> entries,
) {
  final groups = <DateTime, List<SessionExecutionEntry>>{};
  final order = <DateTime>[];
  for (final entry in entries) {
    final raw = entry.execution.completedAt ?? entry.execution.sessionDate;
    final day = DateTime(raw.year, raw.month, raw.day);
    final list = groups.putIfAbsent(day, () {
      order.add(day);
      return <SessionExecutionEntry>[];
    });
    list.add(entry);
  }
  return [for (final day in order) MapEntry(day, groups[day]!)];
}

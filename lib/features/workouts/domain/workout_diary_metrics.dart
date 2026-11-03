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
    this.avgRpe,
    this.hasRpeSamples = false,
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

  /// Mean RPE parsed from set loads that contain `@` (e.g. `60@8`).
  final double? avgRpe;
  final bool hasRpeSamples;
}

WorkoutDiaryKpis computeDiaryKpis(List<SessionExecutionEntry> entries) {
  var completed = 0;
  var skipped = 0;
  var volume = 0.0;
  var hasVolume = false;
  var exercises = 0;
  var sets = 0;
  var rpeSum = 0.0;
  var rpeCount = 0;

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
    if (metrics.hasRpeSamples && metrics.avgRpe != null) {
      rpeSum += metrics.avgRpe! * metrics.rpeSampleCount;
      rpeCount += metrics.rpeSampleCount;
    }
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
    avgRpe: rpeCount == 0 ? null : rpeSum / rpeCount,
    hasRpeSamples: rpeCount > 0,
  );
}

class SessionDiaryMetrics {
  const SessionDiaryMetrics({
    required this.exerciseCount,
    required this.setCount,
    required this.volumeKg,
    required this.hasParsableVolume,
    this.avgRpe,
    this.rpeSampleCount = 0,
    this.hasRpeSamples = false,
  });

  final int exerciseCount;
  final int setCount;
  final double volumeKg;
  final bool hasParsableVolume;
  final double? avgRpe;
  final int rpeSampleCount;
  final bool hasRpeSamples;
}

SessionDiaryMetrics computeSessionMetrics(SessionExecution execution) {
  var exerciseCount = execution.exercises.length;
  var setCount = 0;
  var volume = 0.0;
  var hasVolume = false;
  var rpeSum = 0.0;
  var rpeCount = 0;

  for (final exercise in execution.exercises) {
    setCount += exercise.sets.length;
    for (final set in exercise.sets) {
      final load = parseLoadKg(set.load);
      final reps = parseRepsCount(set.reps);
      if (load != null && reps != null) {
        volume += load * reps;
        hasVolume = true;
      }
      final rpe = parseRpeFromLoad(set.load);
      if (rpe != null) {
        rpeSum += rpe;
        rpeCount++;
      }
    }
  }

  return SessionDiaryMetrics(
    exerciseCount: exerciseCount,
    setCount: setCount,
    volumeKg: volume,
    hasParsableVolume: hasVolume,
    avgRpe: rpeCount == 0 ? null : rpeSum / rpeCount,
    rpeSampleCount: rpeCount,
    hasRpeSamples: rpeCount > 0,
  );
}

/// Extracts RPE from strings that include `@`, e.g. `@8`, `60@8`, `75kg @8.5`.
double? parseRpeFromLoad(String raw) {
  final t = raw.trim().toLowerCase();
  if (t.isEmpty || !t.contains('@')) return null;
  final match = RegExp(r'@\s*(\d+(?:[.,]\d+)?)').firstMatch(t);
  if (match == null) return null;
  final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (n == null || n <= 0 || n > 10) return null;
  return n;
}

/// Extracts a positive kg value from strings like "60", "75kg", "60@8".
/// Pure RPE markers (`@8`) return null so they do not inflate volume.
double? parseLoadKg(String raw) {
  final t = raw.trim().toLowerCase();
  if (t.isEmpty) return null;
  if (t.startsWith('@')) return null;
  final beforeAt = t.contains('@') ? t.split('@').first.trim() : t;
  if (beforeAt.isEmpty) return null;
  final match = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(beforeAt);
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

String formatAvgRpe(double rpe) {
  final rounded = (rpe * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.toInt().toString();
  }
  return rounded.toStringAsFixed(1);
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

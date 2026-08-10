import '../../dashboard/domain/plan_calendar_event.dart';

/// Log of a single performed (or skipped) training session slot.
class SessionExecution {
  const SessionExecution({
    required this.sessionKey,
    required this.weekIndex,
    required this.dayIndex,
    required this.sessionDate,
    required this.status,
    this.completedAt,
    this.notes = '',
    this.exercises = const [],
    this.sessionRpe,
    this.painLevel,
    this.painLocation,
  });

  final String sessionKey;
  final int weekIndex;
  final int dayIndex;
  final DateTime sessionDate;
  final PlanSessionStatus status;
  final DateTime? completedAt;
  final String notes;
  final List<ExecutedExercise> exercises;

  /// Coach-reported difficulty of the actual session (1-10), distinct from
  /// the prescriptive [ExerciseSet.rpe] shown in the plan.
  final int? sessionRpe;

  /// Reported pain level during/after the session (0-10).
  final int? painLevel;

  /// Optional free-text location for the reported pain (e.g. "left knee").
  final String? painLocation;

  Map<String, dynamic> toJson() => {
    'sessionKey': sessionKey,
    'weekIndex': weekIndex,
    'dayIndex': dayIndex,
    'sessionDate': DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
    ).toIso8601String(),
    'status': _statusToJson(status),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    if (notes.trim().isNotEmpty) 'notes': notes.trim(),
    if (exercises.isNotEmpty)
      'exercises': exercises.map((e) => e.toJson()).toList(),
    if (sessionRpe != null) 'sessionRpe': sessionRpe,
    if (painLevel != null) 'painLevel': painLevel,
    if (painLocation != null && painLocation!.trim().isNotEmpty)
      'painLocation': painLocation!.trim(),
  };

  static SessionExecution fromJson(Map<String, dynamic> json) {
    final sessionDateRaw = json['sessionDate']?.toString();
    final parsedDate = sessionDateRaw == null
        ? null
        : DateTime.tryParse(sessionDateRaw);
    final completedRaw = json['completedAt']?.toString();
    final exercisesJson = json['exercises'] as List<dynamic>?;
    return SessionExecution(
      sessionKey: json['sessionKey']?.toString() ?? '',
      weekIndex: (json['weekIndex'] as num?)?.toInt() ?? 0,
      dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 0,
      sessionDate: parsedDate == null
          ? DateTime.now()
          : DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      status: _statusFromJson(json['status']?.toString()),
      completedAt: completedRaw == null ? null : DateTime.tryParse(completedRaw),
      notes: json['notes']?.toString() ?? '',
      exercises:
          exercisesJson
              ?.map(
                (e) => ExecutedExercise.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      sessionRpe: (json['sessionRpe'] as num?)?.toInt(),
      painLevel: (json['painLevel'] as num?)?.toInt(),
      painLocation: json['painLocation']?.toString(),
    );
  }

  SessionExecution copyWith({
    String? sessionKey,
    int? weekIndex,
    int? dayIndex,
    DateTime? sessionDate,
    PlanSessionStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? notes,
    List<ExecutedExercise>? exercises,
    int? sessionRpe,
    bool clearSessionRpe = false,
    int? painLevel,
    bool clearPainLevel = false,
    String? painLocation,
    bool clearPainLocation = false,
  }) => SessionExecution(
    sessionKey: sessionKey ?? this.sessionKey,
    weekIndex: weekIndex ?? this.weekIndex,
    dayIndex: dayIndex ?? this.dayIndex,
    sessionDate: sessionDate ?? this.sessionDate,
    status: status ?? this.status,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    notes: notes ?? this.notes,
    exercises: exercises ?? this.exercises,
    sessionRpe: clearSessionRpe ? null : (sessionRpe ?? this.sessionRpe),
    painLevel: clearPainLevel ? null : (painLevel ?? this.painLevel),
    painLocation: clearPainLocation
        ? null
        : (painLocation ?? this.painLocation),
  );

  static String _statusToJson(PlanSessionStatus status) => switch (status) {
    PlanSessionStatus.completed => 'completed',
    PlanSessionStatus.skipped => 'skipped',
    PlanSessionStatus.planned => 'planned',
  };

  static PlanSessionStatus _statusFromJson(String? raw) => switch (raw) {
    'completed' => PlanSessionStatus.completed,
    'skipped' => PlanSessionStatus.skipped,
    _ => PlanSessionStatus.planned,
  };
}

class ExecutedExercise {
  const ExecutedExercise({
    required this.exerciseId,
    required this.name,
    this.sets = const [],
    this.customExerciseId,
    this.completed = true,
  });

  final String exerciseId;
  final String name;
  final List<ExecutedSet> sets;
  final String? customExerciseId;
  final bool completed;

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'name': name,
    if (customExerciseId != null) 'customExerciseId': customExerciseId,
    'completed': completed,
    if (sets.isNotEmpty) 'sets': sets.map((s) => s.toJson()).toList(),
  };

  static ExecutedExercise fromJson(Map<String, dynamic> json) {
    final setsJson = json['sets'] as List<dynamic>?;
    return ExecutedExercise(
      exerciseId: json['exerciseId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      customExerciseId: json['customExerciseId']?.toString(),
      completed: json['completed'] as bool? ?? true,
      sets:
          setsJson
              ?.map((s) => ExecutedSet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class ExecutedSet {
  const ExecutedSet({
    this.reps = '',
    this.load = '',
    this.completed = true,
  });

  final String reps;
  final String load;
  final bool completed;

  Map<String, dynamic> toJson() => {
    if (reps.isNotEmpty) 'reps': reps,
    if (load.isNotEmpty) 'load': load,
    'completed': completed,
  };

  static ExecutedSet fromJson(Map<String, dynamic> json) => ExecutedSet(
    reps: json['reps']?.toString() ?? '',
    load: json['load']?.toString() ?? '',
    completed: json['completed'] as bool? ?? true,
  );
}

Map<String, SessionExecution> parseSessionExecutions(dynamic raw) {
  if (raw is! Map) return const {};
  final parsed = <String, SessionExecution>{};
  for (final entry in raw.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      parsed[entry.key.toString()] = SessionExecution.fromJson(value);
    } else if (value is Map) {
      parsed[entry.key.toString()] = SessionExecution.fromJson(
        value.cast<String, dynamic>(),
      );
    }
  }
  return parsed;
}

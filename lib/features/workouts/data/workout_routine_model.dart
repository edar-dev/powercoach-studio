// In-memory model for Workout Builder. Serializable via [workout_routine_json_codec.dart].

import '../domain/exercise_prescription_scope.dart';
import '../domain/session_execution.dart';
import '../domain/workout_routine_json_codec.dart';

/// A named section in the mobility routine (e.g. Upper Body, Lower Body). User can add, edit, delete.
class MobilitySection {
  const MobilitySection({
    required this.id,
    required this.name,
    this.scheduleHint = '',
  });

  final String id;
  final String name;

  /// Optional cadence hint for PDF (e.g. "Giorni pari 2, 4, 6").
  final String scheduleHint;

  Map<String, dynamic> toJson() => encodeMobilitySection(this);

  static MobilitySection fromJson(Map<String, dynamic> json) =>
      decodeMobilitySection(json);

  MobilitySection copyWith({String? id, String? name, String? scheduleHint}) =>
      MobilitySection(
        id: id ?? this.id,
        name: name ?? this.name,
        scheduleHint: scheduleHint ?? this.scheduleHint,
      );
}

class WorkoutRoutine {
  WorkoutRoutine({
    required this.name,
    required this.mobilitySections,
    required this.mobilityItems,
    required this.weeks,
    this.startDate,
    this.endDate,
    this.currentWeek,
    this.includesMobilityTab = true,
    this.sessionCompletionByKey = const {},
    this.sessionSkippedByKey = const {},
    this.sessionOverrides = const {},
    this.sessionExecutions = const {},
  });

  final String name;
  final List<MobilitySection> mobilitySections;
  final List<MobilityItem> mobilityItems;
  final List<Week> weeks;

  /// When false, the builder hides the mobility tab (training + details only).
  final bool includesMobilityTab;

  /// Calendar start of the plan; persisted in planData. Null for legacy JSON.
  final DateTime? startDate;

  /// Optional explicit end date for the assignment window.
  final DateTime? endDate;

  /// Coach-facing progress marker (1-based week index when set).
  final int? currentWeek;

  /// Keys `weekIndex-dayIndex` → completed session.
  final Map<String, bool> sessionCompletionByKey;

  /// Keys `weekIndex-dayIndex` → skipped session.
  final Map<String, bool> sessionSkippedByKey;

  /// Keys `weekIndex-dayIndex-yyyy-MM-dd` → occurrence-level override.
  final Map<String, SessionOverride> sessionOverrides;

  /// Keys `weekIndex-dayIndex` → session execution log.
  final Map<String, SessionExecution> sessionExecutions;

  static String sessionKey(int weekIndex, int dayIndex) =>
      '$weekIndex-$dayIndex';

  Map<String, dynamic> toJson() => encodeWorkoutRoutine(this);

  static WorkoutRoutine fromJson(Map<String, dynamic> json) =>
      decodeWorkoutRoutine(json);

  static List<Week> defaultWeeks() => defaultWorkoutWeeks();

  /// Empty routine for creating a new workout from scratch (one default mobility section).
  static WorkoutRoutine empty() {
    final n = DateTime.now();
    return WorkoutRoutine(
      name: '',
      mobilitySections: [const MobilitySection(id: 'sec_1', name: 'Section 1')],
      mobilityItems: [],
      weeks: [],
      startDate: DateTime(n.year, n.month, n.day),
    );
  }

  WorkoutRoutine copyWith({
    String? name,
    List<MobilitySection>? mobilitySections,
    List<MobilityItem>? mobilityItems,
    List<Week>? weeks,
    DateTime? startDate,
    DateTime? endDate,
    int? currentWeek,
    bool? includesMobilityTab,
    Map<String, bool>? sessionCompletionByKey,
    Map<String, bool>? sessionSkippedByKey,
    Map<String, SessionOverride>? sessionOverrides,
    Map<String, SessionExecution>? sessionExecutions,
  }) => WorkoutRoutine(
    name: name ?? this.name,
    mobilitySections: mobilitySections ?? this.mobilitySections,
    mobilityItems: mobilityItems ?? this.mobilityItems,
    weeks: weeks ?? this.weeks,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    currentWeek: currentWeek ?? this.currentWeek,
    includesMobilityTab: includesMobilityTab ?? this.includesMobilityTab,
    sessionCompletionByKey:
        sessionCompletionByKey ?? this.sessionCompletionByKey,
    sessionSkippedByKey: sessionSkippedByKey ?? this.sessionSkippedByKey,
    sessionOverrides: sessionOverrides ?? this.sessionOverrides,
    sessionExecutions: sessionExecutions ?? this.sessionExecutions,
  );
}

enum SessionOverrideKind { skipped, moved }

class SessionOverride {
  const SessionOverride.skipped()
    : kind = SessionOverrideKind.skipped,
      movedToDate = null;

  SessionOverride.moved(DateTime date)
    : kind = SessionOverrideKind.moved,
      movedToDate = DateTime(date.year, date.month, date.day);

  final SessionOverrideKind kind;
  final DateTime? movedToDate;

  Map<String, dynamic> toJson() => encodeSessionOverride(this);

  static SessionOverride fromJson(Map<String, dynamic> json) =>
      decodeSessionOverride(json);
}

class MobilityItem {
  const MobilityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sectionId,
    this.shortTitle = '',
    this.categoryIndex = 0,
    this.customExerciseId,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Compact title for dense PDF rows when [title] is long.
  final String shortTitle;

  /// Id of the [MobilitySection] this item belongs to.
  final String sectionId;

  /// Kept for backward compatibility when reading old JSON.
  final int categoryIndex;

  /// When set, this item is linked to the user's custom exercise library entry.
  final String? customExerciseId;

  Map<String, dynamic> toJson() => encodeMobilityItem(this);

  static MobilityItem fromJson(
    Map<String, dynamic> json, [
    List<MobilitySection>? sections,
  ]) =>
      decodeMobilityItem(json, sections);

  MobilityItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? shortTitle,
    String? sectionId,
    int? categoryIndex,
    String? customExerciseId,
  }) => MobilityItem(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    shortTitle: shortTitle ?? this.shortTitle,
    sectionId: sectionId ?? this.sectionId,
    categoryIndex: categoryIndex ?? this.categoryIndex,
    customExerciseId: customExerciseId ?? this.customExerciseId,
  );

  String get pdfTitle {
    final compact = shortTitle.trim();
    return compact.isNotEmpty ? compact : title.trim();
  }
}

class Week {
  const Week({required this.id, required this.name, required this.days});

  final String id;
  final String name;
  final List<Day> days;

  Map<String, dynamic> toJson() => encodeWeek(this);

  static Week fromJson(Map<String, dynamic> json) => decodeWeek(json);

  Week copyWith({String? id, String? name, List<Day>? days}) =>
      Week(id: id ?? this.id, name: name ?? this.name, days: days ?? this.days);
}

class Day {
  const Day({
    required this.id,
    required this.name,
    required this.exercises,
    this.scheduledWeekday,
  });

  final String id;
  final String name;
  final List<Exercise> exercises;

  /// Optional ISO weekday: 1=Mon ... 7=Sun.
  final int? scheduledWeekday;

  Map<String, dynamic> toJson() => encodeDay(this);

  static Day fromJson(Map<String, dynamic> json) => decodeDay(json);

  Day copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
    int? scheduledWeekday,
    bool clearScheduledWeekday = false,
  }) => Day(
    id: id ?? this.id,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
    scheduledWeekday: clearScheduledWeekday
        ? null
        : (scheduledWeekday ?? this.scheduledWeekday),
  );
}

/// Partitions exercises into standalone (single) and superset groups.
/// Returns list of [Exercise] (standalone) or [List<Exercise>] (group).
List<Object> partitionExercisesBySuperset(List<Exercise> exercises) {
  final result = <Object>[];
  final seenGroupIds = <String>{};
  for (final e in exercises) {
    if (e.supersetGroupId == null || e.supersetGroupId!.isEmpty) {
      result.add(e);
    } else {
      if (!seenGroupIds.contains(e.supersetGroupId)) {
        seenGroupIds.add(e.supersetGroupId!);
        final group = exercises
            .where((x) => x.supersetGroupId == e.supersetGroupId)
            .toList();
        result.add(group);
      }
    }
  }
  return result;
}

/// Single set prescription: combo of sets × reps (e.g. 1×3 75kg, 3×3 60kg).
/// [line] optional free-form; when empty, display uses [sets]×[reps] + [rpe] (load).
class ExerciseSet {
  const ExerciseSet({
    this.line = '',
    this.sets = '1',
    this.reps = '',
    this.rpe = '',
    this.note = '',
  });

  /// Free-form line (e.g. "1x3 75kg"). When set, used as display.
  final String line;

  /// Number of sets for this block (e.g. "1", "3").
  final String sets;
  final String reps;

  /// Load or RPE (e.g. "75kg", "@8").
  final String rpe;
  final String note;

  /// Text to show in lists/PDF: [line] if set, else "sets×reps" + optional load.
  String get displayText {
    if (line.trim().isNotEmpty) return line.trim();
    final n = sets.trim();
    final r = reps.trim();
    final p = rpe.trim();
    if (n.isEmpty && r.isEmpty && p.isEmpty) return '';
    if (n.isEmpty && r.isEmpty) return p;
    if (n.isEmpty) return r.isEmpty ? p : '$r ${p.isEmpty ? '' : p}'.trim();
    if (r.isEmpty) return n + (p.isEmpty ? '' : ' $p').trim();
    // Legacy JSON often stores full schemes in [reps] (e.g. "1x5@7"); do not prepend [sets].
    if (RegExp(r'^\d+x').hasMatch(r) || r.contains('@')) {
      return p.isEmpty ? r : '$r $p'.trim();
    }
    final combo = '${n}x$r';
    return p.isEmpty ? combo : '$combo $p';
  }

  Map<String, dynamic> toJson() => encodeExerciseSet(this);

  static ExerciseSet fromJson(Map<String, dynamic> json) =>
      decodeExerciseSet(json);

  ExerciseSet copyWith({
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) => ExerciseSet(
    line: line ?? this.line,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    rpe: rpe ?? this.rpe,
    note: note ?? this.note,
  );
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rpe,
    this.note = '',
    this.shortName = '',
    this.prescriptionScope = ExercisePrescriptionScope.perWeek,
    this.setDetails,
    this.supersetGroupId,
    this.customExerciseId,
  });

  final String id;
  final String name;
  final String sets;
  final String reps;
  final String rpe;
  final String note;

  /// Optional compact label for PDF tables.
  final String shortName;
  final ExercisePrescriptionScope prescriptionScope;

  /// Multiple set prescriptions (e.g. top set/backoff). When null or empty, use [sets]/[reps]/[rpe] as single prescription.
  final List<ExerciseSet>? setDetails;

  /// When non-null, exercises in the same day with the same id form a superset.
  final String? supersetGroupId;

  /// When set, this exercise is linked to the user's custom exercise library entry.
  final String? customExerciseId;

  Map<String, dynamic> toJson() => encodeExercise(this);

  static Exercise fromJson(Map<String, dynamic> json) => decodeExercise(json);

  /// Effective list of set prescriptions (never null/empty: at least one from setDetails or legacy).
  List<ExerciseSet> get effectiveSetDetails =>
      (setDetails != null && setDetails!.isNotEmpty)
      ? setDetails!
      : [ExerciseSet(sets: sets, reps: reps, rpe: rpe, note: note)];

  Exercise copyWith({
    String? id,
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
    String? supersetGroupId,
    String? customExerciseId,
    bool clearSupersetGroupId = false,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    rpe: rpe ?? this.rpe,
    note: note ?? this.note,
    shortName: shortName ?? this.shortName,
    prescriptionScope: prescriptionScope ?? this.prescriptionScope,
    setDetails: setDetails ?? this.setDetails,
    supersetGroupId: clearSupersetGroupId
        ? null
        : (supersetGroupId ?? this.supersetGroupId),
    customExerciseId: customExerciseId ?? this.customExerciseId,
  );
}

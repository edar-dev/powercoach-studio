// In-memory model for Workout Builder. Serializable to JSON for persistence.

List<MobilitySection> _defaultMobilitySections() => [
      const MobilitySection(id: 'sec_upper', name: 'Upper Body'),
      const MobilitySection(id: 'sec_lower', name: 'Lower Body'),
      const MobilitySection(id: 'sec_full', name: 'Full Body'),
    ];

/// A named section in the mobility routine (e.g. Upper Body, Lower Body). User can add, edit, delete.
class MobilitySection {
  const MobilitySection({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  static MobilitySection fromJson(Map<String, dynamic> json) => MobilitySection(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );

  MobilitySection copyWith({String? id, String? name}) =>
      MobilitySection(id: id ?? this.id, name: name ?? this.name);
}

class WorkoutRoutine {
  const WorkoutRoutine({
    required this.name,
    required this.mobilitySections,
    required this.mobilityItems,
    required this.weeks,
  });

  final String name;
  final List<MobilitySection> mobilitySections;
  final List<MobilityItem> mobilityItems;
  final List<Week> weeks;

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobilitySections': mobilitySections.map((e) => e.toJson()).toList(),
        'mobilityItems': mobilityItems.map((e) => e.toJson()).toList(),
        'weeks': weeks.map((e) => e.toJson()).toList(),
      };

  static WorkoutRoutine fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['mobilitySections'] as List<dynamic>?;
    final sections = sectionsJson != null && sectionsJson.isNotEmpty
        ? sectionsJson
            .map((e) => MobilitySection.fromJson(e as Map<String, dynamic>))
            .toList()
        : _defaultMobilitySections();

    final itemsJson = json['mobilityItems'] as List<dynamic>?;
    final items = itemsJson
            ?.map((e) => MobilityItem.fromJson(e as Map<String, dynamic>, sections))
            .toList() ??
        [];

    return WorkoutRoutine(
      name: json['name'] as String? ?? 'Hypertrophy Phase 1',
      mobilitySections: sections,
      mobilityItems: items,
      weeks: (json['weeks'] as List<dynamic>?)
              ?.map((e) => Week.fromJson(e as Map<String, dynamic>))
              .toList() ??
          defaultWeeks(),
    );
  }

  static List<Week> defaultWeeks() => [
        Week(
          id: 'w1',
          name: 'WEEK 1: ACCLIMATION',
          days: [
            Day(
              id: 'd1',
              name: 'DAY 1 - Lower Body Push',
              exercises: [
                const Exercise(id: 'e1', name: 'Barbell Back Squat', sets: '3', reps: '8-10', rpe: '@8', note: ''),
                const Exercise(id: 'e2', name: 'Leg Press', sets: '3', reps: '12', rpe: '315lb', note: ''),
              ],
            ),
          ],
        ),
      ];

  /// Empty routine for creating a new workout from scratch (one default mobility section).
  static WorkoutRoutine empty() => WorkoutRoutine(
        name: '',
        mobilitySections: [const MobilitySection(id: 'sec_1', name: 'Section 1')],
        mobilityItems: [],
        weeks: [],
      );

  WorkoutRoutine copyWith({
    String? name,
    List<MobilitySection>? mobilitySections,
    List<MobilityItem>? mobilityItems,
    List<Week>? weeks,
  }) =>
      WorkoutRoutine(
        name: name ?? this.name,
        mobilitySections: mobilitySections ?? this.mobilitySections,
        mobilityItems: mobilityItems ?? this.mobilityItems,
        weeks: weeks ?? this.weeks,
      );
}

class MobilityItem {
  const MobilityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sectionId,
    this.categoryIndex = 0,
    this.customExerciseId,
  });

  final String id;
  final String title;
  final String subtitle;
  /// Id of the [MobilitySection] this item belongs to.
  final String sectionId;
  /// Kept for backward compatibility when reading old JSON.
  final int categoryIndex;
  /// When set, this item is linked to the user's custom exercise library (GymBlog.API).
  final String? customExerciseId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'sectionId': sectionId,
        'categoryIndex': categoryIndex,
        if (customExerciseId != null && customExerciseId!.isNotEmpty) 'customExerciseId': customExerciseId,
      };

  static MobilityItem fromJson(Map<String, dynamic> json, [List<MobilitySection>? sections]) {
    final secs = sections ?? _defaultMobilitySections();
    final sectionId = json['sectionId'] as String?;
    final categoryIndex = json['categoryIndex'] as int? ?? 0;
    final resolvedSectionId = sectionId != null && sectionId.isNotEmpty
        ? sectionId
        : (categoryIndex >= 0 && categoryIndex < secs.length ? secs[categoryIndex].id : secs.first.id);
    return MobilityItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      sectionId: resolvedSectionId,
      categoryIndex: categoryIndex,
      customExerciseId: json['customExerciseId'] as String?,
    );
  }

  MobilityItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? sectionId,
    int? categoryIndex,
    String? customExerciseId,
  }) =>
      MobilityItem(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        sectionId: sectionId ?? this.sectionId,
        categoryIndex: categoryIndex ?? this.categoryIndex,
        customExerciseId: customExerciseId ?? this.customExerciseId,
      );
}

class Week {
  const Week({required this.id, required this.name, required this.days});

  final String id;
  final String name;
  final List<Day> days;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'days': days.map((e) => e.toJson()).toList(),
      };

  static Week fromJson(Map<String, dynamic> json) => Week(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Week',
        days: (json['days'] as List<dynamic>?)
                ?.map((e) => Day.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Week copyWith({String? id, String? name, List<Day>? days}) =>
      Week(id: id ?? this.id, name: name ?? this.name, days: days ?? this.days);
}

class Day {
  const Day({required this.id, required this.name, required this.exercises});

  final String id;
  final String name;
  final List<Exercise> exercises;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  static Day fromJson(Map<String, dynamic> json) => Day(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Day',
        exercises: (json['exercises'] as List<dynamic>?)
                ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Day copyWith({String? id, String? name, List<Exercise>? exercises}) =>
      Day(id: id ?? this.id, name: name ?? this.name, exercises: exercises ?? this.exercises);
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
        final group = exercises.where((x) => x.supersetGroupId == e.supersetGroupId).toList();
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
    final combo = '${n}x$r';
    return p.isEmpty ? combo : '$combo $p';
  }

  Map<String, dynamic> toJson() => {
        if (line.isNotEmpty) 'line': line,
        if (sets != '1') 'sets': sets,
        'reps': reps,
        'rpe': rpe,
        if (note.isNotEmpty) 'note': note,
      };

  static ExerciseSet fromJson(Map<String, dynamic> json) {
    final lineStr = json['line'] as String? ?? '';
    return ExerciseSet(
      line: lineStr,
      sets: json['sets'] as String? ?? '1',
      reps: json['reps'] as String? ?? '',
      rpe: json['rpe'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }

  ExerciseSet copyWith({String? line, String? sets, String? reps, String? rpe, String? note}) => ExerciseSet(
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
  /// Multiple set prescriptions (e.g. top set/backoff). When null or empty, use [sets]/[reps]/[rpe] as single prescription.
  final List<ExerciseSet>? setDetails;
  /// When non-null, exercises in the same day with the same id form a superset.
  final String? supersetGroupId;
  /// When set, this exercise is linked to the user's custom exercise library (GymBlog.API).
  final String? customExerciseId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'rpe': rpe,
        'note': note,
        if (setDetails != null && setDetails!.isNotEmpty)
          'setDetails': setDetails!.map((s) => s.toJson()).toList(),
        if (supersetGroupId != null && supersetGroupId!.isNotEmpty) 'supersetGroupId': supersetGroupId,
        if (customExerciseId != null && customExerciseId!.isNotEmpty) 'customExerciseId': customExerciseId,
      };

  static Exercise fromJson(Map<String, dynamic> json) {
    final setDetailsJson = json['setDetails'] as List<dynamic>?;
    List<ExerciseSet>? setDetails;
    if (setDetailsJson != null && setDetailsJson.isNotEmpty) {
      setDetails = setDetailsJson
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final repsStr = json['reps'] as String? ?? '';
      final rpeStr = json['rpe'] as String? ?? '';
      setDetails = [ExerciseSet(reps: repsStr, rpe: rpeStr)];
    }
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sets: json['sets'] as String? ?? '3',
      reps: json['reps'] as String? ?? '',
      rpe: json['rpe'] as String? ?? '',
      note: json['note'] as String? ?? '',
      setDetails: setDetails,
      supersetGroupId: json['supersetGroupId'] as String?,
      customExerciseId: json['customExerciseId'] as String?,
    );
  }

  /// Effective list of set prescriptions (never null/empty: at least one from setDetails or legacy).
  List<ExerciseSet> get effectiveSetDetails =>
      (setDetails != null && setDetails!.isNotEmpty) ? setDetails! : [ExerciseSet(reps: reps, rpe: rpe, note: note)];

  Exercise copyWith({
    String? id,
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    List<ExerciseSet>? setDetails,
    String? supersetGroupId,
    String? customExerciseId,
    bool clearSupersetGroupId = false,
  }) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        rpe: rpe ?? this.rpe,
        note: note ?? this.note,
        setDetails: setDetails ?? this.setDetails,
        supersetGroupId: clearSupersetGroupId ? null : (supersetGroupId ?? this.supersetGroupId),
        customExerciseId: customExerciseId ?? this.customExerciseId,
      );
}

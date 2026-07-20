import 'dart:convert';

import '../data/workout_routine_model.dart';
import 'exercise_prescription_scope.dart';
import 'exercise_summary_sync.dart';
import 'session_execution.dart';

const int workoutRoutineJsonSchemaVersion = 1;
const String workoutRoutineJsonFormat = 'powercoach-workout-routine';

List<MobilitySection> defaultMobilitySections() => [
  const MobilitySection(id: 'sec_upper', name: 'Upper Body'),
  const MobilitySection(id: 'sec_lower', name: 'Lower Body'),
  const MobilitySection(id: 'sec_full', name: 'Full Body'),
];

Map<String, dynamic> encodeMobilitySection(MobilitySection section) => {
  'id': section.id,
  'name': section.name,
  if (section.scheduleHint.trim().isNotEmpty)
    'scheduleHint': section.scheduleHint.trim(),
};

MobilitySection decodeMobilitySection(Map<String, dynamic> json) =>
    MobilitySection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      scheduleHint: json['scheduleHint'] as String? ?? '',
    );

Map<String, dynamic> encodeSessionOverride(SessionOverride override) => {
  'kind': override.kind == SessionOverrideKind.skipped ? 'skipped' : 'moved',
  if (override.movedToDate != null)
    'movedToDate': override.movedToDate!.toIso8601String(),
};

SessionOverride decodeSessionOverride(Map<String, dynamic> json) {
  final kindRaw = json['kind']?.toString();
  if (kindRaw == 'moved') {
    final movedRaw = json['movedToDate'];
    final moved =
        movedRaw == null ? null : DateTime.tryParse(movedRaw.toString());
    if (moved != null) return SessionOverride.moved(moved);
  }
  return const SessionOverride.skipped();
}

Map<String, dynamic> encodeMobilityItem(MobilityItem item) => {
  'id': item.id,
  'title': item.title,
  'subtitle': item.subtitle,
  'sectionId': item.sectionId,
  'categoryIndex': item.categoryIndex,
  if (item.shortTitle.trim().isNotEmpty) 'shortTitle': item.shortTitle.trim(),
  if (item.customExerciseId != null && item.customExerciseId!.isNotEmpty)
    'customExerciseId': item.customExerciseId,
};

MobilityItem decodeMobilityItem(
  Map<String, dynamic> json, [
  List<MobilitySection>? sections,
]) {
  final secs = sections ?? defaultMobilitySections();
  final sectionId = json['sectionId'] as String?;
  final categoryIndex = json['categoryIndex'] as int? ?? 0;
  final resolvedSectionId = sectionId != null && sectionId.isNotEmpty
      ? sectionId
      : (categoryIndex >= 0 && categoryIndex < secs.length
            ? secs[categoryIndex].id
            : secs.first.id);
  return MobilityItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    shortTitle: json['shortTitle'] as String? ?? '',
    sectionId: resolvedSectionId,
    categoryIndex: categoryIndex,
    customExerciseId: json['customExerciseId'] as String?,
  );
}

Map<String, dynamic> encodeExerciseSet(ExerciseSet set) => {
  if (set.line.isNotEmpty) 'line': set.line,
  if (set.sets != '1') 'sets': set.sets,
  'reps': set.reps,
  'rpe': set.rpe,
  if (set.note.isNotEmpty) 'note': set.note,
};

ExerciseSet decodeExerciseSet(Map<String, dynamic> json) {
  final lineStr = json['line'] as String? ?? '';
  return ExerciseSet(
    line: lineStr,
    sets: json['sets'] as String? ?? '1',
    reps: json['reps'] as String? ?? '',
    rpe: json['rpe'] as String? ?? '',
    note: json['note'] as String? ?? '',
  );
}

Map<String, dynamic> encodeExercise(Exercise exercise) {
  final synced = ExerciseSummarySync.apply(exercise);
  return {
    'id': synced.id,
    'name': synced.name,
    'sets': synced.sets,
    'reps': synced.reps,
    'rpe': synced.rpe,
    'note': synced.note,
    if (synced.shortName.trim().isNotEmpty) 'shortName': synced.shortName.trim(),
    if (synced.prescriptionScope != ExercisePrescriptionScope.perWeek)
      'prescriptionScope': synced.prescriptionScope.toJson(),
    if (synced.setDetails != null && synced.setDetails!.isNotEmpty)
      'setDetails': synced.setDetails!.map(encodeExerciseSet).toList(),
    if (synced.supersetGroupId != null && synced.supersetGroupId!.isNotEmpty)
      'supersetGroupId': synced.supersetGroupId,
    if (synced.customExerciseId != null && synced.customExerciseId!.isNotEmpty)
      'customExerciseId': synced.customExerciseId,
  };
}

Exercise decodeExercise(Map<String, dynamic> json) {
  final setDetailsJson = json['setDetails'] as List<dynamic>?;
  List<ExerciseSet>? setDetails;
  if (setDetailsJson != null && setDetailsJson.isNotEmpty) {
    setDetails = setDetailsJson
        .map((e) => decodeExerciseSet(e as Map<String, dynamic>))
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
    shortName: json['shortName'] as String? ?? '',
    prescriptionScope: ExercisePrescriptionScope.fromJson(
      json['prescriptionScope'] as String?,
    ),
    setDetails: setDetails,
    supersetGroupId: json['supersetGroupId'] as String?,
    customExerciseId: json['customExerciseId'] as String?,
  );
}

Map<String, dynamic> encodeDay(Day day) => {
  'id': day.id,
  'name': day.name,
  'exercises': day.exercises.map(encodeExercise).toList(),
  if (day.scheduledWeekday != null) 'scheduledWeekday': day.scheduledWeekday,
};

Day decodeDay(Map<String, dynamic> json) => Day(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? 'Day',
  exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => decodeExercise(e as Map<String, dynamic>))
          .toList() ??
      [],
  scheduledWeekday: _parseScheduledWeekday(json['scheduledWeekday']),
);

Map<String, dynamic> encodeWeek(Week week) => {
  'id': week.id,
  'name': week.name,
  'days': week.days.map(encodeDay).toList(),
};

Week decodeWeek(Map<String, dynamic> json) => Week(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? 'Week',
  days: (json['days'] as List<dynamic>?)
          ?.map((e) => decodeDay(e as Map<String, dynamic>))
          .toList() ??
      [],
);

List<Week> defaultWorkoutWeeks() => [
  Week(
    id: 'w1',
    name: 'WEEK 1: ACCLIMATION',
    days: [
      Day(
        id: 'd1',
        name: 'DAY 1 - Lower Body Push',
        exercises: [
          const Exercise(
            id: 'e1',
            name: 'Barbell Back Squat',
            sets: '3',
            reps: '8-10',
            rpe: '@8',
            note: '',
          ),
          const Exercise(
            id: 'e2',
            name: 'Leg Press',
            sets: '3',
            reps: '12',
            rpe: '315lb',
            note: '',
          ),
        ],
      ),
    ],
  ),
];

Map<String, dynamic> encodeWorkoutRoutine(WorkoutRoutine routine) => {
  'name': routine.name,
  'mobilitySections': routine.mobilitySections.map(encodeMobilitySection).toList(),
  'mobilityItems': routine.mobilityItems.map(encodeMobilityItem).toList(),
  'weeks': routine.weeks.map(encodeWeek).toList(),
  if (routine.startDate != null)
    'startDate': DateTime(
      routine.startDate!.year,
      routine.startDate!.month,
      routine.startDate!.day,
    ).toIso8601String(),
  if (routine.endDate != null)
    'endDate': DateTime(
      routine.endDate!.year,
      routine.endDate!.month,
      routine.endDate!.day,
    ).toIso8601String(),
  if (routine.currentWeek != null) 'currentWeek': routine.currentWeek,
  if (!routine.includesMobilityTab) 'includesMobilityTab': false,
  if (routine.sessionCompletionByKey.isNotEmpty)
    'sessionCompletionByKey': routine.sessionCompletionByKey,
  if (routine.sessionSkippedByKey.isNotEmpty)
    'sessionSkippedByKey': routine.sessionSkippedByKey,
  if (routine.sessionOverrides.isNotEmpty)
    'sessionOverrides': {
      for (final entry in routine.sessionOverrides.entries)
        entry.key: encodeSessionOverride(entry.value),
    },
  if (routine.sessionExecutions.isNotEmpty)
    'sessionExecutions': {
      for (final entry in routine.sessionExecutions.entries)
        entry.key: entry.value.toJson(),
    },
};

WorkoutRoutine decodeWorkoutRoutine(Map<String, dynamic> json) {
  final sectionsJson = json['mobilitySections'] as List<dynamic>?;
  final sections = sectionsJson != null && sectionsJson.isNotEmpty
      ? sectionsJson
            .map((e) => decodeMobilitySection(e as Map<String, dynamic>))
            .toList()
      : defaultMobilitySections();

  final itemsJson = json['mobilityItems'] as List<dynamic>?;
  final items = itemsJson
          ?.map((e) => decodeMobilityItem(e as Map<String, dynamic>, sections))
          .toList() ??
      [];

  DateTime? parsedStart;
  final sd = json['startDate'];
  if (sd != null) {
    parsedStart = DateTime.tryParse(sd.toString());
    if (parsedStart != null) {
      parsedStart = DateTime(
        parsedStart.year,
        parsedStart.month,
        parsedStart.day,
      );
    }
  }

  DateTime? parsedEnd;
  final ed = json['endDate'];
  if (ed != null) {
    parsedEnd = DateTime.tryParse(ed.toString());
    if (parsedEnd != null) {
      parsedEnd = DateTime(parsedEnd.year, parsedEnd.month, parsedEnd.day);
    }
  }

  final currentWeek = (json['currentWeek'] as num?)?.toInt();
  final includesMobilityTab = json['includesMobilityTab'] as bool? ?? true;
  final completionByKey = _parseBoolMap(json['sessionCompletionByKey']);
  final skippedByKey = _parseBoolMap(json['sessionSkippedByKey']);
  final overrides = _parseSessionOverrides(json['sessionOverrides']);
  final executions = parseSessionExecutions(json['sessionExecutions']);

  return WorkoutRoutine(
    name: json['name'] as String? ?? 'Hypertrophy Phase 1',
    mobilitySections: sections,
    mobilityItems: items,
    weeks: (json['weeks'] as List<dynamic>?)
            ?.map((e) => decodeWeek(e as Map<String, dynamic>))
            .toList() ??
        defaultWorkoutWeeks(),
    startDate: parsedStart,
    endDate: parsedEnd,
    currentWeek: currentWeek,
    includesMobilityTab: includesMobilityTab,
    sessionCompletionByKey: completionByKey,
    sessionSkippedByKey: skippedByKey,
    sessionOverrides: overrides,
    sessionExecutions: executions,
  );
}

/// Wraps [routine] in a versioned export envelope for interchange.
Map<String, dynamic> encodeWorkoutRoutineEnvelope(WorkoutRoutine routine) {
  return {
    'schemaVersion': workoutRoutineJsonSchemaVersion,
    'format': workoutRoutineJsonFormat,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'routine': encodeWorkoutRoutine(routine),
  };
}

/// Parses JSON text into a [WorkoutRoutine].
///
/// Accepts the export envelope or a raw planData object.
WorkoutRoutine decodeWorkoutRoutineJson(String jsonText) {
  final decoded = jsonDecode(jsonText);
  if (decoded is! Map) {
    throw const FormatException('Root must be a JSON object');
  }
  final map = decoded.cast<String, dynamic>();
  final routineMap = _extractRoutineMap(map);
  if (routineMap['weeks'] is! List) {
    throw const FormatException('Missing weeks array');
  }
  return decodeWorkoutRoutine(routineMap);
}

String encodeWorkoutRoutineJson(WorkoutRoutine routine) {
  return const JsonEncoder.withIndent('  ').convert(
    encodeWorkoutRoutineEnvelope(routine),
  );
}

Map<String, dynamic> _extractRoutineMap(Map<String, dynamic> map) {
  final format = map['format']?.toString();
  if (format == workoutRoutineJsonFormat || map.containsKey('routine')) {
    final routine = map['routine'];
    if (routine is! Map) {
      throw const FormatException('Invalid routine envelope');
    }
    final version = map['schemaVersion'];
    if (version is num && version.toInt() > workoutRoutineJsonSchemaVersion) {
      throw FormatException('Unsupported schema version: ${version.toInt()}');
    }
    return routine.cast<String, dynamic>();
  }
  return map;
}

Map<String, bool> _parseBoolMap(dynamic raw) {
  if (raw is! Map) {
    return const {};
  }
  final parsed = <String, bool>{};
  for (final entry in raw.entries) {
    final value = entry.value;
    if (value == true) {
      parsed[entry.key.toString()] = true;
    }
  }
  return parsed;
}

Map<String, SessionOverride> _parseSessionOverrides(dynamic raw) {
  if (raw is! Map) return const {};
  final parsed = <String, SessionOverride>{};
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      parsed[key] = decodeSessionOverride(value);
    } else if (value is Map) {
      parsed[key] = decodeSessionOverride(value.cast<String, dynamic>());
    }
  }
  return parsed;
}

int? _parseScheduledWeekday(dynamic raw) {
  final parsed = (raw as num?)?.toInt();
  if (parsed == null || parsed < DateTime.monday || parsed > DateTime.sunday) {
    return null;
  }
  return parsed;
}

// In-memory model for Workout Builder. Serializable to JSON for persistence.

class WorkoutRoutine {
  const WorkoutRoutine({
    required this.name,
    required this.mobilityItems,
    required this.weeks,
  });

  final String name;
  final List<MobilityItem> mobilityItems;
  final List<Week> weeks;

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobilityItems': mobilityItems.map((e) => e.toJson()).toList(),
        'weeks': weeks.map((e) => e.toJson()).toList(),
      };

  static WorkoutRoutine fromJson(Map<String, dynamic> json) {
    return WorkoutRoutine(
      name: json['name'] as String? ?? 'Hypertrophy Phase 1',
      mobilityItems: (json['mobilityItems'] as List<dynamic>?)
              ?.map((e) => MobilityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          defaultMobilityItems(),
      weeks: (json['weeks'] as List<dynamic>?)
              ?.map((e) => Week.fromJson(e as Map<String, dynamic>))
              .toList() ??
          defaultWeeks(),
    );
  }

  static List<MobilityItem> defaultMobilityItems() => [
        const MobilityItem(id: 'm1', title: 'T-Spine Rotation', subtitle: 'Focus on breathing and rib cage position', categoryIndex: 0),
        const MobilityItem(id: 'm2', title: '90/90 Hip Switch', subtitle: "Keep torso upright, 10 reps per side", categoryIndex: 0),
      ];

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

  WorkoutRoutine copyWith({
    String? name,
    List<MobilityItem>? mobilityItems,
    List<Week>? weeks,
  }) =>
      WorkoutRoutine(
        name: name ?? this.name,
        mobilityItems: mobilityItems ?? this.mobilityItems,
        weeks: weeks ?? this.weeks,
      );
}

class MobilityItem {
  const MobilityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.categoryIndex = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final int categoryIndex;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'categoryIndex': categoryIndex,
      };

  static MobilityItem fromJson(Map<String, dynamic> json) => MobilityItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        categoryIndex: json['categoryIndex'] as int? ?? 0,
      );

  MobilityItem copyWith({String? id, String? title, String? subtitle, int? categoryIndex}) =>
      MobilityItem(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        categoryIndex: categoryIndex ?? this.categoryIndex,
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

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rpe,
    this.note = '',
  });

  final String id;
  final String name;
  final String sets;
  final String reps;
  final String rpe;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'reps': reps,
        'rpe': rpe,
        'note': note,
      };

  static Exercise fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        sets: json['sets'] as String? ?? '3',
        reps: json['reps'] as String? ?? '',
        rpe: json['rpe'] as String? ?? '',
        note: json['note'] as String? ?? '',
      );

  Exercise copyWith({String? id, String? name, String? sets, String? reps, String? rpe, String? note}) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        rpe: rpe ?? this.rpe,
        note: note ?? this.note,
      );
}

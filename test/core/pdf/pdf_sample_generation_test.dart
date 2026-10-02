// Manual QA PDF samples for branding / presets / headers / layout.
//
// Writes real PDF bytes via exportWorkoutRoutineToPdf into:
//   test/artifacts/pdf_samples/
//
// Run:
//   flutter test test/core/pdf/pdf_sample_generation_test.dart
//
// Open the printed absolute paths in a PDF viewer after the run.
// Generation is always on (fast fixtures). Optional gate:
//   GENERATE_PDF_SAMPLES=0  → skip writing (still asserts non-empty bytes).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_brand_store.dart';
import 'package:powercoach_studio/core/pdf/pdf_coach_header.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
import 'package:powercoach_studio/core/pdf/pdf_plan_metadata.dart';
import 'package:powercoach_studio/core/storage/local_user_profile_store.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_prescription_scope.dart';
import 'package:powercoach_studio/features/workouts/domain/export_pdf_usecase.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_export_preset.dart';

/// 1×1 red PNG — valid MemoryImage for coach logo band.
final Uint8List _fakeLogoPng = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

PdfExportLabels _labels() {
  return PdfExportLabels(
    brandName: 'PowerCoach Studio',
    coachPrefix: 'Coach:',
    colExercise: 'Esercizio',
    colSets: 'Serie',
    colReps: 'Ripetizioni',
    colLoadRpe: 'Carico/RPE',
    colNotes: 'Note',
    mobilityFallback: 'Mobilità',
    superset: 'Superset',
    dayNumber: (d) => 'Giorno $d',
    emptyValue: '-',
    footerDisclaimer: 'Documento generato con PowerCoach Studio.',
    pageOf: (c, t) => 'Pagina $c di $t',
    generatedOn: (d) => 'Generato il $d',
    measurementDate: 'Data',
    measurementBodyFat: 'BF',
    measurementMuscleMass: 'Massa muscolare',
    measurementSquat: 'Squat',
    measurementBench: 'Panca',
    measurementDeadlift: 'Stacco',
    exportGenerating: 'Generazione…',
    measurementRecordCount: (c) => '$c record',
    denseWeekShort: (n) => 'S$n',
    denseAllWeeks: 'tutte le settimane',
    denseDitto: '"',
    denseWeekLegendEntry: (n, name) => 'S$n = $name',
    denseWeeksSpan: (first, last) => 'S$first–S$last',
    denseLegend: 'Colonne = settimane · " = uguale alla colonna precedente',
    pdfClientPlanFor: (name) => 'Scheda per: $name',
    pdfPlanPeriod: (start, end) => '$start – $end',
    pdfPlanPeriodOpen: (start) => 'Dal $start',
    formatPlanDate: (date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
  );
}

Customer _customer({
  String name = 'Alex Rossi',
  bool useCustomPdfHeader = false,
  String? pdfHeader,
}) {
  final now = DateTime(2026, 3, 1);
  return Customer(
    id: 'cust_sample',
    userId: 'coach_sample',
    name: name,
    pdfHeader: pdfHeader,
    useCustomPdfHeader: useCustomPdfHeader,
    createdAt: now,
    updatedAt: now,
  );
}

Exercise _ex({
  required String id,
  required String name,
  String sets = '3',
  String reps = '8',
  String rpe = '70kg',
  String note = '',
  String? shortName,
  String? supersetGroupId,
  List<ExerciseSet>? setDetails,
  ExercisePrescriptionScope prescriptionScope =
      ExercisePrescriptionScope.perWeek,
}) {
  return Exercise(
    id: id,
    name: name,
    sets: sets,
    reps: reps,
    rpe: rpe,
    note: note,
    shortName: shortName ?? '',
    supersetGroupId: supersetGroupId,
    setDetails: setDetails,
    prescriptionScope: prescriptionScope,
  );
}

WorkoutRoutine _routine({
  required String name,
  required List<Phase> phases,
  List<MobilitySection> mobilitySections = const [],
  List<MobilityItem> mobilityItems = const [],
  DateTime? startDate,
  DateTime? endDate,
  bool includesMobilityTab = false,
}) {
  return WorkoutRoutine(
    name: name,
    mobilitySections: mobilitySections,
    mobilityItems: mobilityItems,
    phases: phases,
    startDate: startDate ?? DateTime(2026, 3, 2),
    endDate: endDate,
    includesMobilityTab: includesMobilityTab,
  );
}

/// Deterministic 4-week / 2-day sample with mobility + a small progression.
WorkoutRoutine _sampleRoutine() {
  const mobilitySection = MobilitySection(
    id: 'mob_upper',
    name: 'Upper body',
    scheduleHint: 'Giorni dispari',
  );

  Week week(int index) {
    final loadBump = index * 2.5;
    final squatLoad = 100 + loadBump;
    final benchLoad = 70 + loadBump;
    return Week(
      id: 'w$index',
      name: 'Settimana ${index + 1}',
      days: [
        Day(
          id: 'w${index}_d0',
          name: 'Lower',
          exercises: [
            _ex(
              id: 'squat',
              name: 'Back Squat',
              shortName: 'Squat',
              sets: '4',
              reps: '5',
              rpe: '${squatLoad}kg @7',
              note: index == 0 ? 'Depth check' : '',
            ),
            _ex(
              id: 'rdl',
              name: 'Romanian Deadlift',
              shortName: 'RDL',
              sets: '3',
              reps: '8',
              rpe: '${80 + loadBump}kg',
            ),
            _ex(
              id: 'lunges',
              name: 'Walking Lunges',
              sets: '3',
              reps: '10/leg',
              rpe: 'bodyweight',
            ),
          ],
        ),
        Day(
          id: 'w${index}_d1',
          name: 'Upper',
          exercises: [
            _ex(
              id: 'bench',
              name: 'Bench Press',
              shortName: 'Bench',
              sets: '4',
              reps: '6',
              rpe: '${benchLoad}kg @8',
            ),
            _ex(
              id: 'row_a',
              name: 'Barbell Row',
              shortName: 'Row',
              sets: '3',
              reps: '8',
              rpe: '${60 + loadBump}kg',
              supersetGroupId: 'ss1',
            ),
            _ex(
              id: 'row_b',
              name: 'Face Pull',
              sets: '3',
              reps: '15',
              rpe: 'band',
              note: 'scapular control',
              supersetGroupId: 'ss1',
            ),
          ],
        ),
      ],
    );
  }

  return WorkoutRoutine(
    name: 'Strength Block Sample',
    mobilitySections: const [mobilitySection],
    mobilityItems: const [
      MobilityItem(
        id: 'm1',
        title: 'Thoracic openers',
        subtitle: '2×8 / lato',
        sectionId: 'mob_upper',
        shortTitle: 'T-spine',
      ),
      MobilityItem(
        id: 'm2',
        title: 'Shoulder CARs',
        subtitle: '1×5 / lato',
        sectionId: 'mob_upper',
      ),
    ],
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [for (var i = 0; i < 4; i++) week(i)],
      ),
    ],
    startDate: DateTime(2026, 3, 2),
    endDate: DateTime(2026, 3, 29),
    includesMobilityTab: true,
  );
}

Directory _samplesDir() {
  // Prefer repo-relative predictable path (gitignored).
  final fromPackage = Directory('test/artifacts/pdf_samples');
  return fromPackage;
}

bool _shouldWriteSamples() {
  final raw = Platform.environment['GENERATE_PDF_SAMPLES'];
  if (raw == null || raw.isEmpty) return true;
  final normalized = raw.trim().toLowerCase();
  return normalized != '0' &&
      normalized != 'false' &&
      normalized != 'no' &&
      normalized != 'off';
}

Future<File?> _writeSample({
  required String basename,
  required Uint8List bytes,
}) async {
  expect(bytes.isNotEmpty, isTrue, reason: '$basename must produce PDF bytes');
  // PDF magic header
  expect(
    String.fromCharCodes(bytes.take(4)),
    '%PDF',
    reason: '$basename should start with %PDF',
  );

  if (!_shouldWriteSamples()) {
    final flag = Platform.environment['GENERATE_PDF_SAMPLES'];
    debugPrint(
      'PDF sample write skipped (GENERATE_PDF_SAMPLES=$flag); '
      '$basename bytes=${bytes.length}',
    );
    return null;
  }

  final dir = _samplesDir();
  await dir.create(recursive: true);
  final file = File('${dir.path}/$basename');
  await file.writeAsBytes(bytes, flush: true);
  expect(await file.exists(), isTrue);
  expect(await file.length(), greaterThan(0));
  final absolute = file.absolute.path;
  // Absolute path for manual visual QA (open in a PDF viewer).
  // ignore: avoid_print
  print('PDF sample written: $absolute (${bytes.length} bytes)');
  return file;
}

Future<void> _exportAndWrite({
  required String basename,
  required WorkoutRoutine routine,
  required WorkoutPdfLayout layout,
  required bool includeMobility,
  List<int>? weekIndices,
  PdfCoachHeaderInfo? coachHeader,
  PdfPlanMetadata? planMetadata,
  String? clientOrCoachName,
}) async {
  final artifact = await exportWorkoutRoutineToPdf(
    routine,
    labels: _labels(),
    coachHeader: coachHeader,
    planMetadata: planMetadata,
    layout: layout,
    includeMobility: includeMobility,
    weekIndices: weekIndices,
    clientOrCoachName: clientOrCoachName,
  );
  expect(artifact.mimeType, 'application/pdf');
  await _writeSample(basename: basename, bytes: artifact.bytes);
}

/// 1 week · 1 day · 2 exercises — sparse single-session plan.
WorkoutRoutine _singleDayFewExercisesRoutine() {
  return _routine(
    name: 'Single Day Mini',
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          Week(
            id: 'w0',
            name: 'Settimana 1',
            days: [
              Day(
                id: 'd0',
                name: 'Full body',
                exercises: [
                  _ex(id: 'goblet', name: 'Goblet Squat', sets: '3', reps: '10'),
                  _ex(id: 'pushup', name: 'Push-up', sets: '3', reps: '12', rpe: 'bw'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 1 week · 1 day · many exercises — dense table stress.
WorkoutRoutine _manyExercisesOneDayRoutine() {
  final exercises = <Exercise>[
    for (var i = 1; i <= 14; i++)
      _ex(
        id: 'ex$i',
        name: 'Exercise $i — long name for wrap stress',
        shortName: 'Ex $i',
        sets: '${2 + (i % 3)}',
        reps: '${6 + (i % 5)}',
        rpe: '${40 + i * 2.5}kg',
        note: i.isOdd ? 'tempo 3-1-1' : '',
      ),
  ];
  return _routine(
    name: 'Dense Day Stress',
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          Week(
            id: 'w0',
            name: 'Settimana 1',
            days: [
              Day(id: 'd0', name: 'Volume day', exercises: exercises),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 1 week · 4 training days.
WorkoutRoutine _fourDaysPerWeekRoutine() {
  Day day(String id, String name, List<Exercise> exercises) =>
      Day(id: id, name: name, exercises: exercises);

  return _routine(
    name: 'Four Day Split',
    endDate: DateTime(2026, 3, 8),
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          Week(
            id: 'w0',
            name: 'Settimana 1',
            days: [
              day('d0', 'Push', [
                _ex(id: 'bp', name: 'Bench Press', sets: '4', reps: '6', rpe: '80kg'),
                _ex(id: 'ohp', name: 'OHP', sets: '3', reps: '8', rpe: '45kg'),
                _ex(id: 'fly', name: 'Cable Fly', sets: '3', reps: '12', rpe: '12kg'),
              ]),
              day('d1', 'Pull', [
                _ex(id: 'dl', name: 'Deadlift', sets: '3', reps: '5', rpe: '140kg'),
                _ex(id: 'pullup', name: 'Pull-up', sets: '3', reps: '8', rpe: 'bw'),
                _ex(id: 'curl', name: 'Curl', sets: '3', reps: '12', rpe: '20kg'),
              ]),
              day('d2', 'Legs', [
                _ex(id: 'sq', name: 'Squat', sets: '4', reps: '5', rpe: '110kg'),
                _ex(id: 'legpress', name: 'Leg Press', sets: '3', reps: '10', rpe: '180kg'),
                _ex(id: 'calf', name: 'Calf Raise', sets: '4', reps: '15', rpe: '60kg'),
              ]),
              day('d3', 'Upper accessory', [
                _ex(id: 'dbp', name: 'DB Press', sets: '3', reps: '10', rpe: '28kg'),
                _ex(id: 'lat', name: 'Lat Pulldown', sets: '3', reps: '12', rpe: '50kg'),
                _ex(id: 'latraise', name: 'Lateral Raise', sets: '3', reps: '15', rpe: '8kg'),
              ]),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 4 weeks with clear load/rep progression differences across weeks.
WorkoutRoutine _progressionWeeksRoutine() {
  Week week(int index) {
    final squat = 90 + index * 5;
    final reps = 8 - index; // 8 → 5
    return Week(
      id: 'w$index',
      name: 'Settimana ${index + 1}',
      days: [
        Day(
          id: 'w${index}_d0',
          name: 'Lower',
          exercises: [
            _ex(
              id: 'squat',
              name: 'Back Squat',
              sets: '4',
              reps: '$reps',
              rpe: '${squat}kg @${7 + (index > 1 ? 1 : 0)}',
              note: index == 3 ? 'test week' : '',
            ),
            _ex(
              id: 'rdl',
              name: 'RDL',
              sets: '3',
              reps: '${10 - index}',
              rpe: '${70 + index * 5}kg',
            ),
          ],
        ),
        Day(
          id: 'w${index}_d1',
          name: 'Upper',
          exercises: [
            _ex(
              id: 'bench',
              name: 'Bench Press',
              sets: '4',
              reps: '${reps + 1}',
              rpe: '${60 + index * 2.5}kg',
            ),
            _ex(
              id: 'row',
              name: 'Chest-supported Row',
              sets: '3',
              reps: '10',
              rpe: '${50 + index * 2.5}kg',
              prescriptionScope: ExercisePrescriptionScope.allWeeks,
            ),
          ],
        ),
      ],
    );
  }

  return _routine(
    name: 'Progression Block',
    endDate: DateTime(2026, 3, 29),
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [for (var i = 0; i < 4; i++) week(i)],
      ),
    ],
  );
}

/// Two named phases (accumulation → intensification), flattened for export.
WorkoutRoutine _multiPhaseRoutine() {
  Week phaseWeek({
    required String id,
    required String name,
    required double squatLoad,
    required String squatReps,
  }) {
    return Week(
      id: id,
      name: name,
      days: [
        Day(
          id: '${id}_d0',
          name: 'Strength',
          exercises: [
            _ex(
              id: 'squat',
              name: 'Back Squat',
              sets: '4',
              reps: squatReps,
              rpe: '${squatLoad}kg',
            ),
            _ex(
              id: 'bench',
              name: 'Bench Press',
              sets: '4',
              reps: squatReps,
              rpe: '${squatLoad * 0.7}kg',
            ),
          ],
        ),
      ],
    );
  }

  return _routine(
    name: 'Multi-Phase Block',
    endDate: DateTime(2026, 4, 12),
    phases: [
      Phase(
        id: 'phase_accum',
        name: 'Accumulation',
        objective: 'Volume base',
        weeks: [
          phaseWeek(id: 'a0', name: 'Acc W1', squatLoad: 90, squatReps: '8'),
          phaseWeek(id: 'a1', name: 'Acc W2', squatLoad: 95, squatReps: '8'),
        ],
      ),
      Phase(
        id: 'phase_int',
        name: 'Intensification',
        objective: 'Load up',
        weeks: [
          phaseWeek(id: 'i0', name: 'Int W1', squatLoad: 105, squatReps: '5'),
          phaseWeek(id: 'i1', name: 'Int W2', squatLoad: 110, squatReps: '3'),
        ],
      ),
    ],
  );
}

/// Mobility-heavy: rich mobility sections + thin training day.
WorkoutRoutine _mobilityHeavyRoutine() {
  const sections = [
    MobilitySection(id: 'mob_prep', name: 'Prep', scheduleHint: 'Ogni sessione'),
    MobilitySection(id: 'mob_lower', name: 'Lower body', scheduleHint: 'Giorni dispari'),
    MobilitySection(id: 'mob_upper', name: 'Upper body', scheduleHint: 'Giorni pari'),
  ];
  const items = [
    MobilityItem(
      id: 'm1',
      title: '90/90 hip switch',
      subtitle: '2×6 / lato',
      sectionId: 'mob_prep',
      shortTitle: '90/90',
    ),
    MobilityItem(
      id: 'm2',
      title: 'Cat-cow',
      subtitle: '2×10',
      sectionId: 'mob_prep',
    ),
    MobilityItem(
      id: 'm3',
      title: 'Couch stretch',
      subtitle: '2×45s / lato',
      sectionId: 'mob_lower',
    ),
    MobilityItem(
      id: 'm4',
      title: 'Ankle rocks',
      subtitle: '2×12 / lato',
      sectionId: 'mob_lower',
      shortTitle: 'Ankle',
    ),
    MobilityItem(
      id: 'm5',
      title: 'Thoracic openers',
      subtitle: '2×8 / lato',
      sectionId: 'mob_upper',
      shortTitle: 'T-spine',
    ),
    MobilityItem(
      id: 'm6',
      title: 'Shoulder CARs',
      subtitle: '1×5 / lato',
      sectionId: 'mob_upper',
    ),
    MobilityItem(
      id: 'm7',
      title: 'Band dislocates',
      subtitle: '2×12',
      sectionId: 'mob_upper',
    ),
  ];

  return _routine(
    name: 'Mobility Heavy Plan',
    includesMobilityTab: true,
    mobilitySections: sections,
    mobilityItems: items,
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          Week(
            id: 'w0',
            name: 'Settimana 1',
            days: [
              Day(
                id: 'd0',
                name: 'Light strength',
                exercises: [
                  _ex(id: 'goblet', name: 'Goblet Squat', sets: '2', reps: '8', rpe: '16kg'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Minimal edge: 1 week · 1 day · 1 exercise.
WorkoutRoutine _minimalEdgeRoutine() {
  return _routine(
    name: 'Minimal Edge',
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          Week(
            id: 'w0',
            name: 'Settimana 1',
            days: [
              Day(
                id: 'd0',
                name: 'Solo',
                exercises: [
                  _ex(id: 'plank', name: 'Plank', sets: '3', reps: '30s', rpe: 'bw'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Straight sets + supersets + multi-setDetails (top set / backoff).
WorkoutRoutine _mixedSetTypesRoutine() {
  return _routine(
    name: 'Mixed Set Types',
    endDate: DateTime(2026, 3, 15),
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          for (var wi = 0; wi < 2; wi++)
            Week(
              id: 'w$wi',
              name: 'Settimana ${wi + 1}',
              days: [
                Day(
                  id: 'w${wi}_d0',
                  name: 'Mixed',
                  exercises: [
                    _ex(
                      id: 'squat',
                      name: 'Back Squat',
                      sets: '1',
                      reps: '3',
                      rpe: '${100 + wi * 5}kg',
                      note: 'top + backoff',
                      setDetails: [
                        ExerciseSet(
                          sets: '1',
                          reps: '3',
                          rpe: '${100 + wi * 5}kg @8',
                          note: 'top',
                        ),
                        ExerciseSet(
                          sets: '3',
                          reps: '5',
                          rpe: '${85 + wi * 5}kg',
                          note: 'backoff',
                        ),
                      ],
                    ),
                    _ex(
                      id: 'bench',
                      name: 'Bench Press',
                      sets: '4',
                      reps: '6',
                      rpe: '${70 + wi * 2.5}kg',
                    ),
                    _ex(
                      id: 'row_a',
                      name: 'Barbell Row',
                      sets: '3',
                      reps: '8',
                      rpe: '${60 + wi * 2.5}kg',
                      supersetGroupId: 'ss_pull',
                    ),
                    _ex(
                      id: 'row_b',
                      name: 'Face Pull',
                      sets: '3',
                      reps: '15',
                      rpe: 'band',
                      note: 'scap control',
                      supersetGroupId: 'ss_pull',
                    ),
                    _ex(
                      id: 'curl_a',
                      name: 'DB Curl',
                      sets: '3',
                      reps: '12',
                      rpe: '12kg',
                      supersetGroupId: 'ss_arm',
                    ),
                    _ex(
                      id: 'curl_b',
                      name: 'Tricep Pushdown',
                      sets: '3',
                      reps: '12',
                      rpe: '25kg',
                      supersetGroupId: 'ss_arm',
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

void main() {
  final labels = _labels();
  final customer = _customer();
  final profile = const LocalUserProfileData(
    displayName: 'Edoardo Coach',
    website: 'studio.example.com',
  );

  test('01 Completo / canonical with default branding', () async {
    final full = resolveWorkoutExportPreset(
      WorkoutExportPreset.full,
      hasMobilityItems: true,
    );
    final header = buildPdfCoachHeader(
      labels: labels,
      customer: customer,
      profile: profile,
      authEmail: 'coach@example.com',
      brand: const PdfBrandData(),
    );
    final plan = buildPdfPlanMetadata(
      routine: _sampleRoutine(),
      labels: labels,
      clientName: customer.name,
    );
    await _exportAndWrite(
      basename: '01_completo_canonical_default_brand.pdf',
      routine: _sampleRoutine(),
      layout: full.layout,
      includeMobility: full.includeMobility,
      weekIndices: full.weekIndices,
      coachHeader: header,
      planMetadata: plan,
      clientOrCoachName: customer.name,
    );
  });

  test('02 Palestra / dense layout', () async {
    final gym = resolveWorkoutExportPreset(
      WorkoutExportPreset.gym,
      hasMobilityItems: true,
    );
    final header = buildPdfCoachHeader(
      labels: labels,
      customer: customer,
      profile: profile,
      authEmail: 'coach@example.com',
      brand: const PdfBrandData(studioName: 'PowerCoach Studio'),
    );
    final plan = buildPdfPlanMetadata(
      routine: _sampleRoutine(),
      labels: labels,
      clientName: customer.name,
    );
    await _exportAndWrite(
      basename: '02_palestra_dense.pdf',
      routine: _sampleRoutine(),
      layout: gym.layout,
      includeMobility: gym.includeMobility,
      weekIndices: gym.weekIndices,
      coachHeader: header,
      planMetadata: plan,
      clientOrCoachName: customer.name,
    );
  });

  test('03 Solo settimana 1 / week filter', () async {
    final week1 = resolveWorkoutExportPreset(
      WorkoutExportPreset.week1Only,
      hasMobilityItems: true,
    );
    final header = buildPdfCoachHeader(
      labels: labels,
      customer: customer,
      profile: profile,
      authEmail: 'coach@example.com',
    );
    final plan = buildPdfPlanMetadata(
      routine: _sampleRoutine(),
      labels: labels,
      clientName: customer.name,
    );
    await _exportAndWrite(
      basename: '03_solo_settimana_1.pdf',
      routine: _sampleRoutine(),
      layout: week1.layout,
      includeMobility: week1.includeMobility,
      weekIndices: week1.weekIndices,
      coachHeader: header,
      planMetadata: plan,
      clientOrCoachName: customer.name,
    );
  });

  test('04 Custom studio brand (accent + disclaimer + hide PowerCoach)',
      () async {
    final gym = resolveWorkoutExportPreset(
      WorkoutExportPreset.gym,
      hasMobilityItems: true,
    );
    final brand = const PdfBrandData(
      studioName: 'Iron Lab Milano',
      accentColorArgb: 0xFFC45C26,
      disclaimer: 'Uso privato — Iron Lab Milano. Non redistribuire.',
      hidePowerCoachBranding: true,
    );
    final header = buildPdfCoachHeader(
      labels: labels,
      customer: customer,
      profile: profile,
      authEmail: 'iron@lab.example',
      brand: brand,
      logoBytes: _fakeLogoPng,
    );
    expect(header.hideProductBranding, isTrue);
    expect(header.hasLogo, isTrue);
    expect(header.leftLine, 'Iron Lab Milano');
    final plan = buildPdfPlanMetadata(
      routine: _sampleRoutine(),
      labels: labels,
      clientName: customer.name,
    );
    await _exportAndWrite(
      basename: '04_custom_studio_brand.pdf',
      routine: _sampleRoutine(),
      layout: gym.layout,
      includeMobility: gym.includeMobility,
      weekIndices: gym.weekIndices,
      coachHeader: header,
      planMetadata: plan,
      clientOrCoachName: customer.name,
    );
  });

  test('05 Customer custom pdfHeader override', () async {
    final full = resolveWorkoutExportPreset(
      WorkoutExportPreset.full,
      hasMobilityItems: true,
    );
    final customCustomer = _customer(
      useCustomPdfHeader: true,
      pdfHeader: 'Header personalizzato cliente — Gym Nord',
    );
    final header = buildPdfCoachHeader(
      labels: labels,
      customer: customCustomer,
      profile: profile,
      authEmail: 'coach@example.com',
      brand: const PdfBrandData(studioName: 'Should Not Appear'),
    );
    expect(header.leftLine, 'Header personalizzato cliente — Gym Nord');
    final plan = buildPdfPlanMetadata(
      routine: _sampleRoutine(),
      labels: labels,
      clientName: customCustomer.name,
    );
    await _exportAndWrite(
      basename: '05_customer_pdf_header_override.pdf',
      routine: _sampleRoutine(),
      layout: full.layout,
      includeMobility: full.includeMobility,
      weekIndices: full.weekIndices,
      coachHeader: header,
      planMetadata: plan,
      clientOrCoachName: customCustomer.name,
    );
  });

  group('structure variants for manual layout QA', () {
    late PdfCoachHeaderInfo header;

    setUp(() {
      header = buildPdfCoachHeader(
        labels: labels,
        customer: customer,
        profile: profile,
        authEmail: 'coach@example.com',
      );
    });

    Future<void> writeStructure({
      required String basename,
      required WorkoutRoutine routine,
      required WorkoutPdfLayout layout,
      required bool includeMobility,
      List<int>? weekIndices,
    }) async {
      final plan = buildPdfPlanMetadata(
        routine: routine,
        labels: labels,
        clientName: customer.name,
      );
      await _exportAndWrite(
        basename: basename,
        routine: routine,
        layout: layout,
        includeMobility: includeMobility,
        weekIndices: weekIndices,
        coachHeader: header,
        planMetadata: plan,
        clientOrCoachName: customer.name,
      );
    }

    test('06 Single day / few exercises (canonical)', () async {
      await writeStructure(
        basename: '06_single_day_few_exercises.pdf',
        routine: _singleDayFewExercisesRoutine(),
        layout: WorkoutPdfLayout.canonical,
        includeMobility: false,
      );
    });

    test('07 Many exercises one day dense stress', () async {
      await writeStructure(
        basename: '07_many_exercises_one_day_dense.pdf',
        routine: _manyExercisesOneDayRoutine(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );
    });

    test('08 Four training days per week (dense)', () async {
      await writeStructure(
        basename: '08_four_days_per_week_dense.pdf',
        routine: _fourDaysPerWeekRoutine(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );
    });

    test('09 Multi-week progression differences (dense)', () async {
      await writeStructure(
        basename: '09_multi_week_progression_dense.pdf',
        routine: _progressionWeeksRoutine(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );
    });

    test('10 Multiple phases flattened (canonical)', () async {
      final routine = _multiPhaseRoutine();
      expect(routine.phases.length, 2);
      expect(routine.weeks.length, 4);
      await writeStructure(
        basename: '10_multi_phase_canonical.pdf',
        routine: routine,
        layout: WorkoutPdfLayout.canonical,
        includeMobility: false,
      );
    });

    test('11 Mobility-heavy with light training (completo)', () async {
      final routine = _mobilityHeavyRoutine();
      final full = resolveWorkoutExportPreset(
        WorkoutExportPreset.full,
        hasMobilityItems: routine.mobilityItems.isNotEmpty,
      );
      await writeStructure(
        basename: '11_mobility_heavy_completo.pdf',
        routine: routine,
        layout: full.layout,
        includeMobility: full.includeMobility,
      );
    });

    test('12 Minimal edge 1w1d1e (dense)', () async {
      await writeStructure(
        basename: '12_minimal_edge_1w1d1e_dense.pdf',
        routine: _minimalEdgeRoutine(),
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
      );
    });

    test('13 Mixed set types straight + supersets + setDetails', () async {
      await writeStructure(
        basename: '13_mixed_set_types_canonical.pdf',
        routine: _mixedSetTypesRoutine(),
        layout: WorkoutPdfLayout.canonical,
        includeMobility: false,
      );
    });
  });
}

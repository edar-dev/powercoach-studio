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
  required WorkoutPdfLayout layout,
  required bool includeMobility,
  List<int>? weekIndices,
  PdfCoachHeaderInfo? coachHeader,
  PdfPlanMetadata? planMetadata,
  String? clientOrCoachName,
}) async {
  final routine = _sampleRoutine();
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
      layout: full.layout,
      includeMobility: full.includeMobility,
      weekIndices: full.weekIndices,
      coachHeader: header,
      planMetadata: plan,
      clientOrCoachName: customCustomer.name,
    );
  });
}

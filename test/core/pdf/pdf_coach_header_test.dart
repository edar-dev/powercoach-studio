import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_coach_header.dart';
import 'package:powercoach_studio/core/pdf/pdf_export_labels.dart';
import 'package:powercoach_studio/core/storage/local_user_profile_store.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';

PdfExportLabels _labels() {
  return PdfExportLabels(
    brandName: 'PowerCoach Studio',
    coachPrefix: 'Coach:',
    colExercise: 'Exercise',
    colSets: 'Sets',
    colReps: 'Reps',
    colLoadRpe: 'Load/RPE',
    colNotes: 'Notes',
    mobilityFallback: 'Mobility',
    superset: 'Superset',
    dayNumber: (d) => 'Day $d',
    emptyValue: '-',
    footerDisclaimer: 'Disclaimer',
    pageOf: (c, t) => '$c/$t',
    generatedOn: (d) => d,
    measurementDate: 'Date',
    measurementBodyFat: 'BF',
    measurementMuscleMass: 'Muscle',
    measurementWaist: 'Waist',
    measurementSquat: 'Squat',
    measurementBench: 'Bench',
    exportGenerating: '...',
    measurementRecordCount: (c) => '$c records',
    denseWeekShort: (n) => 'S$n',
    denseAllWeeks: 'all',
    denseDitto: '〃',
    denseWeekLegendEntry: (n, name) => 'S$n = $name',
  );
}

Customer _customer({
  bool useCustom = false,
  String? header,
}) {
  final now = DateTime(2025, 1, 1);
  return Customer(
    id: 'c1',
    userId: 'u1',
    name: 'Alex',
    pdfHeader: header,
    useCustomPdfHeader: useCustom,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('uses custom pdf header when enabled', () {
    final info = buildPdfCoachHeader(
      labels: _labels(),
      customer: _customer(useCustom: true, header: 'My Gym PT'),
      profile: const LocalUserProfileData(displayName: 'John'),
      authEmail: 'coach@test.com',
    );
    expect(info.leftLine, 'My Gym PT');
    expect(info.centerLine, 'Coach: John');
    expect(info.rightLine, 'coach@test.com');
  });

  test('falls back to brand when no custom header', () {
    final info = buildPdfCoachHeader(
      labels: _labels(),
      profile: const LocalUserProfileData(),
      authEmail: 'a@b.com',
    );
    expect(info.leftLine, 'PowerCoach Studio');
    expect(info.rightLine, 'a@b.com');
  });
}

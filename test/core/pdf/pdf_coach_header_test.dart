import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_brand_store.dart';
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
    measurementSquat: 'Squat',
    measurementBench: 'Bench',
    measurementDeadlift: 'Deadlift',
    exportGenerating: '...',
    measurementRecordCount: (c) => '$c records',
    denseWeekShort: (n) => 'S$n',
    denseAllWeeks: 'all',
    denseDitto: '"',
    denseWeekLegendEntry: (n, name) => 'S$n = $name',
    denseWeeksSpan: (first, last) => 'S$first-S$last',
    denseLegend: 'legend',
    pdfClientPlanFor: (name) => 'Plan for: $name',
    pdfPlanPeriod: (start, end) => '$start – $end',
    pdfPlanPeriodOpen: (start) => 'From $start',
    formatPlanDate: (date) =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
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
      brand: const PdfBrandData(studioName: 'Studio Brand'),
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

  test('prefers studioName over bio and product brand', () {
    final info = buildPdfCoachHeader(
      labels: _labels(),
      profile: const LocalUserProfileData(bio: 'Coach bio'),
      brand: const PdfBrandData(studioName: 'Studio Force'),
    );
    expect(info.leftLine, 'Studio Force');
  });

  test('white-label hides product brand when no studio/bio', () {
    final info = buildPdfCoachHeader(
      labels: _labels(),
      brand: const PdfBrandData(hidePowerCoachBranding: true),
    );
    expect(info.leftLine, isEmpty);
    expect(info.hideProductBranding, isTrue);
  });

  test('attaches logo bytes, accent, and disclaimer from brand', () {
    final logo = Uint8List.fromList([9, 8, 7]);
    final info = buildPdfCoachHeader(
      labels: _labels(),
      brand: const PdfBrandData(
        studioName: 'S',
        accentColorArgb: 0xFF112233,
        disclaimer: 'Private use only',
        hidePowerCoachBranding: true,
      ),
      logoBytes: logo,
    );
    expect(info.logoBytes, logo);
    expect(info.hasLogo, isTrue);
    expect(info.accentColorArgb, 0xFF112233);
    expect(info.disclaimer, 'Private use only');
    expect(info.hideProductBranding, isTrue);
  });

  test('customer override still wins over studioName', () {
    final info = buildPdfCoachHeader(
      labels: _labels(),
      customer: _customer(useCustom: true, header: 'Client Gym'),
      brand: const PdfBrandData(studioName: 'Studio Force'),
    );
    expect(info.leftLine, 'Client Gym');
  });
}

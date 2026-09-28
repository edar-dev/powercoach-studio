import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_labels_l10n.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_service.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_metrics.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  final exportedAt = DateTime(2026, 7, 8);

  CustomerProgressSnapshot sampleProgress() {
    return CustomerProgressSnapshot(
      adherencePercent: 0.85,
      completedSessions30d: 17,
      skippedSessions30d: 3,
      lastSessionDate: DateTime(2026, 7, 1),
      last4Weeks: const [
        WeeklyAdherenceDot(completed: true),
        WeeklyAdherenceDot(completed: false),
        WeeklyAdherenceDot(),
        WeeklyAdherenceDot(completed: true),
      ],
      hasAnyData: true,
    );
  }

  test('buildCustomerProgressCsv includes summary, weekly, and measures', () {
    final csv = buildCustomerProgressCsv(
      CustomerProgressExportInput(
        customerName: 'Marco Rossi',
        progress: sampleProgress(),
        measurements: [
          CustomerMeasurement(
            id: 'm1',
            customerId: 'c1',
            userId: 'coach',
            measurementDate: DateTime(2026, 7, 5),
            bodyFatPercent: 15.2,
            muscleMassKg: 62.5,
            createdAt: exportedAt,
            updatedAt: exportedAt,
          ),
        ],
        exportedAt: exportedAt,
      ),
    );

    expect(csv, contains('# PowerCoach Studio — Marco Rossi'));
    expect(csv, contains('# Generated: 2026-07-08'));
    expect(csv, isNot(contains('--- data ---')));
    expect(csv, contains('summary,0.850,17,3,2026-07-01'));
    expect(csv, contains('weekly,0,completed'));
    expect(csv, contains('weekly,1,missed'));
    expect(csv, contains('weekly,2,'));
    expect(csv, isNot(contains('pr,')));
    expect(csv, contains('measures,body_fat_percent,15.2,%,2026-07-05'));
    expect(csv, contains('measures,muscle_mass_kg,62.5,kg,2026-07-05'));
  });

  test('exportCustomerProgressToCsv sanitizes filename', () async {
    final artifact = await exportCustomerProgressToCsv(
      CustomerProgressExportInput(
        customerName: 'Marco Rossi!',
        progress: sampleProgress(),
        measurements: const [],
        exportedAt: exportedAt,
      ),
    );

    expect(artifact.filename, 'Marco Rossi_progress_2026-07-08.csv');
    expect(artifact.mimeType, 'text/csv');
    expect(String.fromCharCodes(artifact.bytes), contains('summary,0.850'));
  });

  test('buildCustomerProgressCsv prepends EN narrative when labels provided', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final csv = buildCustomerProgressCsv(
      CustomerProgressExportInput(
        customerName: 'Marco Rossi',
        progress: sampleProgress(),
        measurements: const [],
        exportedAt: exportedAt,
        labels: l10n.toCustomerProgressExportLabels(),
      ),
    );

    expect(csv, contains('# PowerCoach Studio — Marco Rossi'));
    expect(csv, contains('# Generated: 2026-07-08'));
    expect(csv, contains('--- data ---'));
    expect(csv, contains('adherence was 85%'));
    expect(csv, contains('17 completed'));
    expect(csv, contains('3 skipped'));
    expect(csv, contains('Last session: 2026-07-01'));
    expect(csv, isNot(contains('Recent PR:')));
    expect(csv, contains('weekly,0,completed'));
    expect(csv, contains('weekly,1,missed'));
    expect(csv, contains('weekly,2,no data'));
    expect(csv, contains('summary,0.850,17,3,2026-07-01'));
  });

  test('buildCustomerProgressCsv prepends IT narrative when labels provided', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    final csv = buildCustomerProgressCsv(
      CustomerProgressExportInput(
        customerName: 'Marco Rossi',
        progress: sampleProgress(),
        measurements: const [],
        exportedAt: exportedAt,
        labels: l10n.toCustomerProgressExportLabels(),
      ),
    );

    expect(csv, contains('# PowerCoach Studio — Marco Rossi'));
    expect(csv, contains('# Generato: 2026-07-08'));
    expect(csv, contains('--- dati ---'));
    expect(csv, contains("aderenza è stata del 85%"));
    expect(csv, contains('17 completate'));
    expect(csv, contains('3 saltate'));
    expect(csv, contains('Ultima sessione: 2026-07-01'));
    expect(csv, isNot(contains('PR recente:')));
    expect(csv, contains('weekly,0,completata'));
    expect(csv, contains('weekly,1,mancata'));
    expect(csv, contains('weekly,2,nessun dato'));
  });

  test('narrative omits missing adherence sentences', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final csv = buildCustomerProgressCsv(
      CustomerProgressExportInput(
        customerName: 'Alex',
        progress: const CustomerProgressSnapshot(
          adherencePercent: null,
          completedSessions30d: 0,
          skippedSessions30d: 0,
          lastSessionDate: null,
          last4Weeks: [],
          hasAnyData: false,
        ),
        measurements: const [],
        exportedAt: exportedAt,
        labels: l10n.toCustomerProgressExportLabels(),
      ),
    );

    expect(csv, isNot(contains('adherence was')));
    expect(csv, isNot(contains('Last session:')));
    expect(csv, isNot(contains('Recent PR:')));
    expect(csv, contains('--- data ---'));
  });
}

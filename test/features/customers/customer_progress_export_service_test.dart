import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_exercise_record.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_export_service.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_metrics.dart';

void main() {
  final exportedAt = DateTime(2026, 7, 8);

  CustomerProgressSnapshot sampleProgress() {
    return CustomerProgressSnapshot(
      adherencePercent: 0.85,
      completedSessions30d: 17,
      skippedSessions30d: 3,
      lastSessionDate: DateTime(2026, 7, 1),
      recentPrs: [
        CustomerPrHighlight(
          exerciseName: 'Panca piana',
          value: 80,
          unit: 'kg',
          recordedAt: DateTime(2026, 7, 1),
        ),
      ],
      last4Weeks: const [
        WeeklyAdherenceDot(completed: true),
        WeeklyAdherenceDot(completed: false),
        WeeklyAdherenceDot(),
        WeeklyAdherenceDot(completed: true),
      ],
      hasAnyData: true,
    );
  }

  test('buildCustomerProgressCsv includes summary, weekly, pr, and measures', () {
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
        exerciseRecords: [
          CustomerExerciseRecord(
            id: 'r1',
            customerId: 'c1',
            customExerciseId: 'ex-stacco',
            exerciseName: 'Stacco',
            value: 120,
            unit: 'kg',
            recordedAt: DateTime(2026, 6, 20),
            createdAt: exportedAt,
            updatedAt: exportedAt,
          ),
        ],
        exportedAt: exportedAt,
      ),
    );

    expect(csv, contains('# PowerCoach Studio — Marco Rossi'));
    expect(csv, contains('# Generated: 2026-07-08'));
    expect(csv, contains('summary,0.850,17,3,2026-07-01'));
    expect(csv, contains('weekly,0,completed'));
    expect(csv, contains('weekly,1,missed'));
    expect(csv, contains('weekly,2,'));
    expect(csv, contains('pr,Stacco,120.0,kg,2026-06-20'));
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

  test('buildCustomerProgressCsv falls back to snapshot PRs when records empty', () {
    final csv = buildCustomerProgressCsv(
      CustomerProgressExportInput(
        customerName: 'Alex',
        progress: sampleProgress(),
        measurements: const [],
        exportedAt: exportedAt,
      ),
    );

    expect(csv, contains('pr,Panca piana,80.0,kg,2026-07-01'));
  });
}

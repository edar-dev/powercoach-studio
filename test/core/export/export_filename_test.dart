import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/export/export_filename.dart';

void main() {
  group('sanitizeExportSlug', () {
    test('strips unsafe characters and collapses spaces', () {
      expect(
        sanitizeExportSlug('Mario Rossi / Upper'),
        'Mario_Rossi_Upper',
      );
    });

    test('uses fallback when empty', () {
      expect(sanitizeExportSlug('   ***   '), 'export');
    });
  });

  group('buildSmartPdfFilename', () {
    test('includes client, document, and date', () {
      final name = buildSmartPdfFilename(
        documentSlug: 'Push Pull Legs',
        clientOrCoachName: 'Mario Rossi',
        generatedOn: DateTime(2026, 3, 15),
        fallbackDocumentSlug: 'workout_plan',
      );
      expect(name, 'Mario_Rossi_Push_Pull_Legs_2026-03-15.pdf');
    });

    test('omits client segment when absent', () {
      final name = buildSmartPdfFilename(
        documentSlug: 'Plan A',
        generatedOn: DateTime(2026, 1, 2),
      );
      expect(name, 'Plan_A_2026-01-02.pdf');
    });
  });
}

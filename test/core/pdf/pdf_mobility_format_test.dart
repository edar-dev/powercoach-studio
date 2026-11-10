import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_mobility_format.dart';

void main() {
  test('formatMobilityPdfLine omits colon when subtitle is empty', () {
    expect(formatMobilityPdfLine('Gatto-Mucca', ''), 'Gatto-Mucca');
  });

  test('formatMobilityPdfLine joins title and subtitle when present', () {
    expect(formatMobilityPdfLine('Dead bug', '3x6/6'), 'Dead bug: 3x6/6');
  });

  test('formatMobilityPdfLine prefers structured prescription summary', () {
    // sanitizePdfText maps × → x for Helvetica; separator em dash is kept.
    expect(
      formatMobilityPdfLine(
        'WGS',
        'hold end range',
        prescriptionSummary: '3×30s @8',
      ),
      'WGS: 3x30s @8 - hold end range',
    );
  });

  test('formatMobilityPdfLine with prescription and empty note', () {
    expect(
      formatMobilityPdfLine('Cat-cow', '', prescriptionSummary: '2×10'),
      'Cat-cow: 2x10',
    );
  });
}

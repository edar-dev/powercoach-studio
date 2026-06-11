import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_mobility_format.dart';

void main() {
  test('formatMobilityPdfLine omits colon when subtitle is empty', () {
    expect(formatMobilityPdfLine('Gatto-Mucca', ''), 'Gatto-Mucca');
  });

  test('formatMobilityPdfLine joins title and subtitle when present', () {
    expect(formatMobilityPdfLine('Dead bug', '3x6/6'), 'Dead bug: 3x6/6');
  });
}

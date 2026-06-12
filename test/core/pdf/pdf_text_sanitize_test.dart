import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_text_sanitize.dart';

void main() {
  test('sanitizePdfText replaces dashes and punctuation outside WinAnsi', () {
    expect(
      sanitizePdfText('PDF Stress \u2014 Overflow'),
      'PDF Stress - Overflow',
    );
    expect(
      sanitizePdfText('1/6/2026 \u2013 31/8/2026'),
      '1/6/2026 - 31/8/2026',
    );
    expect(
      sanitizePdfText('S1 = Week 1 \u00B7 S2 = Week 2'),
      'S1 = Week 1 - S2 = Week 2',
    );
  });

  test('sanitizePdfText keeps Latin accents for Italian copy', () {
    expect(sanitizePdfText('Mobilità'), 'Mobilità');
    expect(sanitizePdfText('Piano per: Edoardo'), 'Piano per: Edoardo');
  });
}

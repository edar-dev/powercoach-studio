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

  test('sanitizePdfText replaces Helvetica-unsafe name↔cue separators', () {
    // U+22C5 DOT OPERATOR — common tofu between shortName and cue.
    expect(
      sanitizePdfText('Good morning \u22C5 Safety bar'),
      'Good morning - Safety bar',
    );
    expect(
      sanitizePdfText('Hack squat \u2219 Con pausa'),
      'Hack squat - Con pausa',
    );
    expect(
      sanitizePdfText('Pulley basso \u25A1 Impugnatura stretta'),
      'Pulley basso - Impugnatura stretta',
    );
    expect(
      sanitizePdfText('Dip \u2022 Zavorrate'),
      'Dip - Zavorrate',
    );
  });

  test('sanitizePdfText strips leftover non-WinAnsi glyphs', () {
    expect(
      sanitizePdfText('Core bracing \u2605 Plank'),
      'Core bracing Plank',
    );
  });
}

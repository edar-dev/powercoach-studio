import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_coaching_note.dart';

void main() {
  test('abbreviatePdfCoachingNote shortens long sumo note', () {
    expect(
      abbreviatePdfCoachingNote('Fermo incastro 2" + Fermo ginocchio'),
      'Fermo incastro 2" + ginocchio',
    );
  });

  test('abbreviatePdfCoachingNote fixes common fermo typo', () {
    expect(
      abbreviatePdfCoachingNote('Femo incastro 2" + Fermo ginocchio'),
      'Fermo incastro 2" + ginocchio',
    );
  });

  test('abbreviatePdfCoachingNote fixes standalone Femo typo', () {
    expect(abbreviatePdfCoachingNote('Femo 1-2"'), 'Fermo 1-2"');
    expect(abbreviatePdfCoachingNote('Femo 2" in basso'), 'Fermo 2" in basso');
  });
}

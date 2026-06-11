import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_coaching_note.dart';

void main() {
  test('abbreviatePdfCoachingNote shortens long sumo note', () {
    expect(
      abbreviatePdfCoachingNote('Fermo incastro 2" + Fermo ginocchio'),
      'Fermo incastro 2" + ginocchio',
    );
  });
}

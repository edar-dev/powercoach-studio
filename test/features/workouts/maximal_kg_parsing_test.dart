import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_kg_parsing.dart';

void main() {
  group('parseMaximalKgInput', () {
    test('parses integers and decimals with comma or dot', () {
      expect(parseMaximalKgInput('80'), 80);
      expect(parseMaximalKgInput('80.5'), 80.5);
      expect(parseMaximalKgInput('80,5'), 80.5);
      expect(parseMaximalKgInput('  100  '), 100);
    });

    test('rejects empty and invalid', () {
      expect(parseMaximalKgInput(null), isNull);
      expect(parseMaximalKgInput(''), isNull);
      expect(parseMaximalKgInput('  '), isNull);
      expect(parseMaximalKgInput('abc'), isNull);
    });
  });

  group('formatMaximalKgInput', () {
    test('drops trailing .0 for whole numbers', () {
      expect(formatMaximalKgInput(80), '80');
      expect(formatMaximalKgInput(80.0), '80');
      expect(formatMaximalKgInput(80.5), '80.5');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_load_math.dart';

void main() {
  group('applyPercentOfMaximal', () {
    test('computes raw percent of massimale', () {
      expect(
        applyPercentOfMaximal(maximalKg: 100, percent: 80),
        80,
      );
      expect(
        applyPercentOfMaximal(maximalKg: 100, percent: 50),
        50,
      );
      expect(
        applyPercentOfMaximal(maximalKg: 142.5, percent: 75),
        closeTo(106.875, 1e-9),
      );
    });
  });

  group('roundToIncrement', () {
    test('rounds to 2.5 kg', () {
      expect(roundToIncrement(80, 2.5), 80);
      expect(roundToIncrement(81, 2.5), 80);
      expect(roundToIncrement(81.25, 2.5), 82.5);
      expect(roundToIncrement(106.875, 2.5), 107.5);
    });

    test('rounds to 1 kg', () {
      expect(roundToIncrement(80.4, 1), 80);
      // Dart num.round() is half-away-from-zero → 80.5 → 81.
      expect(roundToIncrement(80.5, 1), 81);
      expect(roundToIncrement(80.6, 1), 81);
    });

    test('rounds to 0.5 kg', () {
      expect(roundToIncrement(80.24, 0.5), 80);
      expect(roundToIncrement(80.25, 0.5), 80.5);
      expect(roundToIncrement(80.74, 0.5), 80.5);
      expect(roundToIncrement(80.75, 0.5), 81);
    });

    test('returns raw when increment is not positive', () {
      expect(roundToIncrement(81.3, 0), 81.3);
      expect(roundToIncrement(81.3, -1), 81.3);
    });
  });

  group('applyPercentRounded', () {
    test('chips and slider share the same apply path', () {
      const maximal = 100.0;
      for (final percent in [50, 60, 65, 70, 75, 80, 85, 90, 95]) {
        final fromApply = applyPercentRounded(
          maximalKg: maximal,
          percent: percent,
          incrementKg: 2.5,
        );
        final fromParts = roundToIncrement(
          applyPercentOfMaximal(maximalKg: maximal, percent: percent),
          2.5,
        );
        expect(fromApply, fromParts);
      }
    });

    test('80% of 100 kg with 2.5 increment is 80', () {
      expect(
        applyPercentRounded(maximalKg: 100, percent: 80, incrementKg: 2.5),
        80,
      );
    });

    test('75% of 142.5 kg with 2.5 increment is 107.5', () {
      expect(
        applyPercentRounded(maximalKg: 142.5, percent: 75, incrementKg: 2.5),
        107.5,
      );
    });
  });

  group('formatMaximalDisplayKg', () {
    test('formats whole and half kilograms without unit', () {
      expect(formatMaximalDisplayKg(80), '80');
      expect(formatMaximalDisplayKg(107.5), '107.5');
      expect(formatMaximalDisplayKg(80.0), '80');
    });
  });

  group('formatMaximalLoadKg', () {
    test('formats whole and half kilograms with kg suffix', () {
      expect(formatMaximalLoadKg(80), '80kg');
      expect(formatMaximalLoadKg(107.5), '107.5kg');
      expect(formatMaximalLoadKg(80.0), '80kg');
    });
  });

  group('kMaximalPercentPresets', () {
    test('matches coach-oriented chip table', () {
      expect(
        kMaximalPercentPresets,
        [50, 60, 65, 70, 75, 80, 85, 90, 95],
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/set_load_display.dart';

void main() {
  group('formatSetLoadDisplay', () {
    test('splits load@rpe into kg and rpe cells', () {
      final d = formatSetLoadDisplay('60@8');
      expect(d.loadLabel, '60');
      expect(d.rpeLabel, '8');
      expect(d.percentLabel, '—');
    });

    test('handles kg suffix and decimal rpe', () {
      final d = formatSetLoadDisplay('75kg @8.5');
      expect(d.loadLabel, '75');
      expect(d.rpeLabel, '8.5');
      expect(d.percentLabel, '—');
    });

    test('pure rpe marker leaves load empty', () {
      final d = formatSetLoadDisplay('@8');
      expect(d.loadLabel, '—');
      expect(d.rpeLabel, '8');
    });

    test('empty or unparseable shows em dashes', () {
      final empty = formatSetLoadDisplay('');
      expect(empty.loadLabel, '—');
      expect(empty.rpeLabel, '—');
      expect(empty.percentLabel, '—');

      final text = formatSetLoadDisplay('moderato');
      expect(text.loadLabel, '—');
      expect(text.rpeLabel, '—');
    });

    test('derives inverse percent when maximal kg known', () {
      final d = formatSetLoadDisplay(
        '80@8',
        resolvedMaximalKg: 100,
        hasMaximalRef: true,
      );
      expect(d.percentLabel, '80%');
      expect(d.loadLabel, '80');
      expect(d.rpeLabel, '8');
    });

    test('percent stays dash without ref or without resolved kg', () {
      expect(
        formatSetLoadDisplay(
          '80@8',
          resolvedMaximalKg: 100,
          hasMaximalRef: false,
        ).percentLabel,
        '—',
      );
      expect(
        formatSetLoadDisplay(
          '80@8',
          hasMaximalRef: true,
        ).percentLabel,
        '—',
      );
      expect(
        formatSetLoadDisplay(
          '80@8',
          resolvedMaximalKg: 0,
          hasMaximalRef: true,
        ).percentLabel,
        '—',
      );
    });

    test('rounds percent from load and maximal', () {
      final d = formatSetLoadDisplay(
        '107.5',
        resolvedMaximalKg: 142.5,
        hasMaximalRef: true,
      );
      expect(d.percentLabel, '75%');
      expect(d.loadLabel, '107.5');
    });
  });
}

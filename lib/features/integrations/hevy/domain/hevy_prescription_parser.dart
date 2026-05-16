import '../../../workouts/data/workout_routine_model.dart';

/// Parsed set row for Hevy routine/workout API.
class HevyParsedSet {
  const HevyParsedSet({
    this.type = 'normal',
    this.reps,
    this.weightKg,
    this.rpe,
    this.durationSeconds,
  });

  final String type;
  final int? reps;
  final double? weightKg;
  final double? rpe;
  final int? durationSeconds;
}

/// Maps PowerCoach prescriptions to Hevy set payloads.
class HevyPrescriptionParser {
  static const _allowedRpe = [6.0, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0];

  List<HevyParsedSet> parseExercise(Exercise exercise) {
    final details = exercise.effectiveSetDetails;
    if (details.isEmpty) {
      return [_fromLegacy(exercise.sets, exercise.reps, exercise.rpe)];
    }

    final out = <HevyParsedSet>[];
    for (final block in details) {
      out.addAll(_parseSetDetail(block, exercise.sets));
    }
    if (out.isEmpty) {
      return [const HevyParsedSet()];
    }
    return out;
  }

  List<HevyParsedSet> _parseSetDetail(ExerciseSet block, String fallbackSets) {
    final line = block.displayText.trim();
    if (line.isEmpty) {
      return [const HevyParsedSet()];
    }

    final fromLine = _parseLine(line);
    if (fromLine != null) {
      final count = _parseSetCount(block.sets.isNotEmpty ? block.sets : fallbackSets);
      return List.generate(count, (_) => fromLine);
    }

    return [
      HevyParsedSet(
        reps: _parseReps(block.reps),
        weightKg: _parseWeight(block.rpe),
        rpe: _nearestRpe(_parseRpeValue(block.rpe)),
      ),
    ];
  }

  HevyParsedSet _fromLegacy(String sets, String reps, String rpe) {
    final parsed = _parseLine('${sets}x$reps $rpe'.trim());
    if (parsed != null) {
      return parsed;
    }
    return HevyParsedSet(
      reps: _parseReps(reps),
      weightKg: _parseWeight(rpe),
      rpe: _nearestRpe(_parseRpeValue(rpe)),
    );
  }

  int _parseSetCount(String sets) {
    final n = int.tryParse(sets.trim());
    if (n == null || n < 1) return 1;
    return n.clamp(1, 20);
  }

  int? _parseReps(String value) {
    final digits = RegExp(r'\d+').firstMatch(value.trim());
    if (digits == null) return null;
    return int.tryParse(digits.group(0)!);
  }

  double? _parseWeight(String value) {
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*kg', caseSensitive: false).firstMatch(value);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  double? _parseRpeValue(String value) {
    final at = RegExp(r'@?\s*(\d+(?:\.\d+)?)').firstMatch(value.trim());
    if (at != null) return double.tryParse(at.group(1)!);
    final rpe = RegExp(r'rpe\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(value);
    if (rpe != null) return double.tryParse(rpe.group(1)!);
    return null;
  }

  double? _nearestRpe(double? value) {
    if (value == null) return null;
    double? best;
    var bestDist = double.infinity;
    for (final allowed in _allowedRpe) {
      final d = (allowed - value).abs();
      if (d < bestDist) {
        bestDist = d;
        best = allowed;
      }
    }
    return best;
  }

  HevyParsedSet? _parseLine(String line) {
    final lower = line.toLowerCase();
    final setMatch = RegExp(r'^(\d+)\s*x\s*(\d+)', caseSensitive: false).firstMatch(lower);
    int? reps;
    if (setMatch != null) {
      reps = int.tryParse(setMatch.group(2)!);
    } else {
      reps = _parseReps(line);
    }
    return HevyParsedSet(
      reps: reps,
      weightKg: _parseWeight(line),
      rpe: _nearestRpe(_parseRpeValue(line)),
    );
  }
}

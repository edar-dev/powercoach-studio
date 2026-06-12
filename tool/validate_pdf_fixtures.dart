import 'dart:io';

import 'package:powercoach_studio/features/workouts/domain/workout_routine_json_codec.dart';

void main() {
  final dir = Directory('docs/pdfs/fixtures');
  if (!dir.existsSync()) {
    stderr.writeln('Missing docs/pdfs/fixtures');
    exit(1);
  }
  for (final entity in dir.listSync()) {
    if (entity is! File || !entity.path.endsWith('.json')) continue;
    final name = entity.uri.pathSegments.last;
    final routine = decodeWorkoutRoutineJson(entity.readAsStringSync());
    stdout.writeln(
      'OK $name: "${routine.name}" (${routine.weeks.length} weeks, '
      '${routine.mobilityItems.length} mobility)',
    );
  }
}

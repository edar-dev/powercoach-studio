import '../../features/workouts/data/workout_routine_model.dart';
import '../../features/workouts/domain/exercise_prescription_scope.dart';
import 'pdf_programming_rows.dart';

/// Stable key for aligning the same exercise across week columns in dense PDF.
String denseProgrammingBlockKey(Object block) {
  if (block is Exercise) {
    final customId = block.customExerciseId?.trim() ?? '';
    if (customId.isNotEmpty) return 'cex:$customId';
    return 'name:${block.name.trim().toLowerCase()}';
  }
  final group = block as List<Exercise>;
  if (group.isEmpty) return 'empty';
  return 'ss:${group.map(denseProgrammingBlockKey).join('|')}';
}

/// One aligned row in a dense day table (exercise label + per-week cells).
class DenseDayRow {
  const DenseDayRow({
    required this.rowKey,
    required this.labelBlock,
    required this.weekBlocks,
  });

  final String rowKey;
  final Object? labelBlock;
  final List<Object?> weekBlocks;
}

List<DenseDayRow> buildDenseDayRows({
  required List<Week> weeks,
  required int dayIndex,
}) {
  final orderedKeys = <String>[];
  final weekBlocksByKey = <String, List<Object?>>{};
  final labelBlockByKey = <String, Object?>{};

  void registerBlock(Object block, int weekIndex) {
    final key = denseProgrammingBlockKey(block);
    if (!weekBlocksByKey.containsKey(key)) {
      orderedKeys.add(key);
      weekBlocksByKey[key] = List<Object?>.filled(weeks.length, null);
      labelBlockByKey[key] = block;
    }
    weekBlocksByKey[key]![weekIndex] = block;
    if (labelBlockByKey[key] == null) {
      labelBlockByKey[key] = block;
    }
  }

  for (var wi = 0; wi < weeks.length; wi++) {
    if (dayIndex >= weeks[wi].days.length) continue;
    final blocks = partitionExercisesBySuperset(weeks[wi].days[dayIndex].exercises);
    for (final block in blocks) {
      registerBlock(block, wi);
    }
  }

  return orderedKeys
      .map(
        (key) => DenseDayRow(
          rowKey: key,
          labelBlock: labelBlockByKey[key],
          weekBlocks: weekBlocksByKey[key]!,
        ),
      )
      .toList();
}

bool denseShouldMergeWeekCells({
  required Object? labelBlock,
  required List<PdfDenseCellContent?> weekContents,
}) {
  if (labelBlock is Exercise &&
      labelBlock.prescriptionScope == ExercisePrescriptionScope.allWeeks) {
    final populated = weekContents
        .whereType<PdfDenseCellContent>()
        .where((cell) => cell.prescription.trim().isNotEmpty)
        .length;
    return populated >= 1;
  }
  return denseWeekPrescriptionsIdentical(weekContents);
}

ExercisePrescriptionScope? denseLabelPrescriptionScope(Object? block) {
  if (block is Exercise) return block.prescriptionScope;
  if (block is List<Exercise> && block.isNotEmpty) {
    return block.first.prescriptionScope;
  }
  return null;
}

bool denseBlockIsSuperset(Object? block) =>
    block is List<Exercise> && block.length > 1;

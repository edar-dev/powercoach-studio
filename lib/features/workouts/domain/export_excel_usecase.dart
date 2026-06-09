import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../../core/export/export_artifact.dart';
import '../data/workout_routine_model.dart';

/// Exports [WorkoutRoutine] to an .xlsx file. Layout: plan name, then for each week/day
/// a table with columns Exercise, Sets, Reps, Load/RPE, Notes.
Future<ExportArtifact> exportWorkoutRoutineToExcel(WorkoutRoutine routine) async {
  final excel = Excel.createExcel();
  final sheet = excel['Workout Plan'];

  int row = 0;

  // Plan name
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(routine.name);
  row += 2;

  for (final week in routine.weeks) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(week.name);
    row += 1;

    for (final day in week.days) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(day.name);
      row += 1;

      // Header row
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Exercise');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue('Sets');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue('Reps');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue('Load/RPE');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue('Notes');
      row += 1;

      for (final item in partitionExercisesBySuperset(day.exercises)) {
        if (item is Exercise) {
          final ex = item;
          final details = ex.effectiveSetDetails;
          if (details.length > 1) {
            for (var i = 0; i < details.length; i++) {
              final s = details[i];
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(i == 0 ? ex.name : '');
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(i == 0 ? '${details.length}' : '');
            final disp = s.displayText;
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(disp.isNotEmpty ? disp : s.reps);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(disp.isNotEmpty ? '' : s.rpe);
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(s.note.isNotEmpty ? s.note : (i == 0 ? ex.note : ''));
              row += 1;
            }
          } else {
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(ex.name);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(ex.sets);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(ex.reps);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(ex.rpe);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(ex.note);
            row += 1;
          }
        } else {
          final group = item as List<Exercise>;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('Superset');
          row += 1;
          for (final ex in group) {
            final details = ex.effectiveSetDetails;
            if (details.length > 1) {
              for (var i = 0; i < details.length; i++) {
                final s = details[i];
                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(i == 0 ? ex.name : '');
                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(i == 0 ? '${details.length}' : '');
            final disp = s.displayText;
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(disp.isNotEmpty ? disp : s.reps);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(disp.isNotEmpty ? '' : s.rpe);
                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(s.note.isNotEmpty ? s.note : (i == 0 ? ex.note : ''));
                row += 1;
              }
            } else {
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(ex.name);
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(ex.sets);
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(ex.reps);
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(ex.rpe);
              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(ex.note);
              row += 1;
            }
          }
        }
      }
      row += 1;
    }
    row += 1;
  }

  final sanitizedName = routine.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final sanitized = sanitizedName.isEmpty ? 'workout_plan' : sanitizedName;
  final encoded = excel.encode() ?? <int>[];
  return ExportArtifact(
    bytes: Uint8List.fromList(encoded),
    filename: '${sanitized}_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    mimeType:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
}

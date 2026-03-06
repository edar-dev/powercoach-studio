import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../data/workout_routine_model.dart';

/// Exports [WorkoutRoutine] to an .xlsx file. Layout: plan name, then for each week/day
/// a table with columns Exercise, Sets, Reps, Load/RPE, Notes.
/// Returns the path to the saved file in the temp directory for sharing.
Future<String> exportWorkoutRoutineToExcel(WorkoutRoutine routine) async {
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

      for (final ex in day.exercises) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(ex.name);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(ex.sets);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(ex.reps);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(ex.rpe);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(ex.note);
        row += 1;
      }
      row += 1;
    }
    row += 1;
  }

  final dir = await getTemporaryDirectory();
  final sanitizedName = routine.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final sanitized = sanitizedName.isEmpty ? 'workout_plan' : sanitizedName;
  final path = '${dir.path}/${sanitized}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  final file = File(path);
  final bytes = excel.encode();
  if (bytes != null) {
    await file.writeAsBytes(bytes);
  }
  return file.path;
}

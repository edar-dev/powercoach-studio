import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/export/export_artifact.dart';
import '../../../core/pdf/pdf_coach_header.dart';
import '../../../core/pdf/pdf_document_theme.dart';
import '../../../core/pdf/pdf_export_labels.dart';
import '../../../core/pdf/pdf_programming_rows.dart';
import '../../../core/pdf/pdf_text_sanitize.dart';
import '../data/workout_routine_model.dart';

/// PDF programming layout: per-week sections vs dense progression columns.
enum WorkoutPdfLayout {
  /// One section per week, then days.
  canonical,

  /// One section per day slot; columns are weeks (progression view).
  /// Optimized for minimal page count.
  dense,
}

/// Generates a PDF from [WorkoutRoutine].
/// Returns an in-memory artifact for sharing (works on web and native).
Future<ExportArtifact> exportWorkoutRoutineToPdf(
  WorkoutRoutine routine, {
  required PdfExportLabels labels,
  PdfCoachHeaderInfo? coachHeader,
  WorkoutPdfLayout layout = WorkoutPdfLayout.dense,
  bool includeMobility = true,
}) async {
  final generatedAt = DateTime.now();
  final doc = pw.Document();
  final dense = layout == WorkoutPdfLayout.dense;

  final programming = layout == WorkoutPdfLayout.canonical
      ? _canonicalProgrammingWidgets(routine, labels, dense: dense)
      : _denseProgrammingWidgets(routine, labels);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(PdfDocumentTheme.pageMarginFor(dense: dense)),
      header: (context) {
        if (dense && context.pageNumber > 1) {
          return PdfDocumentTheme.buildRunningHeader(
            routine.name,
            context,
            labels,
          );
        }
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (coachHeader != null && coachHeader.hasContent)
              PdfDocumentTheme.buildCoachHeaderBand(coachHeader),
            PdfDocumentTheme.buildDocumentTitle(routine.name, dense: dense),
            pw.SizedBox(height: dense ? 6 : 10),
          ],
        );
      },
      footer: (context) => PdfDocumentTheme.buildPageFooter(
        context,
        labels,
        generatedAt,
        dense: dense,
        showDisclaimer: !dense || context.pageNumber == context.pagesCount,
      ),
      build: (context) => [
        if (includeMobility) ..._mobilityWidgets(routine, labels, dense: dense),
        ...programming,
      ],
    ),
  );

  final bytes = await doc.save();
  final sanitizedName = routine.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final sanitized = sanitizedName.isEmpty ? 'workout_plan' : sanitizedName;
  return ExportArtifact(
    bytes: bytes,
    filename: '${sanitized}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    mimeType: 'application/pdf',
  );
}

List<pw.Widget> _mobilityWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels, {
  required bool dense,
}) {
  if (routine.mobilityItems.isEmpty) return [];

  final sections = <pw.Widget>[];
  for (final section in routine.mobilitySections) {
    final items =
        routine.mobilityItems.where((m) => m.sectionId == section.id).toList();
    if (items.isEmpty) continue;

    final sectionName = section.name.trim().isNotEmpty
        ? section.name.trim()
        : labels.mobilityFallback;

    sections.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            sectionName,
            style: pw.TextStyle(
              fontSize: dense
                  ? PdfDocumentTheme.denseDayFontSize
                  : PdfDocumentTheme.dayFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfDocumentTheme.textPrimary,
            ),
          ),
          pw.SizedBox(height: dense ? 3 : 6),
          ...items.map(
            (m) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: dense ? 1.5 : 3),
              child: pw.Text(
                '${sanitizePdfText(m.title)}: ${sanitizePdfText(m.subtitle)}',
                style: pw.TextStyle(
                  fontSize: dense
                      ? PdfDocumentTheme.denseTableFontSize
                      : PdfDocumentTheme.tableFontSize,
                  color: PdfDocumentTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  if (sections.isEmpty) return [];

  final rows = <pw.Widget>[];
  final columns = dense ? 3 : 2;
  for (var i = 0; i < sections.length; i += columns) {
    rows.add(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < columns; c++) ...[
            if (c > 0) pw.SizedBox(width: dense ? 10 : 16),
            if (i + c < sections.length)
              pw.Expanded(child: sections[i + c])
            else if (c == 0)
              pw.Spacer()
            else
              pw.Expanded(child: pw.SizedBox()),
          ],
        ],
      ),
    );
    rows.add(pw.SizedBox(height: dense ? 6 : 12));
  }

  return [
    PdfDocumentTheme.sectionTitle(labels.mobilityFallback, dense: dense),
    ...rows,
    pw.SizedBox(height: dense ? 4 : 8),
  ];
}

List<pw.Widget> _canonicalProgrammingWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels, {
  required bool dense,
}) {
  return routine.weeks.expand((week) {
    final weekTitle = week.name.trim().isNotEmpty ? week.name.trim() : 'Week';
    final dayWidgets = <pw.Widget>[];

    for (final entry in week.days.asMap().entries) {
      final day = entry.value;
      final dayTitle = day.name.trim().isNotEmpty
          ? day.name.trim()
          : labels.dayNumber(entry.key + 1);
      final blocks = partitionExercisesBySuperset(day.exercises);

      dayWidgets.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            PdfDocumentTheme.dayTitle(dayTitle, dense: dense),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfDocumentTheme.border,
                width: dense ? 0.35 : 0.5,
              ),
              columnWidths: dense
                  ? const {
                      0: pw.FlexColumnWidth(2.1),
                      1: pw.FlexColumnWidth(2.4),
                      2: pw.FlexColumnWidth(1.5),
                    }
                  : const {
                      0: pw.FlexColumnWidth(2.2),
                      1: pw.FlexColumnWidth(0.38),
                      2: pw.FlexColumnWidth(0.55),
                      3: pw.FlexColumnWidth(0.82),
                      4: pw.FlexColumnWidth(1.55),
                    },
              children: [
                if (entry.key == 0)
                  PdfDocumentTheme.programmingHeaderRow(
                    labels,
                    dense: dense,
                    prescriptionColumns: dense,
                  ),
                ...blocks.expand((item) => _tableRowsForBlock(
                      item,
                      labels,
                      dense: dense,
                    )),
              ],
            ),
            pw.SizedBox(height: dense ? 5 : 10),
          ],
        ),
      );
    }

    return [
      PdfDocumentTheme.sectionTitle(weekTitle, dense: dense),
      ...dayWidgets,
      pw.SizedBox(height: dense ? 3 : 6),
    ];
  }).toList();
}

Iterable<pw.TableRow> _tableRowsForBlock(
  Object item,
  PdfExportLabels labels, {
  required bool dense,
}) {
  if (item is Exercise) {
    return _exerciseRows(item, labels, dense: dense);
  }
  final group = item as List<Exercise>;
  if (dense) {
    return group.expand((e) => _exerciseRows(e, labels, dense: dense));
  }
  return [
    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfDocumentTheme.supersetBg),
      children: [
        PdfDocumentTheme.tableCell(labels.superset, isSuperset: true, dense: dense),
        PdfDocumentTheme.tableCell('', isSuperset: true, dense: dense),
        PdfDocumentTheme.tableCell('', isSuperset: true, dense: dense),
        PdfDocumentTheme.tableCell('', isSuperset: true, dense: dense),
        PdfDocumentTheme.tableCell('', isSuperset: true, dense: dense),
      ],
    ),
    ...group.expand((e) => _exerciseRows(e, labels, dense: dense)),
  ];
}

Iterable<pw.TableRow> _exerciseRows(
  Exercise e,
  PdfExportLabels labels, {
  required bool dense,
}) {
  final rows = buildProgrammingSetRows(e, dense: dense);
  return rows.map((row) {
    if (dense && row.prescriptionOnly) {
      return pw.TableRow(
        decoration: pw.BoxDecoration(
          color: row.isGrouped ? PdfDocumentTheme.exerciseGroupBg : null,
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfDocumentTheme.border, width: 0.35),
          ),
        ),
        children: [
          PdfDocumentTheme.programmingExerciseCell(
            row.exercise,
            highlight: row.isGrouped,
            emptyPlaceholder: labels.emptyValue,
            dense: true,
          ),
          PdfDocumentTheme.tableCell(
            row.reps,
            blankIfEmpty: row.reps.isEmpty,
            emptyPlaceholder: labels.emptyValue,
            dense: true,
          ),
          PdfDocumentTheme.tableCell(
            row.notes,
            blankIfEmpty: row.notes.isEmpty,
            emptyPlaceholder: labels.emptyValue,
            dense: true,
          ),
        ],
      );
    }

    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: row.isGrouped ? PdfDocumentTheme.exerciseGroupBg : null,
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfDocumentTheme.border,
            width: dense ? 0.35 : 0.4,
          ),
        ),
      ),
      children: [
        PdfDocumentTheme.programmingExerciseCell(
          row.exercise,
          highlight: row.isGrouped,
          emptyPlaceholder: labels.emptyValue,
          dense: dense,
        ),
        PdfDocumentTheme.tableCell(
          row.sets,
          center: true,
          blankIfEmpty: row.sets.isEmpty,
          emptyPlaceholder: labels.emptyValue,
          dense: dense,
        ),
        PdfDocumentTheme.tableCell(
          row.reps,
          center: true,
          blankIfEmpty: row.reps.isEmpty,
          emptyPlaceholder: labels.emptyValue,
          dense: dense,
        ),
        PdfDocumentTheme.tableCell(
          row.load,
          center: true,
          blankIfEmpty: row.load.isEmpty,
          emptyPlaceholder: labels.emptyValue,
          dense: dense,
        ),
        PdfDocumentTheme.tableCell(
          row.notes,
          blankIfEmpty: row.notes.isEmpty,
          emptyPlaceholder: labels.emptyValue,
          dense: dense,
        ),
      ],
    );
  });
}

int _maxDaySlotCount(List<Week> weeks) {
  var m = 0;
  for (final w in weeks) {
    if (w.days.length > m) m = w.days.length;
  }
  return m;
}

List<Object> _blocksForDay(Day day) => partitionExercisesBySuperset(day.exercises);

String _blockRowLabel(Object item, {bool dense = false}) {
  if (item is Exercise) return item.name;
  final g = item as List<Exercise>;
  if (g.isEmpty) return '';
  if (g.length == 1) return g.first.name;
  if (dense) {
    return g.map((e) => e.name).join(' + ');
  }
  return g.map((e) => e.name).join(' / ');
}

String _weekColumnHeader(Week week, int index) {
  final n = week.name.trim();
  if (n.length <= 14) return n.isEmpty ? 'W${index + 1}' : n;
  return 'W${index + 1}';
}

List<pw.Widget> _denseProgrammingWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels,
) {
  const dense = true;
  final weeks = routine.weeks;
  if (weeks.isEmpty) return [];

  final out = <pw.Widget>[];
  final daySlots = _maxDaySlotCount(weeks);

  for (var d = 0; d < daySlots; d++) {
    if (!weeks.any((w) => d < w.days.length)) continue;

    final dayTitle = () {
      for (final w in weeks) {
        if (d < w.days.length) {
          final name = w.days[d].name.trim();
          if (name.isNotEmpty) return name;
        }
      }
      return labels.dayNumber(d + 1);
    }();

    var maxRows = 0;
    for (final w in weeks) {
      if (d >= w.days.length) continue;
      final n = _blocksForDay(w.days[d]).length;
      if (n > maxRows) maxRows = n;
    }

    if (maxRows == 0) {
      out.add(pw.SizedBox(height: 4));
      continue;
    }

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1.35),
    };
    for (var i = 0; i < weeks.length; i++) {
      columnWidths[i + 1] = const pw.FlexColumnWidth(1);
    }

    final headerCells = <pw.Widget>[
      PdfDocumentTheme.compactCell(
        labels.colExercise,
        isHeader: true,
        labels: labels,
        dense: dense,
      ),
      ...weeks.asMap().entries.map(
            (e) => PdfDocumentTheme.compactCell(
              _weekColumnHeader(e.value, e.key),
              isHeader: true,
              labels: labels,
              dense: dense,
            ),
          ),
    ];

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfDocumentTheme.tableHeaderBg),
        children: headerCells,
      ),
    ];

    for (var r = 0; r < maxRows; r++) {
      String label = '';
      for (final w in weeks) {
        if (d >= w.days.length) continue;
        final blocks = _blocksForDay(w.days[d]);
        if (r < blocks.length) {
          label = _blockRowLabel(blocks[r], dense: dense);
          break;
        }
      }

      final cells = <pw.Widget>[
        PdfDocumentTheme.compactCell(
          label,
          labels: labels,
          dense: dense,
          blankIfEmpty: true,
        ),
        ...weeks.map((w) {
          if (d >= w.days.length) {
            return PdfDocumentTheme.compactCell(
              '',
              labels: labels,
              dense: dense,
              blankIfEmpty: true,
            );
          }
          final blocks = _blocksForDay(w.days[d]);
          if (r >= blocks.length) {
            return PdfDocumentTheme.compactCell(
              '',
              labels: labels,
              dense: dense,
              blankIfEmpty: true,
            );
          }
          return PdfDocumentTheme.compactCell(
            formatBlockPrescriptionCompact(blocks[r], singleLine: true),
            labels: labels,
            dense: dense,
            blankIfEmpty: true,
          );
        }),
      ];
      tableRows.add(pw.TableRow(children: cells));
    }

    out.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          PdfDocumentTheme.sectionTitle(dayTitle, dense: dense),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfDocumentTheme.border,
              width: 0.35,
            ),
            columnWidths: columnWidths,
            children: tableRows,
          ),
        ],
      ),
    );
    out.add(pw.SizedBox(height: 8));
  }

  return out;
}

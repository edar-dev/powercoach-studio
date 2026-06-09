import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/export/export_artifact.dart';
import '../../../core/pdf/pdf_coach_header.dart';
import '../../../core/pdf/pdf_document_theme.dart';
import '../../../core/pdf/pdf_export_labels.dart';
import '../../../core/pdf/pdf_programming_rows.dart';
import '../../../core/pdf/pdf_text_sanitize.dart';
import '../data/workout_routine_model.dart';

/// PDF programming layout: per-week sections vs per-day progression columns.
enum WorkoutPdfLayout {
  /// One section per week, then days (current behavior).
  canonical,

  /// One section per day slot; columns are weeks (progression view).
  compact,
}

/// Generates a PDF from [WorkoutRoutine].
/// Returns an in-memory artifact for sharing (works on web and native).
Future<ExportArtifact> exportWorkoutRoutineToPdf(
  WorkoutRoutine routine, {
  required PdfExportLabels labels,
  PdfCoachHeaderInfo? coachHeader,
  WorkoutPdfLayout layout = WorkoutPdfLayout.canonical,
  bool includeMobility = true,
}) async {
  final generatedAt = DateTime.now();
  final doc = pw.Document();

  final programming = layout == WorkoutPdfLayout.canonical
      ? _canonicalProgrammingWidgets(routine, labels)
      : _compactProgrammingWidgets(routine, labels);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(PdfDocumentTheme.pageMargin),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (coachHeader != null && coachHeader.hasContent)
            PdfDocumentTheme.buildCoachHeaderBand(coachHeader),
          PdfDocumentTheme.buildDocumentTitle(routine.name),
          pw.SizedBox(height: 14),
        ],
      ),
      footer: (context) =>
          PdfDocumentTheme.buildPageFooter(context, labels, generatedAt),
      build: (context) => [
        if (includeMobility) ..._mobilityWidgets(routine, labels),
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

List<pw.Widget> _mobilityWidgets(WorkoutRoutine routine, PdfExportLabels labels) {
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
              fontSize: PdfDocumentTheme.dayFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfDocumentTheme.textPrimary,
            ),
          ),
          pw.SizedBox(height: 6),
          ...items.map(
            (m) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                '${sanitizePdfText(m.title)}: ${sanitizePdfText(m.subtitle)}',
                style: pw.TextStyle(
                  fontSize: PdfDocumentTheme.tableFontSize,
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
  for (var i = 0; i < sections.length; i += 2) {
    rows.add(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: sections[i]),
          if (i + 1 < sections.length) ...[
            pw.SizedBox(width: 16),
            pw.Expanded(child: sections[i + 1]),
          ] else
            pw.Spacer(),
        ],
      ),
    );
    rows.add(pw.SizedBox(height: 12));
  }

  return [
    PdfDocumentTheme.sectionTitle(labels.mobilityFallback),
    ...rows,
    pw.SizedBox(height: 8),
  ];
}

List<pw.Widget> _canonicalProgrammingWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels,
) {
  return routine.weeks.expand((week) {
    final weekTitle = week.name.trim().isNotEmpty
        ? week.name.trim()
        : 'Week';
    return [
      PdfDocumentTheme.sectionTitle(weekTitle),
      ...week.days.asMap().entries.expand((entry) {
        final day = entry.value;
        final dayTitle = day.name.trim().isNotEmpty
            ? day.name.trim()
            : labels.dayNumber(entry.key + 1);
        return [
          PdfDocumentTheme.dayTitle(dayTitle),
          pw.Table(
            border: pw.TableBorder.all(color: PdfDocumentTheme.border, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.35),
              1: const pw.FlexColumnWidth(0.42),
              2: const pw.FlexColumnWidth(0.62),
              3: const pw.FlexColumnWidth(0.95),
              4: const pw.FlexColumnWidth(1.66),
            },
            children: [
              PdfDocumentTheme.programmingHeaderRow(labels),
              ...partitionExercisesBySuperset(day.exercises).expand((item) {
                return _tableRowsForBlock(item, labels);
              }),
            ],
          ),
          pw.SizedBox(height: 14),
        ];
      }),
      pw.SizedBox(height: 6),
    ];
  }).toList();
}

Iterable<pw.TableRow> _tableRowsForBlock(Object item, PdfExportLabels labels) {
  if (item is Exercise) {
    return _exerciseRows(item, labels);
  }
  final group = item as List<Exercise>;
  return [
    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfDocumentTheme.supersetBg),
      children: [
        PdfDocumentTheme.tableCell(labels.superset, isSuperset: true),
        PdfDocumentTheme.tableCell('', isSuperset: true),
        PdfDocumentTheme.tableCell('', isSuperset: true),
        PdfDocumentTheme.tableCell('', isSuperset: true),
        PdfDocumentTheme.tableCell('', isSuperset: true),
      ],
    ),
    ...group.expand((e) => _exerciseRows(e, labels)),
  ];
}

Iterable<pw.TableRow> _exerciseRows(Exercise e, PdfExportLabels labels) {
  final rows = buildProgrammingSetRows(e);
  return rows.map((row) {
    if (row.isGrouped) {
      return pw.TableRow(
        children: [
          PdfDocumentTheme.groupedExerciseCell(
            text: row.exercise,
            isContinuation: row.isContinuation,
            isLastInGroup: row.isLastInGroup,
            emptyPlaceholder: labels.emptyValue,
          ),
          PdfDocumentTheme.groupedDataCell(
            row.sets,
            isLastInGroup: row.isLastInGroup,
            center: true,
            blankIfEmpty: row.sets.isEmpty,
            emptyPlaceholder: labels.emptyValue,
          ),
          PdfDocumentTheme.groupedDataCell(
            row.reps,
            isLastInGroup: row.isLastInGroup,
            center: true,
            blankIfEmpty: row.reps.isEmpty,
            emptyPlaceholder: labels.emptyValue,
          ),
          PdfDocumentTheme.groupedDataCell(
            row.load,
            isLastInGroup: row.isLastInGroup,
            center: true,
            blankIfEmpty: row.load.isEmpty,
            emptyPlaceholder: labels.emptyValue,
          ),
          PdfDocumentTheme.groupedDataCell(
            row.notes,
            isLastInGroup: row.isLastInGroup,
            blankIfEmpty: row.notes.isEmpty,
            emptyPlaceholder: labels.emptyValue,
          ),
        ],
      );
    }

    return pw.TableRow(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfDocumentTheme.border, width: 0.5),
        ),
      ),
      children: [
        PdfDocumentTheme.tableCell(
          row.exercise,
          bold: true,
          emptyPlaceholder: labels.emptyValue,
        ),
        PdfDocumentTheme.tableCell(
          row.sets,
          center: true,
          blankIfEmpty: row.sets.isEmpty,
          emptyPlaceholder: labels.emptyValue,
        ),
        PdfDocumentTheme.tableCell(
          row.reps,
          center: true,
          blankIfEmpty: row.reps.isEmpty,
          emptyPlaceholder: labels.emptyValue,
        ),
        PdfDocumentTheme.tableCell(
          row.load,
          center: true,
          blankIfEmpty: row.load.isEmpty,
          emptyPlaceholder: labels.emptyValue,
        ),
        PdfDocumentTheme.tableCell(
          row.notes,
          blankIfEmpty: row.notes.isEmpty,
          emptyPlaceholder: labels.emptyValue,
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

String _blockRowLabel(Object item) {
  if (item is Exercise) return item.name;
  final g = item as List<Exercise>;
  if (g.isEmpty) return '';
  if (g.length == 1) return g.first.name;
  return g.map((e) => e.name).join(' / ');
}

String _exercisePrescriptionCompact(Exercise e) {
  final details = e.effectiveSetDetails;
  if (details.length > 1) {
    return details.map((s) {
      if (s.displayText.isNotEmpty) {
        final n = s.note.trim();
        return n.isEmpty ? s.displayText : '${s.displayText} ($n)';
      }
      final sets = s.sets.trim();
      final reps = s.reps.trim();
      final load = s.rpe.trim();
      final n = s.note.trim();
      final core = sets.isNotEmpty && reps.isNotEmpty
          ? '${sets}x$reps${load.isNotEmpty ? ' $load' : ''}'
          : [sets, reps, load].where((x) => x.isNotEmpty).join(' ');
      if (core.isEmpty && n.isEmpty) return '';
      if (n.isEmpty) return core;
      return core.isEmpty ? n : '$core ($n)';
    }).where((x) => x.isNotEmpty).join('\n');
  }
  if (details.isNotEmpty && details.first.displayText.isNotEmpty) {
    final n = e.note.trim();
    final d0 = details.first.displayText;
    return n.isEmpty ? d0 : '$d0 — $n';
  }
  final sets = e.sets.trim();
  final reps = e.reps.trim();
  final rpe = e.rpe.trim();
  final note = e.note.trim();
  String line;
  if (sets.isNotEmpty && reps.isNotEmpty) {
    line = '${sets}x$reps${rpe.isNotEmpty ? ' $rpe' : ''}';
  } else {
    line = [reps, sets, rpe].where((x) => x.isNotEmpty).join(' ');
  }
  if (note.isNotEmpty) {
    line = line.isEmpty ? note : '$line — $note';
  }
  return line;
}

String _blockPrescriptionCompact(Object item) {
  if (item is Exercise) return _exercisePrescriptionCompact(item);
  final g = item as List<Exercise>;
  return g.map((e) => '${e.name}: ${_exercisePrescriptionCompact(e)}').join('\n');
}

String _weekColumnHeader(Week week, int index) {
  final n = week.name.trim();
  if (n.length <= 14) return n.isEmpty ? 'W${index + 1}' : n;
  return 'W${index + 1}';
}

List<pw.Widget> _compactProgrammingWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels,
) {
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

    out.add(PdfDocumentTheme.sectionTitle(dayTitle));

    var maxRows = 0;
    for (final w in weeks) {
      if (d >= w.days.length) continue;
      final n = _blocksForDay(w.days[d]).length;
      if (n > maxRows) maxRows = n;
    }

    if (maxRows == 0) {
      out.add(pw.SizedBox(height: 8));
      continue;
    }

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1.4),
    };
    for (var i = 0; i < weeks.length; i++) {
      columnWidths[i + 1] = const pw.FlexColumnWidth(1);
    }

    final headerCells = <pw.Widget>[
      PdfDocumentTheme.compactCell(labels.colExercise, isHeader: true, labels: labels),
      ...weeks.asMap().entries.map(
            (e) => PdfDocumentTheme.compactCell(
              _weekColumnHeader(e.value, e.key),
              isHeader: true,
              labels: labels,
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
          label = _blockRowLabel(blocks[r]);
          break;
        }
      }
      if (label.isEmpty) label = labels.emptyValue;

      final cells = <pw.Widget>[
        PdfDocumentTheme.compactCell(label, labels: labels),
        ...weeks.map((w) {
          if (d >= w.days.length) {
            return PdfDocumentTheme.compactCell(labels.emptyValue, labels: labels);
          }
          final blocks = _blocksForDay(w.days[d]);
          if (r >= blocks.length) {
            return PdfDocumentTheme.compactCell('', labels: labels);
          }
          return PdfDocumentTheme.compactCell(
            _blockPrescriptionCompact(blocks[r]),
            labels: labels,
          );
        }),
      ];
      tableRows.add(pw.TableRow(children: cells));
    }

    out.add(
      pw.Table(
        border: pw.TableBorder.all(color: PdfDocumentTheme.border, width: 0.5),
        columnWidths: columnWidths,
        children: tableRows,
      ),
    );
    out.add(pw.SizedBox(height: 16));
  }

  return out;
}

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/export/export_artifact.dart';
import '../../../core/pdf/pdf_coach_header.dart';
import '../../../core/pdf/pdf_dense_day_rows.dart';
import '../../../core/pdf/pdf_document_theme.dart';
import '../../../core/pdf/pdf_exercise_name.dart';
import '../../../core/pdf/pdf_export_labels.dart';
import '../../../core/pdf/pdf_mobility_format.dart';
import '../../../core/pdf/pdf_plan_metadata.dart';
import '../../../core/pdf/pdf_programming_rows.dart';
import '../data/workout_routine_model.dart';
import 'density_block.dart';

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
  PdfPlanMetadata? planMetadata,
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
          final weekHints = routine.weeks
              .asMap()
              .keys
              .map((i) => labels.denseWeekShort(i + 1))
              .join('  ');
          return PdfDocumentTheme.buildRunningHeader(
            routine.name,
            subtitle: weekHints,
          );
        }
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (coachHeader != null && coachHeader.hasContent)
              PdfDocumentTheme.buildCoachHeaderBand(coachHeader),
            PdfDocumentTheme.buildDocumentTitle(routine.name, dense: dense),
            if (planMetadata != null) ...[
              if (planMetadata.hasClient)
                PdfDocumentTheme.buildPlanSubtitle(
                  labels.pdfClientPlanFor(planMetadata.clientName!),
                  dense: dense,
                ),
              if (planMetadata.hasPlanPeriod)
                PdfDocumentTheme.buildPlanSubtitle(
                  planMetadata.planPeriodLabel!,
                  dense: dense,
                ),
            ],
            if (dense && routine.weeks.length > 1) ...[
              PdfDocumentTheme.buildDenseWeekLegend(
                labels,
                routine.weeks.asMap().entries.map((entry) {
                  final name = entry.value.name.trim();
                  return name.isNotEmpty
                      ? name
                      : labels.denseWeekShort(entry.key + 1);
                }).toList(),
              ),
              PdfDocumentTheme.buildDenseLegendHint(labels.denseLegend),
            ],
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
        if (includeMobility) ...[
          ..._mobilityWidgets(routine, labels, dense: dense),
          pw.NewPage(),
        ],
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
          if (section.scheduleHint.trim().isNotEmpty) ...[
            pw.SizedBox(height: dense ? 1 : 2),
            pw.Text(
              section.scheduleHint.trim(),
              style: pw.TextStyle(
                fontSize: dense
                    ? PdfDocumentTheme.denseCompactTableFontSize
                    : PdfDocumentTheme.tableFontSize,
                fontStyle: pw.FontStyle.italic,
                color: PdfDocumentTheme.textMuted,
              ),
            ),
          ],
          pw.SizedBox(height: dense ? 3 : 6),
          ...items.map(
            (m) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: dense ? 1.5 : 3),
              child: pw.Text(
                formatMobilityPdfLine(m.pdfTitle, m.subtitle),
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
            if ((day.coachingNote ?? '').trim().isNotEmpty)
              PdfDocumentTheme.dayCoachingNote(
                day.coachingNote!.trim(),
                dense: dense,
              ),
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
                      day,
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
  Day day,
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
  final headerLabel = densityBlockExportLabel(day, group, labels);
  return [
    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfDocumentTheme.supersetBg),
      children: [
        PdfDocumentTheme.tableCell(headerLabel, isSuperset: true, dense: dense),
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

String _blockRowLabel(
  Object item, {
  required int rowNumber,
  required PdfExportLabels labels,
  Day? day,
  bool dense = false,
}) {
  final prefix = '$rowNumber. ';
  if (item is Exercise) {
    final name = dense ? resolveExerciseDisplayNameForPdf(item) : item.name;
    return '$prefix$name';
  }
  final g = item as List<Exercise>;
  if (g.isEmpty) return '';
  if (g.length == 1) {
    final name =
        dense ? resolveExerciseDisplayNameForPdf(g.first) : g.first.name;
    return '$prefix$name';
  }
  final joiner = dense ? ' + ' : ' / ';
  final names = g
      .map((e) => dense ? resolveExerciseDisplayNameForPdf(e) : e.name)
      .join(joiner);
  final tagLabel = day != null
      ? densityBlockExportLabel(day, g, labels)
      : labels.superset;
  final densityTag = dense ? '$tagLabel: ' : '';
  return '$prefix$densityTag$names';
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

    if (d > 0) {
      out.add(pw.NewPage());
    }

    final dayTitle = () {
      for (final w in weeks) {
        if (d < w.days.length) {
          final name = w.days[d].name.trim();
          if (name.isNotEmpty) return name;
        }
      }
      return labels.dayNumber(d + 1);
    }();

    final dayRows = buildDenseDayRows(weeks: weeks, dayIndex: d);
    if (dayRows.isEmpty) {
      out.add(pw.SizedBox(height: 4));
      continue;
    }

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FlexColumnWidth(1.15),
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
              labels.denseWeekShort(e.key + 1),
              isHeader: true,
              labels: labels,
              dense: dense,
              center: true,
            ),
          ),
    ];

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfDocumentTheme.tableHeaderBg),
        children: headerCells,
      ),
    ];

    for (var r = 0; r < dayRows.length; r++) {
      final dayRow = dayRows[r];
      final block = dayRow.labelBlock;
      Day? labelDay;
      for (final w in weeks) {
        if (d < w.days.length) {
          labelDay = w.days[d];
          break;
        }
      }

      final label = block == null
          ? ''
          : _blockRowLabel(
              block,
              rowNumber: r + 1,
              labels: labels,
              day: labelDay,
              dense: dense,
            );

      final weekContents = dayRow.weekBlocks
          .map(
            (weekBlock) => weekBlock == null
                ? null
                : formatDenseBlockContent(weekBlock),
          )
          .toList();

      final allSame = denseShouldMergeWeekCells(
        labelBlock: block,
        weekContents: weekContents,
      );
      final sharedNote = resolveSharedDenseNote(weekContents);
      final firstPopulatedIndex = weekContents.indexWhere(
        (content) => content != null && content.prescription.trim().isNotEmpty,
      );

      final cells = <pw.Widget>[
        PdfDocumentTheme.denseExerciseLabelCell(
          label: label,
          sharedNote: allSame ? null : sharedNote,
        ),
      ];

      final weeksSpanLabel = labels.denseWeeksSpan(1, weeks.length);

      for (var wi = 0; wi < weeks.length; wi++) {
        final content = weekContents[wi];
        if (content == null || content.prescription.trim().isEmpty) {
          cells.add(
            PdfDocumentTheme.compactCell(
              '',
              labels: labels,
              dense: dense,
              blankIfEmpty: true,
            ),
          );
          continue;
        }
        if (allSame) {
          if (wi == firstPopulatedIndex) {
            cells.add(
              PdfDocumentTheme.denseMergedWeeksCell(
                PdfDenseCellContent(
                  prescription: content.prescription,
                  note: sharedNote ?? '',
                ),
                weeksSpanLabel: weeksSpanLabel,
                allWeeksLabel: labels.denseAllWeeks,
                note: sharedNote,
              ),
            );
          } else {
            cells.add(
              PdfDocumentTheme.denseMergedWeeksSpacerCell(
                dittoMark: labels.denseDitto,
              ),
            );
          }
          continue;
        }
        final previous = wi > 0 ? weekContents[wi - 1] : null;
        if (previous != null &&
            previous.prescription.trim() == content.prescription.trim() &&
            content.prescription.trim().isNotEmpty &&
            previous.note.trim() == content.note.trim()) {
          cells.add(
            PdfDocumentTheme.denseMergedWeeksSpacerCell(
              dittoMark: labels.denseDitto,
            ),
          );
          continue;
        }
        cells.add(
          PdfDocumentTheme.densePrescriptionCell(
            PdfDenseCellContent(
              prescription: content.prescription,
              note: sharedNote == null ? content.note : '',
            ),
            includeNote: sharedNote == null,
            center: true,
          ),
        );
      }

      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: r.isOdd ? PdfDocumentTheme.tableRowAltBg : null,
          ),
          children: cells,
        ),
      );
    }

    out.add(
      pw.Inseparable(
        child: pw.Column(
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
      ),
    );
    out.add(pw.SizedBox(height: 8));
  }

  return out;
}

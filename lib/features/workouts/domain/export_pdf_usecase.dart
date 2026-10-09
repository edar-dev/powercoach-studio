import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/analytics/product_analytics.dart';
import '../../../core/export/export_artifact.dart';
import '../../../core/export/export_filename.dart';
import '../../../core/pdf/pdf_coach_header.dart';
import '../../../core/pdf/pdf_dense_day_rows.dart';
import '../../../core/pdf/pdf_document_theme.dart';
import '../../../core/pdf/pdf_exercise_name.dart';
import '../../../core/pdf/pdf_export_labels.dart';
import '../../../core/pdf/pdf_mobility_format.dart';
import '../../../core/pdf/pdf_page_packing.dart';
import '../../../core/pdf/pdf_plan_metadata.dart';
import '../../../core/pdf/pdf_programming_rows.dart';
import '../data/workout_routine_model.dart';
import 'filter_routine_weeks.dart';

export 'filter_routine_weeks.dart';

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
///
/// When [weekIndices] is non-null and non-empty, only those weeks (0-based)
/// are included. Invalid filters fall back to the full routine.
Future<ExportArtifact> exportWorkoutRoutineToPdf(
  WorkoutRoutine routine, {
  required PdfExportLabels labels,
  PdfCoachHeaderInfo? coachHeader,
  PdfPlanMetadata? planMetadata,
  WorkoutPdfLayout layout = WorkoutPdfLayout.dense,
  bool includeMobility = true,
  List<int>? weekIndices,
  String? clientOrCoachName,
}) async {
  final filtered = filterRoutineWeeks(routine, weekIndices);
  final generatedAt = DateTime.now();
  final doc = pw.Document();
  final dense = layout == WorkoutPdfLayout.dense;

  final body = dense
      ? _densePageBodyWidgets(
          filtered,
          labels,
          includeMobility: includeMobility,
        )
      : [
          if (includeMobility)
            ..._mobilityWidgets(filtered, labels, dense: dense),
          ..._canonicalProgrammingWidgets(filtered, labels, dense: dense),
        ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(PdfDocumentTheme.pageMarginFor(dense: dense)),
      header: (context) {
        if (dense && context.pageNumber > 1) {
          final weekHints = filtered.weeks
              .asMap()
              .keys
              .map((i) => labels.denseWeekShort(i + 1))
              .join('  ');
          return PdfDocumentTheme.buildRunningHeader(
            filtered.name,
            subtitle: weekHints,
          );
        }
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (coachHeader != null && coachHeader.hasContent)
              PdfDocumentTheme.buildCoachHeaderBand(coachHeader),
            PdfDocumentTheme.buildDocumentTitle(
              filtered.name,
              dense: dense,
              coachHeader: coachHeader,
            ),
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
            if (dense && filtered.weeks.length > 1) ...[
              PdfDocumentTheme.buildDenseWeekLegend(
                labels,
                filtered.weeks.asMap().entries.map((entry) {
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
        coachHeader: coachHeader,
      ),
      build: (context) => body,
    ),
  );

  final bytes = await doc.save();
  final filename = buildSmartPdfFilename(
    documentSlug: filtered.name,
    clientOrCoachName: clientOrCoachName,
    generatedOn: generatedAt,
    fallbackDocumentSlug: 'workout_plan',
  );
  ProductAnalytics.pdfExported(source: 'workout_plan');
  return ExportArtifact(
    bytes: bytes,
    filename: filename,
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

/// Day section for optional within-week packing (canonical layout).
class _CanonicalDayBlock {
  _CanonicalDayBlock({
    required this.widgets,
    required this.estimatedHeight,
  });

  final List<pw.Widget> widgets;
  final double estimatedHeight;
}

List<pw.Widget> _canonicalProgrammingWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels, {
  required bool dense,
}) {
  // Canonical packing uses a budget slightly tighter than dense later-page
  // (larger margins / day chrome). Dense-only packing is the primary ROI;
  // this only packs remaining short days after week-title+first-day.
  final remainingDayBudget = denseContentBudget(firstPage: false) - 40;

  return routine.weeks.expand((week) {
    final weekTitle = week.name.trim().isNotEmpty ? week.name.trim() : 'Week';
    final dayBlocks = <_CanonicalDayBlock>[];

    for (final entry in week.days.asMap().entries) {
      final day = entry.value;
      final dayTitle = day.name.trim().isNotEmpty
          ? day.name.trim()
          : labels.dayNumber(entry.key + 1);
      final blocks = partitionExercisesBySuperset(day.exercises);
      final columnWidths = dense
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
            };

      final tableRows = [
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
      ];
      // Prefer slight overestimate (title + header + rows + gap).
      final estimatedHeight =
          20.0 + 16.0 + (tableRows.length - 1) * 18.0 + (dense ? 5.0 : 10.0);

      dayBlocks.add(
        _CanonicalDayBlock(
          estimatedHeight: estimatedHeight,
          widgets: [
            PdfDocumentTheme.dayTitle(dayTitle, dense: dense),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfDocumentTheme.border,
                width: dense ? 0.35 : 0.5,
              ),
              columnWidths: columnWidths,
              children: tableRows,
            ),
            pw.SizedBox(height: dense ? 5 : 10),
          ],
        ),
      );
    }

    // Bind week title to the first day so it cannot orphan alone at a break.
    if (dayBlocks.isEmpty) {
      return [
        PdfDocumentTheme.sectionTitle(weekTitle, dense: dense),
        pw.SizedBox(height: dense ? 3 : 6),
      ];
    }

    final first = dayBlocks.first;
    final remaining = dayBlocks.skip(1).toList();
    final packedRemaining = packConsecutiveByHeight(
      remaining,
      (b) => b.estimatedHeight,
      pageBudget: remainingDayBudget,
    );

    return [
      // Outer Inseparable: week title + first day only (no canSpan).
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            PdfDocumentTheme.sectionTitle(weekTitle, dense: dense),
            ...first.widgets,
          ],
        ),
      ),
      // Pack consecutive short remaining days; each batch is one Inseparable.
      for (final batch in packedRemaining)
        pw.Inseparable(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              for (final day in batch) ...day.widgets,
            ],
          ),
        ),
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
  if (group.isEmpty) return const [];

  // Canonical supersets: linked names like dense, no dash fillers in Rx cols.
  final names = group.map((e) => e.name.trim()).where((n) => n.isNotEmpty);
  final headerLabel = names.isEmpty
      ? labels.superset
      : '${labels.superset}: ${names.join(' + ')}';
  return [
    pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfDocumentTheme.supersetBg),
      children: [
        PdfDocumentTheme.tableCell(headerLabel, isSuperset: true, dense: dense),
        PdfDocumentTheme.tableCell(
          '',
          isSuperset: true,
          dense: dense,
          blankIfEmpty: true,
        ),
        PdfDocumentTheme.tableCell(
          '',
          isSuperset: true,
          dense: dense,
          blankIfEmpty: true,
        ),
        PdfDocumentTheme.tableCell(
          '',
          isSuperset: true,
          dense: dense,
          blankIfEmpty: true,
        ),
        PdfDocumentTheme.tableCell(
          '',
          isSuperset: true,
          dense: dense,
          blankIfEmpty: true,
        ),
      ],
    ),
    ...group.expand(
      (e) => _exerciseRows(e, labels, dense: dense, inSuperset: true),
    ),
  ];
}

Iterable<pw.TableRow> _exerciseRows(
  Exercise e,
  PdfExportLabels labels, {
  required bool dense,
  bool inSuperset = false,
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

    final highlight = row.isGrouped || inSuperset;
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: highlight ? PdfDocumentTheme.exerciseGroupBg : null,
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
          highlight: highlight,
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
  final tagLabel = labels.superset;
  final densityTag = dense ? '$tagLabel: ' : '';
  return '$prefix$densityTag$names';
}

/// One dense day slot: section widgets (no Inseparable) + height estimate.
class _DenseDayBlock {
  _DenseDayBlock({
    required this.widgets,
    required this.estimatedHeight,
  });

  final List<pw.Widget> widgets;
  final double estimatedHeight;
}

/// Dense MultiPage body: mobility (optional attach) + packed day batches.
List<pw.Widget> _densePageBodyWidgets(
  WorkoutRoutine routine,
  PdfExportLabels labels, {
  required bool includeMobility,
}) {
  final dayBlocks = _buildDenseDayBlocks(routine, labels);

  final mobilityWidgets = includeMobility
      ? _mobilityWidgets(routine, labels, dense: true)
      : const <pw.Widget>[];

  final populatedSections = routine.mobilitySections
      .where(
        (s) => routine.mobilityItems.any((m) => m.sectionId == s.id),
      )
      .length;
  final mobilityHeight = mobilityWidgets.isEmpty
      ? 0.0
      : estimateMobilityHeight(
          sectionCount: populatedSections,
          itemCount: routine.mobilityItems.length,
          dense: true,
        );

  // First batch uses the tighter page-1 budget (coach band + legend). When
  // short mobility is present, reserve its height so attach can succeed.
  final batches = packConsecutiveByHeightWithFirstPageBudget(
    dayBlocks,
    (b) => b.estimatedHeight,
    firstPageBudget: denseContentBudget(firstPage: true),
    laterPageBudget: denseContentBudget(firstPage: false),
    reservedFirstPageHeight: mobilityHeight,
  );

  final out = <pw.Widget>[];
  if (mobilityWidgets.isNotEmpty &&
      batches.isNotEmpty &&
      canAttachMobilityToFirstBatch(
        mobilityHeight: mobilityHeight,
        firstBatchHeight: batches.first.fold<double>(
          0,
          (sum, b) => sum + b.estimatedHeight,
        ),
        firstPageBudget: denseContentBudget(firstPage: true),
      )) {
    out.add(
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            ...mobilityWidgets,
            for (final day in batches.first) ...day.widgets,
          ],
        ),
      ),
    );
    for (final batch in batches.skip(1)) {
      out.add(_wrapDenseDayBatch(batch));
    }
    return out;
  }

  // Keep prior behavior when mobility does not fit with the first batch.
  out.addAll(mobilityWidgets);
  for (final batch in batches) {
    out.add(_wrapDenseDayBatch(batch));
  }
  return out;
}

pw.Widget _wrapDenseDayBatch(List<_DenseDayBlock> batch) {
  // One Inseparable per batch — never per-day, never canSpan.
  return pw.Inseparable(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        for (final day in batch) ...day.widgets,
      ],
    ),
  );
}

List<_DenseDayBlock> _buildDenseDayBlocks(
  WorkoutRoutine routine,
  PdfExportLabels labels,
) {
  const dense = true;
  final weeks = routine.weeks;
  if (weeks.isEmpty) return [];

  final blocks = <_DenseDayBlock>[];
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

    final dayRows = buildDenseDayRows(weeks: weeks, dayIndex: d);
    if (dayRows.isEmpty) {
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
        repeat: true,
        decoration: pw.BoxDecoration(color: PdfDocumentTheme.tableHeaderBg),
        children: headerCells,
      ),
    ];

    for (var r = 0; r < dayRows.length; r++) {
      final dayRow = dayRows[r];
      final block = dayRow.labelBlock;

      final label = block == null
          ? ''
          : _blockRowLabel(
              block,
              rowNumber: r + 1,
              labels: labels,
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

    blocks.add(
      _DenseDayBlock(
        estimatedHeight: estimateDenseDayHeight(
          rowCount: dayRows.length,
          weekCount: weeks.length,
        ),
        // Day UI only — batch wrapper owns Inseparable (no canSpan).
        widgets: [
          PdfDocumentTheme.sectionTitle(dayTitle, dense: dense),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfDocumentTheme.border,
              width: 0.35,
            ),
            columnWidths: columnWidths,
            children: tableRows,
          ),
          pw.SizedBox(height: 8),
        ],
      ),
    );
  }

  return blocks;
}

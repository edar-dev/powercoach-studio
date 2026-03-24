import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/workout_routine_model.dart';
import '../../customers/data/models/customer.dart';

/// PDF programming layout: per-week sections vs per-day progression columns.
enum WorkoutPdfLayout {
  /// One section per week, then days (current behavior).
  canonical,

  /// One section per day slot; columns are weeks (progression view).
  compact,
}

// PDF layout aligned to Stitch prototype "Generated Screen" (project 15732533611981325178, screen 80e27a86da484d75b1dc9481a2d61b1c).
// design/stitch-assets/generated-pdf-screen.html | .png
const double _pdfHeaderFontSize = 10;
const double _pdfTitleFontSize = 18;
const double _pdfSectionFontSize = 14;
const double _pdfDayFontSize = 12;
const double _pdfTableFontSize = 10;
const double _pdfSupersetFontSize = 9;
const double _pdfFooterFontSize = 8;
const double _pdfCellPadding = 8;
const double _pdfCompactTableFontSize = 8;
const double _pdfCompactCellPadding = 5;
final PdfColor _pdfTableHeaderBg = PdfColor.fromHex('#f3f4f6');
final PdfColor _pdfBorder = PdfColor.fromHex('#e5e7eb');
final PdfColor _pdfSupersetBg = PdfColor.fromHex('#f9fafb');
final PdfColor _pdfFooterMuted = PdfColor.fromHex('#9ca3af');

/// Generates a PDF from [WorkoutRoutine]. Optionally uses [Customer] pdfHeader when [Customer.useCustomPdfHeader] is true.
/// [layout] selects canonical (per week) or compact (per day slot, weeks as columns).
/// Returns the path to the saved file in the temp directory for sharing.
Future<String> exportWorkoutRoutineToPdf(
  WorkoutRoutine routine, {
  Customer? customer,
  WorkoutPdfLayout layout = WorkoutPdfLayout.canonical,
}) async {
  final doc = pw.Document();
  final hasCustomHeader = customer != null &&
      customer.useCustomPdfHeader &&
      (customer.pdfHeader?.trim().isNotEmpty ?? false);
  final headerText = hasCustomHeader ? customer.pdfHeader!.trim() : null;

  final programming = layout == WorkoutPdfLayout.canonical
      ? _canonicalProgrammingWidgets(routine)
      : _compactProgrammingWidgets(routine);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (headerText != null)
            pw.Text(
              headerText,
              style: pw.TextStyle(fontSize: _pdfHeaderFontSize, color: _pdfFooterMuted),
            ),
          if (headerText != null) pw.SizedBox(height: 4),
          pw.Text(
            routine.name,
            style: pw.TextStyle(
              fontSize: _pdfTitleFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
        ],
      ),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 24),
        child: pw.Text(
          'This document is intended for the designated client only. Please consult a physician before beginning any new exercise program.',
          style: pw.TextStyle(fontSize: _pdfFooterFontSize, color: _pdfFooterMuted),
          textAlign: pw.TextAlign.center,
        ),
      ),
      build: (context) => [
        ..._mobilityWidgets(routine),
        ...programming,
      ],
    ),
  );

  final bytes = await doc.save();
  final dir = await getTemporaryDirectory();
  final sanitizedName = routine.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  final sanitized = sanitizedName.isEmpty ? 'workout_plan' : sanitizedName;
  final file = File('${dir.path}/${sanitized}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(bytes);
  return file.path;
}

List<pw.Widget> _mobilityWidgets(WorkoutRoutine routine) {
  if (routine.mobilityItems.isEmpty) return [];
  return [
    ...routine.mobilitySections.expand((section) {
      final items = routine.mobilityItems.where((m) => m.sectionId == section.id).toList();
      if (items.isEmpty) return <pw.Widget>[];
      return [
        pw.Text(
          section.name.isNotEmpty ? section.name : 'Mobility',
          style: pw.TextStyle(
            fontSize: _pdfSectionFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...items.map(
          (m) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              '${m.title}: ${m.subtitle}',
              style: pw.TextStyle(fontSize: _pdfTableFontSize),
            ),
          ),
        ),
        pw.SizedBox(height: 12),
      ];
    }),
    pw.SizedBox(height: 16),
  ];
}

List<pw.Widget> _canonicalProgrammingWidgets(WorkoutRoutine routine) {
  return routine.weeks.expand((week) {
    return [
      pw.Text(
        week.name,
        style: pw.TextStyle(
          fontSize: _pdfSectionFontSize,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 8),
      ...week.days.expand((day) {
        return [
          pw.Text(
            day.name,
            style: pw.TextStyle(
              fontSize: _pdfDayFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.all(color: _pdfBorder),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(0.6),
              2: const pw.FlexColumnWidth(0.8),
              3: const pw.FlexColumnWidth(0.8),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: _pdfTableHeaderBg,
                ),
                children: [
                  _cell('Exercise', isHeader: true),
                  _cell('Sets', isHeader: true),
                  _cell('Reps', isHeader: true),
                  _cell('Load/RPE', isHeader: true),
                  _cell('Notes', isHeader: true),
                ],
              ),
              ...partitionExercisesBySuperset(day.exercises).expand((item) {
                if (item is Exercise) {
                  final e = item;
                  final details = e.effectiveSetDetails;
                  if (details.length > 1) {
                    return details.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return pw.TableRow(
                        children: [
                          _cell(i == 0 ? e.name : ''),
                          _cell(i == 0 ? '${details.length}' : ''),
                          _cell(s.displayText.isNotEmpty ? s.displayText : s.reps),
                          _cell(s.displayText.isNotEmpty ? '' : s.rpe),
                          _cell(s.note.isNotEmpty ? s.note : (i == 0 ? e.note : '')),
                        ],
                      );
                    });
                  }
                  return [
                    pw.TableRow(
                      children: [
                        _cell(e.name),
                        _cell(e.sets),
                        _cell(e.reps),
                        _cell(e.rpe),
                        _cell(e.note),
                      ],
                    ),
                  ];
                }
                final group = item as List<Exercise>;
                return [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: _pdfSupersetBg),
                    children: [
                      _cell('Superset', isSupersetHeader: true),
                      _cell(''),
                      _cell(''),
                      _cell(''),
                      _cell(''),
                    ],
                  ),
                  ...group.expand((e) {
                    final details = e.effectiveSetDetails;
                    if (details.length > 1) {
                      return details.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return pw.TableRow(
                          children: [
                            _cell(i == 0 ? e.name : ''),
                            _cell(i == 0 ? '${details.length}' : ''),
                            _cell(s.displayText.isNotEmpty ? s.displayText : s.reps),
                            _cell(s.displayText.isNotEmpty ? '' : s.rpe),
                            _cell(s.note.isNotEmpty ? s.note : (i == 0 ? e.note : '')),
                          ],
                        );
                      });
                    }
                    return [
                      pw.TableRow(
                        children: [
                          _cell(e.name),
                          _cell(e.sets),
                          _cell(e.reps),
                          _cell(e.rpe),
                          _cell(e.note),
                        ],
                      ),
                    ];
                  }),
                ];
              }),
            ],
          ),
          pw.SizedBox(height: 12),
        ];
      }),
      pw.SizedBox(height: 12),
    ];
  }).toList();
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
  if (g.isEmpty) return 'Superset';
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

List<pw.Widget> _compactProgrammingWidgets(WorkoutRoutine routine) {
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
      return 'Day ${d + 1}';
    }();

    out.add(
      pw.Text(
        dayTitle,
        style: pw.TextStyle(
          fontSize: _pdfSectionFontSize,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
    out.add(pw.SizedBox(height: 8));

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
      _compactCell('Exercise', isHeader: true),
      ...weeks.asMap().entries.map(
            (e) => _compactCell(_weekColumnHeader(e.value, e.key), isHeader: true),
          ),
    ];

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _pdfTableHeaderBg),
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
      if (label.isEmpty) label = '—';

      final cells = <pw.Widget>[
        _compactCell(label),
        ...weeks.map((w) {
          if (d >= w.days.length) {
            return _compactCell('—');
          }
          final blocks = _blocksForDay(w.days[d]);
          if (r >= blocks.length) {
            return _compactCell('');
          }
          return _compactCell(_blockPrescriptionCompact(blocks[r]));
        }),
      ];
      tableRows.add(pw.TableRow(children: cells));
    }

    out.add(
      pw.Table(
        border: pw.TableBorder.all(color: _pdfBorder),
        columnWidths: columnWidths,
        children: tableRows,
      ),
    );
    out.add(pw.SizedBox(height: 16));
  }

  return out;
}

pw.Widget _cell(String text, {bool isHeader = false, bool isSupersetHeader = false}) {
  final fontSize = isSupersetHeader ? _pdfSupersetFontSize : _pdfTableFontSize;
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(horizontal: _pdfCellPadding, vertical: _pdfCellPadding),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: (isHeader || isSupersetHeader) ? pw.FontWeight.bold : null,
      ),
    ),
  );
}

pw.Widget _compactCell(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(horizontal: _pdfCompactCellPadding, vertical: _pdfCompactCellPadding),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: _pdfCompactTableFontSize,
        fontWeight: isHeader ? pw.FontWeight.bold : null,
      ),
    ),
  );
}

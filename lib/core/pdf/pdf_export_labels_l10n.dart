import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'pdf_export_labels.dart';
import 'pdf_text_sanitize.dart';

extension PdfExportLabelsL10n on AppLocalizations {
  PdfExportLabels toPdfExportLabels() {
    return PdfExportLabels(
      brandName: pdfBrandName,
      coachPrefix: pdfCoachPrefix,
      colExercise: pdfColExercise,
      colSets: pdfColSets,
      colReps: pdfColReps,
      colLoadRpe: pdfColLoadRpe,
      colNotes: pdfColNotes,
      mobilityFallback: pdfMobilitySection,
      superset: pdfSuperset,
      circuit: pdfCircuit,
      emom: pdfEmom,
      dayNumber: pdfDayNumber,
      emptyValue: pdfEmptyValue,
      footerDisclaimer: pdfFooterDisclaimer,
      pageOf: pdfPageOf,
      generatedOn: pdfGeneratedOn,
      measurementDate: measurementDate,
      measurementBodyFat: measurementBodyFat,
      measurementMuscleMass: measurementMuscleMass,
      measurementWaist: measurementWaist,
      measurementSquat: measurementSquat,
      measurementBench: measurementBench,
      exportGenerating: pdfExportGenerating,
      measurementRecordCount: pdfMeasurementRecordCount,
      denseWeekShort: pdfDenseWeekShort,
      denseAllWeeks: pdfDenseAllWeeks,
      denseDitto: sanitizePdfText(pdfDenseDitto),
      denseWeekLegendEntry: (weekIndex, weekName) => sanitizePdfText(
        pdfDenseWeekLegendEntry(weekIndex, weekName),
      ),
      denseWeeksSpan: (first, last) =>
          sanitizePdfText(pdfDenseWeeksSpan(first, last)),
      denseLegend: sanitizePdfText(pdfDenseLegend),
      pdfClientPlanFor: (name) => sanitizePdfText(pdfClientPlanFor(name)),
      pdfPlanPeriod: (start, end) => sanitizePdfText(pdfPlanPeriod(start, end)),
      pdfPlanPeriodOpen: (start) => sanitizePdfText(pdfPlanPeriodOpen(start)),
      formatPlanDate: (date) =>
          sanitizePdfText(DateFormat.yMd(localeName).format(date)),
    );
  }
}

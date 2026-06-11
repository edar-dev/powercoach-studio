import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'pdf_export_labels.dart';

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
      denseDitto: pdfDenseDitto,
      denseWeekLegendEntry: pdfDenseWeekLegendEntry,
      denseWeeksSpan: pdfDenseWeeksSpan,
      denseLegend: pdfDenseLegend,
      pdfClientPlanFor: pdfClientPlanFor,
      pdfPlanPeriod: pdfPlanPeriod,
      pdfPlanPeriodOpen: pdfPlanPeriodOpen,
      formatPlanDate: (date) => DateFormat.yMd(localeName).format(date),
    );
  }
}

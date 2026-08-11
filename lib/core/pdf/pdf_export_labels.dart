/// Localized strings embedded in generated PDF documents.
class PdfExportLabels {
  const PdfExportLabels({
    required this.brandName,
    required this.coachPrefix,
    required this.colExercise,
    required this.colSets,
    required this.colReps,
    required this.colLoadRpe,
    required this.colNotes,
    required this.mobilityFallback,
    required this.superset,
    required this.circuit,
    required this.emom,
    required this.dayNumber,
    required this.emptyValue,
    required this.footerDisclaimer,
    required this.pageOf,
    required this.generatedOn,
    required this.measurementDate,
    required this.measurementBodyFat,
    required this.measurementMuscleMass,
    required this.measurementWaist,
    required this.measurementSquat,
    required this.measurementBench,
    required this.exportGenerating,
    required this.measurementRecordCount,
    required this.denseWeekShort,
    required this.denseAllWeeks,
    required this.denseDitto,
    required this.denseWeekLegendEntry,
    required this.denseWeeksSpan,
    required this.denseLegend,
    required this.pdfClientPlanFor,
    required this.pdfPlanPeriod,
    required this.pdfPlanPeriodOpen,
    required this.formatPlanDate,
  });

  final String brandName;
  final String coachPrefix;
  final String colExercise;
  final String colSets;
  final String colReps;
  final String colLoadRpe;
  final String colNotes;
  final String mobilityFallback;
  final String superset;
  final String circuit;
  final String emom;
  final String Function(int dayIndex) dayNumber;
  final String emptyValue;
  final String footerDisclaimer;
  final String Function(int current, int total) pageOf;
  final String Function(String date) generatedOn;
  final String measurementDate;
  final String measurementBodyFat;
  final String measurementMuscleMass;
  final String measurementWaist;
  final String measurementSquat;
  final String measurementBench;
  final String exportGenerating;
  final String Function(int count) measurementRecordCount;
  final String Function(int weekIndex) denseWeekShort;
  final String denseAllWeeks;
  final String denseDitto;
  final String Function(int weekIndex, String weekName) denseWeekLegendEntry;
  final String Function(int firstWeek, int lastWeek) denseWeeksSpan;
  final String denseLegend;
  final String Function(String name) pdfClientPlanFor;
  final String Function(String start, String end) pdfPlanPeriod;
  final String Function(String start) pdfPlanPeriodOpen;
  final String Function(DateTime date) formatPlanDate;
}

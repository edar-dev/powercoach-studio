/// Localized strings for customer progress CSV export narrative + labels.
class CustomerProgressExportLabels {
  const CustomerProgressExportLabels({
    required this.title,
    required this.generatedOn,
    required this.narrativeSummary,
    required this.narrativeLastSession,
    required this.narrativeRecentPr,
    required this.weeklyCompleted,
    required this.weeklyMissed,
    required this.weeklyNoData,
    required this.dataSection,
  });

  final String title;
  final String generatedOn;
  final String Function(String adherence, int completed, int skipped)
      narrativeSummary;
  final String Function(String when) narrativeLastSession;
  final String Function(String name, String value, String unit)
      narrativeRecentPr;
  final String weeklyCompleted;
  final String weeklyMissed;
  final String weeklyNoData;
  final String dataSection;
}

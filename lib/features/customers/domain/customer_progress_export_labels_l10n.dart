import '../../../l10n/app_localizations.dart';
import 'customer_progress_export_labels.dart';

extension CustomerProgressExportLabelsL10n on AppLocalizations {
  CustomerProgressExportLabels toCustomerProgressExportLabels() {
    return CustomerProgressExportLabels(
      title: customerProgressExportTitle,
      generatedOn: customerProgressExportGeneratedOn,
      narrativeSummary: customerProgressNarrativeSummary,
      narrativeLastSession: customerProgressNarrativeLastSession,
      narrativeRecentPr: customerProgressNarrativeRecentPr,
      weeklyCompleted: customerProgressExportWeeklyCompleted,
      weeklyMissed: customerProgressExportWeeklyMissed,
      weeklyNoData: customerProgressExportWeeklyNoData,
      dataSection: customerProgressExportDataSection,
    );
  }
}

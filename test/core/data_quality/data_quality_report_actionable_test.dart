import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/data_quality/data_quality.dart';

void main() {
  group('DataQualityReport.actionableFindings', () {
    test('keeps errors and warnings, drops info, sorts error first', () {
      final report = DataQualityReport(
        findings: const [
          DataQualityFinding(
            ruleId: DataQualityRuleIds.preferencesDecode,
            severity: DataQualitySeverity.info,
            message: 'info noise',
          ),
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.warning,
            message: 'broken pin',
          ),
          DataQualityFinding(
            ruleId: DataQualityRuleIds.orphanReference,
            severity: DataQualitySeverity.error,
            message: 'orphan plan',
          ),
        ],
        scannedEntityCount: 3,
        generatedAt: DateTime.utc(2026, 10, 9),
      );

      final actionable = report.actionableFindings;
      expect(actionable, hasLength(2));
      expect(actionable.first.severity, DataQualitySeverity.error);
      expect(actionable.first.message, 'orphan plan');
      expect(actionable.last.severity, DataQualitySeverity.warning);
      expect(actionable.any((f) => f.severity == DataQualitySeverity.info), isFalse);
    });

    test('empty when only info findings', () {
      final report = DataQualityReport(
        findings: const [
          DataQualityFinding(
            ruleId: DataQualityRuleIds.preferencesDecode,
            severity: DataQualitySeverity.info,
            message: 'malformed list',
          ),
        ],
        scannedEntityCount: 0,
        generatedAt: DateTime.utc(2026, 10, 9),
      );
      expect(report.actionableFindings, isEmpty);
    });
  });
}

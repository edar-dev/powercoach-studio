import 'data_quality_finding.dart';
import 'data_quality_severity.dart';

/// Immutable scan result. Does not repair or delete entities.
class DataQualityReport {
  const DataQualityReport({
    required this.findings,
    required this.scannedEntityCount,
    required this.generatedAt,
  });

  final List<DataQualityFinding> findings;
  final int scannedEntityCount;
  final DateTime generatedAt;

  bool get hasErrors =>
      findings.any((f) => f.severity == DataQualitySeverity.error);

  bool get hasWarnings =>
      findings.any((f) => f.severity == DataQualitySeverity.warning);

  /// Errors and warnings coaches should act on (excludes info noise).
  ///
  /// Sorted error → warning so dashboard Attention can show the worst first.
  List<DataQualityFinding> get actionableFindings {
    final list = findings
        .where(
          (f) =>
              f.severity == DataQualitySeverity.error ||
              f.severity == DataQualitySeverity.warning,
        )
        .toList();
    list.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return list;
  }

  int countBySeverity(DataQualitySeverity severity) =>
      findings.where((f) => f.severity == severity).length;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'scannedEntityCount': scannedEntityCount,
        'findingCount': findings.length,
        'errorCount': countBySeverity(DataQualitySeverity.error),
        'warningCount': countBySeverity(DataQualitySeverity.warning),
        'infoCount': countBySeverity(DataQualitySeverity.info),
        'findings': findings.map((f) => f.toJson()).toList(growable: false),
      };

  /// Compact Markdown summary for CLI / tooling.
  String toMarkdown() {
    final buf = StringBuffer()
      ..writeln('# Data quality report')
      ..writeln()
      ..writeln('- Generated: `${generatedAt.toUtc().toIso8601String()}`')
      ..writeln('- Scanned entities: **$scannedEntityCount**')
      ..writeln('- Findings: **${findings.length}** '
          '(errors: ${countBySeverity(DataQualitySeverity.error)}, '
          'warnings: ${countBySeverity(DataQualitySeverity.warning)}, '
          'info: ${countBySeverity(DataQualitySeverity.info)})')
      ..writeln();

    if (findings.isEmpty) {
      buf.writeln('_No findings._');
      return buf.toString();
    }

    buf.writeln('| Severity | Rule | Entity | Message |');
    buf.writeln('|---|---|---|---|');
    for (final f in findings) {
      final ref = [
        if (f.entityType != null) f.entityType!.name,
        if (f.entityId != null && f.entityId!.isNotEmpty) f.entityId,
      ].join(':');
      final msg = f.message.replaceAll('|', '\\|').replaceAll('\n', ' ');
      buf.writeln('| ${f.severity.name} | `${f.ruleId}` | `$ref` | $msg |');
    }
    return buf.toString();
  }
}

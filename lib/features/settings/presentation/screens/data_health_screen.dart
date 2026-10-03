import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/data_quality/data_quality.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../core/ui/widgets/stitch_secondary_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../data_health_controller.dart';

/// Settings sub-page: local data quality scan + safe prefs orphan repair.
class DataHealthScreen extends StatefulWidget {
  const DataHealthScreen({super.key, this.controller});

  /// Optional inject for tests; defaults to live stores.
  final DataHealthController? controller;

  @override
  State<DataHealthScreen> createState() => _DataHealthScreenState();
}

class _DataHealthScreenState extends State<DataHealthScreen> {
  late final DataHealthController _controller =
      widget.controller ?? DataHealthController();

  bool _isScanning = true;
  bool _isRepairing = false;
  DataQualityReport? _report;
  String? _errorMessage;
  bool _notSignedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runScan();
    });
  }

  Future<void> _runScan() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      setState(() {
        _isScanning = false;
        _notSignedIn = true;
        _report = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _notSignedIn = false;
      _errorMessage = null;
    });

    try {
      final report = await _controller.scan(user.id);
      if (!mounted) return;
      setState(() {
        _report = report;
        _isScanning = false;
      });
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _report = null;
        _errorMessage = AppLocalizations.of(context).dataHealthScanFailed;
      });
    }
  }

  Future<void> _clearOrphanPrefs() async {
    final report = _report;
    if (report == null || !DataHealthController.hasPreferenceOrphans(report)) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.dataHealthClearOrphanPrefsConfirmTitle,
      message: l10n.dataHealthClearOrphanPrefsConfirmMessage,
      confirmLabel: l10n.dataHealthClearOrphanPrefs,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isRepairing = true);
    try {
      final count = await _controller.clearPreferencesOrphans(report);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dataHealthClearedOrphansSnack(count)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _runScan();
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dataHealthScanFailed),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRepairing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final report = _report;
    final hasPrefsOrphans =
        report != null && DataHealthController.hasPreferenceOrphans(report);

    return Scaffold(
      backgroundColor: MarketingDarkColors.stitchPageBg,
      appBar: StitchSecondaryAppBar(
        title: l10n.dataHealthTitle,
        actions: [
          IconButton(
            tooltip: l10n.dataHealthRescanAction,
            onPressed: _isScanning || _isRepairing ? null : _runScan,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(
          context: context,
          l10n: l10n,
          theme: theme,
          hasPrefsOrphans: hasPrefsOrphans,
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AppLocalizations l10n,
    required ThemeData theme,
    required bool hasPrefsOrphans,
  }) {
    if (_notSignedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.dataHealthNotSignedIn,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: MarketingDarkColors.slate400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.headerLogin),
              ),
            ],
          ),
        ),
      );
    }

    if (_isScanning && _report == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = _report;
    final findings = report == null
        ? const <DataQualityFinding>[]
        : _sortedFindings(report.findings);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.dataHealthSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: MarketingDarkColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isScanning ? null : _runScan,
                      child: Text(l10n.dataHealthScanAction),
                    ),
                  ] else if (report != null) ...[
                    Text(
                      report.findings.isEmpty
                          ? l10n.dataHealthNoIssues
                          : l10n.dataHealthFindingsCount(report.findings.length),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: MarketingDarkColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.scannedEntityCount} entities · '
                      '${report.generatedAt.toLocal()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MarketingDarkColors.slate500,
                      ),
                    ),
                    if (_isScanning) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                    if (findings.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      for (final finding in findings) ...[
                        _FindingTile(finding: finding),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: FilledButton.icon(
            onPressed: hasPrefsOrphans && !_isScanning && !_isRepairing
                ? _clearOrphanPrefs
                : null,
            icon: _isRepairing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cleaning_services_outlined, size: 18),
            label: Text(l10n.dataHealthClearOrphanPrefs),
          ),
        ),
      ],
    );
  }

  static List<DataQualityFinding> _sortedFindings(
    List<DataQualityFinding> findings,
  ) {
    final sorted = List<DataQualityFinding>.from(findings);
    sorted.sort((a, b) {
      final bySeverity =
          _severityRank(a.severity).compareTo(_severityRank(b.severity));
      if (bySeverity != 0) return bySeverity;
      return a.ruleId.compareTo(b.ruleId);
    });
    return sorted;
  }

  static int _severityRank(DataQualitySeverity severity) {
    switch (severity) {
      case DataQualitySeverity.error:
        return 0;
      case DataQualitySeverity.warning:
        return 1;
      case DataQualitySeverity.info:
        return 2;
    }
  }
}

class _FindingTile extends StatelessWidget {
  const _FindingTile({required this.finding});

  final DataQualityFinding finding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _severityColor(finding.severity);
    final entityRef = [
      if (finding.entityType != null) finding.entityType!.name,
      if (finding.entityId != null && finding.entityId!.isNotEmpty)
        finding.entityId,
    ].join(':');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  finding.severity.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  finding.ruleId,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: MarketingDarkColors.slate400,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            finding.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.text,
            ),
          ),
          if (entityRef.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entityRef,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate500,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _severityColor(DataQualitySeverity severity) {
    switch (severity) {
      case DataQualitySeverity.error:
        return const Color(0xFFF87171);
      case DataQualitySeverity.warning:
        return const Color(0xFFFBBF24);
      case DataQualitySeverity.info:
        return const Color(0xFF60A5FA);
    }
  }
}

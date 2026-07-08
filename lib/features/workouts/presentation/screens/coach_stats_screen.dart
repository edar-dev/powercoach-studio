import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import '../../domain/coach_stats_loader.dart';
import '../widgets/coach_stats_adherence_chart.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';

/// Coach-facing adherence and activity KPIs.
class CoachStatsScreen extends StatefulWidget {
  const CoachStatsScreen({super.key});

  @override
  State<CoachStatsScreen> createState() => _CoachStatsScreenState();
}

class _CoachStatsScreenState extends State<CoachStatsScreen> {
  final CoachStatsLoader _loader = CoachStatsLoader();
  int _periodDays = 7;
  bool _loading = true;
  CoachStatsSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final snapshot = await _loader.load(periodDays: _periodDays);
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  void _setPeriod(int days) {
    if (_periodDays == days) return;
    setState(() => _periodDays = days);
    _load();
  }

  Future<void> _exportCsv(AppLocalizations l10n) async {
    final snapshot = _snapshot;
    if (snapshot == null) return;

    final buffer = StringBuffer()
      ..writeln('period,${_periodDays}d')
      ..writeln(
        'adherence,${snapshot.adherenceRate?.toStringAsFixed(3) ?? ''}',
      )
      ..writeln('completed,${snapshot.completedSessions}')
      ..writeln('skipped,${snapshot.skippedSessions}')
      ..writeln('active_clients,${snapshot.activeClients}')
      ..writeln('date,completed_count');

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final point in snapshot.dailyCompleted) {
      buffer.writeln(
        '${dateFormat.format(point.date)},${point.completedCount}',
      );
    }

    await Share.share(
      buffer.toString(),
      subject: l10n.coachStatsExportCsvSubject,
      sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
    );
  }

  void _onDaySelected(CoachStatsDailyPoint point, AppLocalizations l10n) {
    final dateLabel = DateFormat.yMMMd(l10n.localeName).format(point.date);
    showAppSnackBar(
      context,
      content: Text(l10n.coachStatsChartDaySummary(dateLabel, point.completedCount)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final snapshot = _snapshot;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: StitchSecondaryAppBar(
        title: l10n.coachStatsTitle,
        actions: [
          if (snapshot != null)
            IconButton(
              tooltip: l10n.coachStatsExportCsv,
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: () => _exportCsv(l10n),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 7,
                        label: Text(l10n.coachStatsPeriod7d),
                      ),
                      ButtonSegment(
                        value: 30,
                        label: Text(l10n.coachStatsPeriod30d),
                      ),
                    ],
                    selected: {_periodDays},
                    onSelectionChanged: (values) {
                      if (values.isEmpty) return;
                      _setPeriod(values.first);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (snapshot != null) ...[
                    _KpiCard(
                      label: l10n.coachStatsAdherence,
                      value: snapshot.adherenceRate == null
                          ? '—'
                          : '${(snapshot.adherenceRate! * 100).round()}%',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            label: l10n.coachStatsCompletedSessions,
                            value: '${snapshot.completedSessions}',
                            icon: Icons.check_circle_outline,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiCard(
                            label: l10n.coachStatsSkippedSessions,
                            value: '${snapshot.skippedSessions}',
                            icon: Icons.remove_circle_outline,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _KpiCard(
                      label: l10n.coachStatsActiveClients,
                      value: '${snapshot.activeClients}',
                      icon: Icons.people_outline,
                    ),
                    const SizedBox(height: 16),
                    CoachStatsAdherenceChart(
                      points: snapshot.dailyCompleted,
                      l10n: l10n,
                      onDaySelected: (point) => _onDaySelected(point, l10n),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Row(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: (compact
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.headlineMedium)
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

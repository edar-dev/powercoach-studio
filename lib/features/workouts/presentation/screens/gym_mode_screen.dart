import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../dashboard/data/dashboard_snapshot_loader.dart';
import '../../../dashboard/domain/dashboard_snapshot.dart';

/// Gym mode — full-page list of today's scheduled sessions, optimized for
/// glanceable use on the gym floor. Tapping a session opens [GymSessionScreen].
class GymModeScreen extends StatefulWidget {
  const GymModeScreen({super.key, this.loadSnapshot});

  /// When set (tests), skips repositories and returns this future instead.
  final Future<DashboardSnapshot> Function(String unknownClientLabel)?
  loadSnapshot;

  @override
  State<GymModeScreen> createState() => _GymModeScreenState();
}

class _GymModeScreenState extends State<GymModeScreen> {
  final DashboardSnapshotLoader _loader = DashboardSnapshotLoader();
  DashboardSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    final snap = widget.loadSnapshot != null
        ? await widget.loadSnapshot!(l10n.dashboardUnknownClient)
        : await _loader.load(
            unknownClientLabel: l10n.dashboardUnknownClient,
            untitledWorkoutLabel: l10n.dashboardUntitledWorkout,
          );
    if (!mounted) return;
    setState(() {
      _snapshot = snap;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final snap = _snapshot;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: Text(
          l10n.gymModeTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading && snap == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, theme, cs, l10n, snap),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    DashboardSnapshot? snap,
  ) {
    if (snap == null || snap.hasError) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Center(
            child: Text(
              l10n.dashboardLoadError,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final items = snap.todayItems;
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.event_available_outlined,
            size: 48,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.gymModeEmptyToday,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final localeName = l10n.localeName;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final weekdayLabel = DateFormat(
          'EEE dd MMM',
          localeName,
        ).format(item.date);
        final programLabel = item.programName.trim().isEmpty
            ? l10n.dashboardUntitledWorkout
            : item.programName;
        return _GymSessionCard(
          theme: theme,
          colorScheme: cs,
          clientName: item.clientName,
          programName: programLabel,
          sessionLabel: item.sessionLabel,
          dateLabel: weekdayLabel,
          onTap: () {
            HapticFeedback.mediumImpact();
            navigateTo(
              context,
              gymSessionPath(
                customerId: item.customerId,
                planId: item.planId,
                weekIndex: item.weekIndex,
                dayIndex: item.dayIndex,
                date: item.date,
              ),
            );
          },
        );
      },
    );
  }
}

class _GymSessionCard extends StatelessWidget {
  const _GymSessionCard({
    required this.theme,
    required this.colorScheme,
    required this.clientName,
    required this.programName,
    required this.sessionLabel,
    required this.dateLabel,
    required this.onTap,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String clientName;
  final String programName;
  final String sessionLabel;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$programName · $sessionLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.fitness_center,
                color: StitchM3Theme.accent,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';

/// Lista completa "Today's Schedule" – route /dashboard/schedule.
/// Dati mock; tap su una sessione apre il dettaglio.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const List<({String time, String period, String client, String program})> _items = [
    (time: '08:00', period: 'AM', client: 'Marcus Wright', program: 'Hypertrophy - Legs'),
    (time: '10:30', period: 'AM', client: 'Sarah Jenkins', program: 'Mobility & Core'),
    (time: '02:00', period: 'PM', client: 'David Chen', program: 'Push Day (A)'),
    (time: '05:15', period: 'PM', client: 'Emma Thompson', program: 'HIIT - Full Body'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          "Today's Schedule",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScheduleTile(
              theme: theme,
              cs: cs,
              time: item.time,
              period: item.period,
              clientName: item.client,
              programName: item.program,
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push(
                  Uri(
                    path: '/dashboard/schedule/detail',
                    queryParameters: {
                      'time': item.time,
                      'period': item.period,
                      'client': item.client,
                      'program': item.program,
                    },
                  ).toString(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.theme,
    required this.cs,
    required this.time,
    required this.period,
    required this.clientName,
    required this.programName,
    required this.onTap,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String time;
  final String period;
  final String clientName;
  final String programName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    period,
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programName,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

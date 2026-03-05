import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';

/// Dettaglio di una sessione dello schedule – route /dashboard/schedule/detail?time=...&period=...&client=...&program=...
class ScheduleDetailScreen extends StatelessWidget {
  const ScheduleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final uri = GoRouterState.of(context).uri;
    final time = uri.queryParameters['time'] ?? '–';
    final period = uri.queryParameters['period'] ?? '';
    final client = uri.queryParameters['client'] ?? '–';
    final program = uri.queryParameters['program'] ?? '–';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
        title: Text(
          'Session',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$time $period', style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text(client, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text(program, style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Session details will appear here when the schedule API is connected.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

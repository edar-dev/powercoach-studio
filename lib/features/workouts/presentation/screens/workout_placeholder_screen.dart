import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';

/// Placeholder for Workout Builder bottom nav: Library, Diary, Stats,
/// or for other routes (e.g. exercise-library) with custom back destination.
/// Shows a "Coming soon" message and back navigation.
class WorkoutPlaceholderScreen extends StatelessWidget {
  const WorkoutPlaceholderScreen({
    super.key,
    required this.title,
    this.backRoute,
    this.backLabel,
  });

  final String title;
  /// When set, back arrow and bottom button navigate here instead of /workouts/builder.
  final String? backRoute;
  /// Label for the bottom button when [backRoute] is set (e.g. "Back to Dashboard").
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(backRoute ?? '/workouts/builder');
            }
          },
        ),
        title: Text(
          title,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 64, color: cs.onSurfaceVariant),
              const SizedBox(height: 24),
              Text(
                'Coming soon',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This section is not yet implemented.',
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.go(backRoute ?? '/workouts/builder');
                },
                icon: const Icon(Icons.arrow_back, size: 20),
                label: Text(backLabel ?? 'Back to Builder'),
                style: FilledButton.styleFrom(
                  backgroundColor: StitchM3Theme.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

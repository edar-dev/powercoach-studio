import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Shared card shell for login, registration, and password recovery screens.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    this.headerIcon = Icons.bolt,
    this.headline,
    this.subtitle,
    required this.child,
  });

  final IconData headerIcon;
  final String? headline;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: StitchM3Theme.authCardMaxWidth),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          border: Border.all(color: cs.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: StitchM3Theme.authHeaderPadding,
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: StitchM3Theme.accent,
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                    ),
                    child: Icon(headerIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PowerCoach Studio',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: StitchM3Theme.authCardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (headline != null) ...[
                    Text(
                      headline!,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

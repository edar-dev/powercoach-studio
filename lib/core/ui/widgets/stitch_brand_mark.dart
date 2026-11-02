import 'package:flutter/material.dart';

import '../../theme/stitch_m3_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Compact PowerCoach logo badge used in shell rail and app bars.
class StitchBrandMark extends StatelessWidget {
  const StitchBrandMark({
    super.key,
    this.size = 32,
    this.showTitle = false,
    this.onTap,
  });

  static const String logoAsset = 'assets/images/powercoach_logo.png';

  final double size;
  final bool showTitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final badge = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _FallbackLogoBadge(size: size),
      ),
    );

    Widget child = badge;
    if (showTitle) {
      child = Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          badge,
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              l10n.appTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return child;

    return Tooltip(
      message: l10n.navHomeTooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: child,
        ),
      ),
    );
  }
}

class _FallbackLogoBadge extends StatelessWidget {
  const _FallbackLogoBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StitchM3Theme.logoStart, StitchM3Theme.logoEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text(
        'PCS',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.375,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

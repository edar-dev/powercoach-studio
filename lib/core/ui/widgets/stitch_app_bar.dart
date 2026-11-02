import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routing/app_navigation.dart';
import '../../routing/app_paths.dart';
import '../../theme/stitch_m3_theme.dart';
import '../../../l10n/app_localizations.dart';

/// App bar Stitch: optional logo + titolo, bordo inferiore, solo Material.
///
/// On tablet+ inside [PrimaryShellScaffold], set [showLogo] to false — the
/// [NavigationRail] is the primary chrome and logo/Home is redundant.
///
/// Set [showTitle] to false when the page body already owns the H1 (e.g. Diary
/// hero header) so the bar does not repeat the same heading.
class StitchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StitchAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.onLogoTap,
    this.showLogo = true,
    this.showTitle = true,
    this.bottom,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  /// Logo tap; defaults to navigating to [AppPaths.dashboard].
  final VoidCallback? onLogoTap;

  /// When false, renders title only (slim hub chrome beside the rail).
  final bool showLogo;

  /// When false, omits the title text (page body / hero owns the heading).
  final bool showTitle;

  /// Optional bottom (e.g. [TabBar]); when null, a 1px outline divider is used.
  final PreferredSizeWidget? bottom;

  static const String _logoAsset = 'assets/images/powercoach_logo.png';

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 1;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  void _handleLogoTap(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (onLogoTap != null) {
      onLogoTap!();
      return;
    }
    navigateTo(context, AppPaths.dashboard);
  }

  TextStyle? _titleStyle(ThemeData theme, ColorScheme cs) =>
      theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      );

  Widget? _buildTitle(BuildContext context, ThemeData theme, ColorScheme cs) {
    if (!showLogo && !showTitle) return null;

    final titleText = showTitle
        ? Text(
            title,
            style: _titleStyle(theme, cs),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )
        : null;

    if (!showLogo) return titleText;

    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Tooltip(
          message: l10n.navHomeTooltip,
          child: InkWell(
            onTap: () => _handleLogoTap(context),
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            child: const _LogoBadge(logoAsset: _logoAsset),
          ),
        ),
        if (titleText != null) ...[
          const SizedBox(width: 12),
          Expanded(child: titleText),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: leading,
      title: _buildTitle(context, theme, cs),
      actions: actions,
      bottom: bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: cs.outline, height: 1),
          ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.logoAsset});

  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(
        logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _FallbackLogoBadge(),
      ),
    );
  }
}

class _FallbackLogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StitchM3Theme.logoStart, StitchM3Theme.logoEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
      ),
      alignment: Alignment.center,
      child: const Text(
        'PCS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

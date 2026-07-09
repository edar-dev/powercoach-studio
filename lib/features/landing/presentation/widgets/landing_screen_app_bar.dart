import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// App bar for the landing page with auth-aware actions.
class LandingScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LandingScreenAppBar({
    super.key,
    required this.isLoggedIn,
  });

  final bool isLoggedIn;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      title: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/images/powercoach_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: cs.outline,
          height: 1,
        ),
      ),
      actions: [
        if (isLoggedIn) ...[
          TextButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/customers');
            },
            icon: const Icon(Icons.people_outline, size: 20),
            label: Text(l10n.customersTitle),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                navigateTo(context, '/profile');
              },
              icon: const Icon(Icons.person_outline, size: 20),
              label: Text(l10n.headerProfile),
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/login');
            },
            child: Text(l10n.headerLogin),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                navigateTo(context, '/register');
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.headerJoinNow),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerListEmptyBody extends StatelessWidget {
  const CustomerListEmptyBody({
    super.key,
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.onImportFromContacts,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onImportFromContacts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            StitchM3Theme.accent.withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StitchM3Theme.accent.withValues(alpha: 0.06),
                        border: Border.all(
                          color: StitchM3Theme.accent.withValues(alpha: 0.2),
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Icon(
                        Icons.group_add,
                        size: 80,
                        color: StitchM3Theme.accent.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.customersEmptyTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.customersEmptyMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 32),
                  OutlinedButton(
                    onPressed: onImportFromContacts,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(l10n.customersImportContacts),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

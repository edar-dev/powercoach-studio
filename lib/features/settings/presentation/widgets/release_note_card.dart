import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercoach_studio/core/release_notes/release_note_entry.dart';
import 'package:powercoach_studio/core/release_notes/release_notes_l10n.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../../../l10n/app_localizations.dart';

class ReleaseNoteCard extends StatelessWidget {
  const ReleaseNoteCard({
    super.key,
    required this.entry,
    required this.l10n,
    required this.isInstalledVersion,
    required this.initiallyExpanded,
  });

  final ReleaseNoteEntry entry;
  final AppLocalizations l10n;
  final bool isInstalledVersion;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final monthYear = DateFormat('MMM yyyy', l10n.localeName).format(
      entry.releaseDate.toLocal(),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        side: isInstalledVersion
            ? BorderSide(color: cs.primary.withValues(alpha: 0.5))
            : BorderSide.none,
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${entry.version} · $monthYear',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isInstalledVersion)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                  ),
                  child: Text(
                    l10n.releaseNotesCurrentVersionBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.releaseNotesHighlightsLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...entry.highlightKeys.map(
              (key) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        releaseNoteHighlight(l10n, key),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

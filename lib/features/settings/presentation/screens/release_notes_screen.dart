import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/constants/app_info.dart';
import 'package:powercoach_studio/core/release_notes/release_notes_catalog.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';

import '../../../../l10n/app_localizations.dart';
import '../widgets/release_note_card.dart';

class ReleaseNotesScreen extends StatelessWidget {
  const ReleaseNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.releaseNotesTitle),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Card(
            elevation: 0,
            color: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.releaseNotesInstalledVersion(kAppVersionLabel),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...kReleaseNotesCatalog.map(
            (entry) => ReleaseNoteCard(
              entry: entry,
              l10n: l10n,
              isInstalledVersion: entry.version == kAppVersionLabel,
              initiallyExpanded: entry.version == kAppVersionLabel,
            ),
          ),
        ],
      ),
    );
  }
}

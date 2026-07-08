import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ExerciseLibraryImportSourceSheet extends StatelessWidget {
  const ExerciseLibraryImportSourceSheet({
    super.key,
    required this.onImportDefault,
    required this.onImportHevy,
    required this.onImportCustomFile,
  });

  final VoidCallback onImportDefault;
  final VoidCallback onImportHevy;
  final VoidCallback onImportCustomFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.auto_awesome),
          title: Text(l10n.exerciseLibraryImportSourceDefault),
          subtitle: Text(l10n.exerciseLibraryImportSourceDefaultSubtitle),
          onTap: onImportDefault,
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center),
          title: Text(l10n.exerciseLibraryImportSourceHevy),
          subtitle: Text(l10n.exerciseLibraryImportSourceHevySubtitle),
          onTap: onImportHevy,
        ),
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: Text(l10n.exerciseLibraryImportSourceCustom),
          subtitle: Text(l10n.exerciseLibraryImportSourceCustomSubtitle),
          onTap: onImportCustomFile,
        ),
      ],
    );
  }
}

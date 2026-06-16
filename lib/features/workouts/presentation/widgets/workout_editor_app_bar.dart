import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';

class WorkoutEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const WorkoutEditorAppBar({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.editorMode,
    required this.loading,
    required this.hideExportMenu,
    required this.saving,
    required this.showManualSaveButton,
    required this.onBack,
    required this.onOpenTemplates,
    required this.onImportJson,
    required this.onExport,
    required this.onSave,
    this.saveStatusIndicator,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final bool editorMode;
  final bool loading;
  final bool hideExportMenu;
  final bool saving;
  final bool showManualSaveButton;
  final Future<void> Function() onBack;
  final VoidCallback onOpenTemplates;
  final VoidCallback onImportJson;
  final void Function(String value) onExport;
  final VoidCallback onSave;
  final Widget? saveStatusIndicator;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async => onBack(),
      ),
      title: Text(
        l10n.workoutBuilderTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        if (!editorMode)
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: l10n.workoutTemplatesTitle,
            onPressed: onOpenTemplates,
          ),
        if (!loading)
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: l10n.workoutImportJson,
            onPressed: onImportJson,
          ),
        if (!loading && !hideExportMenu)
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.workoutExport,
            onSelected: onExport,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pdf', child: Text(l10n.workoutExportPdf)),
              PopupMenuItem(
                value: 'excel',
                child: Text(l10n.workoutExportExcel),
              ),
              PopupMenuItem(value: 'json', child: Text(l10n.workoutExportJson)),
              PopupMenuItem(value: 'hevy', child: Text(l10n.workoutExportHevy)),
            ],
          ),
        if (editorMode && !loading && saveStatusIndicator != null)
          saveStatusIndicator!,
        if (showManualSaveButton)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 88,
              height: 36,
              child: FilledButton(
                onPressed: (loading || saving) ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: StitchM3Theme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(l10n.customerSave),
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: colorScheme.outline, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

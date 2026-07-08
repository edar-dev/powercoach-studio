import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/customer_exercise_record_repository.dart';
import '../data/models/customer_exercise_record.dart';

Future<void> deleteCustomerExerciseRecord({
  required BuildContext context,
  required String customerId,
  required CustomerExerciseRecord record,
  CustomerExerciseRecordRepository? repo,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirm = await showAppConfirmDialog(
    context: context,
    title: l10n.recordDeleteConfirm,
    message: '',
    confirmLabel: l10n.customerDelete,
    cancelLabel: l10n.customerCancel,
    destructive: true,
  );
  if (!confirm || !context.mounted) return;

  final repository = repo ?? CustomerExerciseRecordRepository();
  final cs = Theme.of(context).colorScheme;
  try {
    await repository.delete(customerId, record.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.recordDeleted),
        behavior: SnackBarBehavior.floating,
        backgroundColor: StitchM3Theme.accent,
      ),
    );
    Navigator.of(context).pop(true);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.recordDeleteError),
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.errorContainer,
      ),
    );
  }
}

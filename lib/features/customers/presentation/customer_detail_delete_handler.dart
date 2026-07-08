import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../data/customer_repository.dart';

Future<void> deleteCustomerDetail({
  required BuildContext context,
  required String customerId,
  CustomerRepository? customerRepo,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    title: l10n.customerDeleteConfirmTitle,
    message: l10n.customerDeleteConfirmMessage,
    confirmLabel: l10n.customerDelete,
    cancelLabel: l10n.customerCancel,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final repo = customerRepo ?? CustomerRepository();
  try {
    await repo.delete(customerId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.customerDeletedMessage,
          style: TextStyle(color: colorScheme.onPrimaryContainer),
        ),
        backgroundColor: colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/customers');
  } catch (e, stackTrace) {
    await Sentry.captureException(e, stackTrace: stackTrace);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.customerDeleteError,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
        backgroundColor: colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

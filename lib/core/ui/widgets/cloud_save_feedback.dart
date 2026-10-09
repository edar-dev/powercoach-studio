import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../remote/cloud_save_error_message.dart';
import 'app_snackbar.dart';

/// Shows a floating error SnackBar for cloud-save failures.
///
/// Resolves copy via [tryCloudSaveErrorMessage], then [fallbackMessage], then
/// [cloudSaveErrorMessage]. Optional [onRetry] adds a localized Retry action.
void showCloudSaveErrorSnackBar(
  BuildContext context,
  Object error, {
  String? fallbackMessage,
  VoidCallback? onRetry,
}) {
  final l10n = AppLocalizations.of(context);
  final colorScheme = Theme.of(context).colorScheme;
  final message = tryCloudSaveErrorMessage(error, l10n) ??
      fallbackMessage ??
      cloudSaveErrorMessage(error, l10n);

  showAppSnackBar(
    context,
    content: Text(
      message,
      style: TextStyle(color: colorScheme.onErrorContainer),
    ),
    backgroundColor: colorScheme.errorContainer,
    action: onRetry == null
        ? null
        : SnackBarAction(
            label: l10n.cloudSaveRetryAction,
            textColor: colorScheme.onErrorContainer,
            onPressed: onRetry,
          ),
  );
}

/// Shows a floating success SnackBar after a cloud save.
void showCloudSaveSuccessSnackBar(
  BuildContext context, {
  String? message,
}) {
  final l10n = AppLocalizations.of(context);
  final colorScheme = Theme.of(context).colorScheme;
  showAppSnackBar(
    context,
    content: Text(
      message ?? l10n.cloudSaveSucceeded,
      style: TextStyle(color: colorScheme.onPrimaryContainer),
    ),
    backgroundColor: colorScheme.primaryContainer,
  );
}

/// Thin status chip used by workout editor save indicator (and reusable elsewhere).
class CloudSaveStatusChip extends StatelessWidget {
  const CloudSaveStatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.textTheme,
    this.tooltip,
    this.onRetry,
    this.retryLabel,
    this.margin = const EdgeInsets.only(right: 8),
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final TextTheme textTheme;
  final String? tooltip;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final canRetry = onRetry != null && retryLabel != null;
    final tip = tooltip ?? label;

    return Tooltip(
      message: tip,
      child: Semantics(
        button: canRetry,
        label: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: canRetry ? onRetry : null,
          child: Container(
            margin: margin,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: foreground.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (canRetry) ...[
                  const SizedBox(width: 6),
                  Text(
                    retryLabel!,
                    style: textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
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

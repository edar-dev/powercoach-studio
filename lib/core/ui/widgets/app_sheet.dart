import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

typedef AppSheetBodyBuilder = Widget Function(BuildContext context);

/// Standard bottom sheet presenter (mobile-first).
///
/// - Uses Material 3 bottom sheet.
/// - Handles SafeArea + keyboard insets.
/// - Optionally presents as a near full-screen sheet for complex flows.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required AppSheetBodyBuilder bodyBuilder,
  Widget? trailing,
  String? primaryActionLabel,
  VoidCallback? onPrimaryAction,
  bool isDismissible = true,
  bool enableDrag = true,
  bool fullScreen = false,
  /// When true, the sheet sizes to its content instead of filling [maxHeightFraction].
  bool wrapContent = false,
  double maxHeightFraction = 0.88,
}) {
  final cs = Theme.of(context).colorScheme;

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(StitchM3Theme.radiusXl)),
    ),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      final height = MediaQuery.sizeOf(sheetContext).height;
      final maxHeight =
          fullScreen ? height * 0.96 : height * maxHeightFraction;

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: _AppSheetScaffold(
            title: title,
            trailing: trailing,
            primaryActionLabel: primaryActionLabel,
            onPrimaryAction: onPrimaryAction,
            wrapContent: wrapContent,
            child: bodyBuilder(sheetContext),
          ),
        ),
      );
    },
  );
}

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

class _AppSheetScaffold extends StatelessWidget {
  const _AppSheetScaffold({
    required this.title,
    required this.child,
    this.trailing,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.wrapContent = false,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final bool wrapContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final titleStyle = wrapContent
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

    final body = ScrollConfiguration(
      behavior: const _NoGlowScrollBehavior(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16, wrapContent ? 12 : 16, 16, 16),
        child: child,
      ),
    );

    return Column(
      mainAxisSize: wrapContent ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, wrapContent ? 8 : 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (trailing != null) trailing!,
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Container(height: 1, color: cs.outline),
        if (wrapContent) body else Expanded(child: body),
        if (primaryActionLabel != null && onPrimaryAction != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionLabel!),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

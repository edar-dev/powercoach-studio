import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';

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
  /// When false, the body fills remaining height without an outer scroll view
  /// (needed for nested scrollables / Expanded lists).
  bool scrollBody = true,
  double maxHeightFraction = 0.88,
  bool useRootNavigator = false,
}) {
  final cs = Theme.of(context).colorScheme;

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    useSafeArea: true,
    useRootNavigator: useRootNavigator,
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
            scrollBody: scrollBody,
            child: bodyBuilder(sheetContext),
          ),
        ),
      );
    },
  );
}

/// Desktop end-aligned side panel; on narrow viewports falls back to [showAppBottomSheet].
Future<T?> showAppSidePanel<T>({
  required BuildContext context,
  required String title,
  required AppSheetBodyBuilder bodyBuilder,
  Widget? trailing,
  String? primaryActionLabel,
  VoidCallback? onPrimaryAction,
  bool isDismissible = true,
  bool fullScreen = false,
  bool wrapContent = false,
  bool scrollBody = true,
  double maxHeightFraction = 0.88,
  double panelWidth = 420,
  bool useRootNavigator = true,
}) {
  if (!AppBreakpoints.isDesktop(context)) {
    return showAppBottomSheet<T>(
      context: context,
      title: title,
      bodyBuilder: bodyBuilder,
      trailing: trailing,
      primaryActionLabel: primaryActionLabel,
      onPrimaryAction: onPrimaryAction,
      isDismissible: isDismissible,
      fullScreen: fullScreen,
      wrapContent: wrapContent,
      scrollBody: scrollBody,
      maxHeightFraction: maxHeightFraction,
      useRootNavigator: useRootNavigator,
    );
  }

  final cs = Theme.of(context).colorScheme;
  final width = math.min(
    panelWidth,
    MediaQuery.sizeOf(context).width * 0.42,
  );

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    useRootNavigator: useRootNavigator,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: cs.surface,
          elevation: 8,
          child: SafeArea(
            left: false,
            child: SizedBox(
              width: width,
              height: double.infinity,
              child: _AppSheetScaffold(
                title: title,
                trailing: trailing,
                primaryActionLabel: primaryActionLabel,
                onPrimaryAction: onPrimaryAction,
                wrapContent: wrapContent,
                scrollBody: scrollBody,
                child: bodyBuilder(dialogContext),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: offset, child: child);
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
    this.scrollBody = true,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final bool wrapContent;
  final bool scrollBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final titleStyle = wrapContent
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

    final Widget body;
    if (scrollBody) {
      body = ScrollConfiguration(
        behavior: const _NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, wrapContent ? 12 : 16, 16, 16),
          child: child,
        ),
      );
    } else {
      body = Padding(
        padding: EdgeInsets.fromLTRB(16, wrapContent ? 12 : 16, 16, 16),
        child: child,
      );
    }

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

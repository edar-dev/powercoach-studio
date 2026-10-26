import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/settings/post_invite_onboarding_store.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_snapshot.dart';
import '../../domain/post_invite_onboarding_state.dart';
import 'dashboard_surface_card.dart';

/// Dismissible 3-step checklist for coaches after invite (customer → plan → PDF).
class PostInviteOnboardingCard extends StatefulWidget {
  const PostInviteOnboardingCard({
    super.key,
    this.snapshot,
    this.userId,
    this.store,
    this.onDismissed,
  });

  final DashboardSnapshot? snapshot;
  final String? userId;
  final PostInviteOnboardingStore? store;
  final VoidCallback? onDismissed;

  @override
  State<PostInviteOnboardingCard> createState() =>
      _PostInviteOnboardingCardState();
}

class _PostInviteOnboardingCardState extends State<PostInviteOnboardingCard> {
  bool _loaded = false;
  bool _dismissed = false;
  bool _pdfDone = false;

  PostInviteOnboardingStore get _store =>
      widget.store ?? PostInviteOnboardingStore.instance;

  String get _userId =>
      widget.userId ?? SupabaseBootstrap.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void didUpdateWidget(covariant PostInviteOnboardingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.store != widget.store ||
        oldWidget.snapshot != widget.snapshot) {
      // Reload prefs when dashboard snapshot refreshes (e.g. after PDF export).
      _loadPrefs();
    }
  }

  Future<void> _loadPrefs() async {
    final uid = _userId;
    final dismissed = await _store.isDismissed(uid);
    final pdfDone = await _store.isPdfDone(uid);
    if (!mounted) return;
    setState(() {
      _dismissed = dismissed;
      _pdfDone = pdfDone;
      _loaded = true;
    });
  }

  PostInviteOnboardingState? get _state {
    final snap = widget.snapshot;
    if (!_loaded || snap == null) return null;
    return resolvePostInviteOnboarding(
      snapshot: snap,
      dismissed: _dismissed,
      pdfDone: _pdfDone,
    );
  }

  Future<void> _dismiss() async {
    unawaited(HapticFeedback.mediumImpact());
    await _store.markDismissed(_userId);
    if (!mounted) return;
    setState(() => _dismissed = true);
    widget.onDismissed?.call();
  }

  void _openPath(String path) {
    HapticFeedback.mediumImpact();
    navigateTo(context, path);
  }

  String _step2Path(PostInviteOnboardingState state) {
    final noPlanId = state.firstCustomerWithoutPlanId;
    if (noPlanId != null && noPlanId.isNotEmpty) {
      return customerWorkoutEditorPath(noPlanId);
    }
    final planCustomerId = state.firstPlanCustomerId;
    final planId = state.firstPlanId;
    if (planCustomerId != null &&
        planCustomerId.isNotEmpty &&
        planId != null &&
        planId.isNotEmpty) {
      return customerWorkoutEditorPath(planCustomerId, planId: planId);
    }
    if (state.hasCustomer) return AppPaths.customers;
    return AppPaths.customersNew;
  }

  String _step3Path(PostInviteOnboardingState state) {
    final planCustomerId = state.firstPlanCustomerId;
    final planId = state.firstPlanId;
    if (planCustomerId != null &&
        planCustomerId.isNotEmpty &&
        planId != null &&
        planId.isNotEmpty) {
      return customerWorkoutEditorPath(planCustomerId, planId: planId);
    }
    final noPlanId = state.firstCustomerWithoutPlanId;
    if (noPlanId != null && noPlanId.isNotEmpty) {
      return customerWorkoutEditorPath(noPlanId);
    }
    if (state.hasCustomer) return AppPaths.customers;
    return AppPaths.customersNew;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null || !state.visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DashboardSurfaceCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.checklist_rtl, color: cs.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.postInviteOnboardingTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.postInviteOnboardingProgress(state.completedCount),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.postInviteOnboardingDismiss,
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                  onPressed: _dismiss,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StepRow(
              done: state.hasCustomer,
              title: l10n.postInviteOnboardingStep1Title,
              body: l10n.postInviteOnboardingStep1Body,
              actionLabel: l10n.postInviteOnboardingStep1Action,
              onTap: state.hasCustomer
                  ? null
                  : () => _openPath(AppPaths.customersNew),
              theme: theme,
              cs: cs,
            ),
            _StepRow(
              done: state.hasPlan,
              title: l10n.postInviteOnboardingStep2Title,
              body: l10n.postInviteOnboardingStep2Body,
              actionLabel: l10n.postInviteOnboardingStep2Action,
              onTap: state.hasPlan ? null : () => _openPath(_step2Path(state)),
              theme: theme,
              cs: cs,
            ),
            _StepRow(
              done: state.pdfDone,
              title: l10n.postInviteOnboardingStep3Title,
              body: l10n.postInviteOnboardingStep3Body,
              actionLabel: l10n.postInviteOnboardingStep3Action,
              onTap: state.pdfDone ? null : () => _openPath(_step3Path(state)),
              theme: theme,
              cs: cs,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _dismiss,
                child: Text(l10n.postInviteOnboardingDismiss),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.done,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
    required this.theme,
    required this.cs,
  });

  final bool done;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onTap;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 22,
            color: done ? StitchM3Theme.accent : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (!done && onTap != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    actionLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}

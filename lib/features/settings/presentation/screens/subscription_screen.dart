import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/product_analytics.dart';
import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/billing/billing_checkout.dart';
import '../../../../core/billing/entitlement_models.dart';
import '../../../../core/billing/entitlement_repository.dart';
import '../../../../core/billing/plan_usage.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/widgets/stitch_secondary_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/subscription/subscription_billing_details_card.dart';
import '../widgets/subscription/subscription_plan_compare_card.dart';
import '../widgets/subscription/subscription_pro_actions_card.dart';
import '../widgets/subscription/subscription_status_card.dart';
import '../widgets/subscription/subscription_upgrade_card.dart';

/// Subscription Settings – Stitch dark redesign (Free vs Pro).
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  bool _busy = false;
  bool _yearly = false;
  Entitlement? _entitlement;
  int _activeCustomerCount = 0;
  final PlanUsage _planUsage = PlanUsage();
  final _compareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    EntitlementRepository.instance.entitlement
        .addListener(_onEntitlementChanged);
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCheckoutQuery();
    });
  }

  void _handleCheckoutQuery() {
    if (!mounted) return;
    final checkout = GoRouterState.of(context).uri.queryParameters['checkout'];
    if (checkout == null || checkout.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (checkout == 'success') {
      ProductAnalytics.subscribed();
      unawaited(_load());
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.subscriptionCheckoutSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (checkout == 'cancel') {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.subscriptionCheckoutCancel),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    EntitlementRepository.instance.entitlement
        .removeListener(_onEntitlementChanged);
    super.dispose();
  }

  void _onEntitlementChanged() {
    final value = EntitlementRepository.instance.cached;
    if (value == null || !mounted) return;
    setState(() => _entitlement = value);
  }

  Future<void> _load() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _entitlement = null;
          _activeCustomerCount = 0;
        });
      }
      return;
    }

    final results = await Future.wait([
      EntitlementRepository.instance.refresh(),
      _planUsage.countActiveCustomers(),
    ]);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _entitlement = results[0] as Entitlement?;
      _activeCustomerCount = results[1] as int;
    });
  }

  String _planLabel(AppLocalizations l10n) {
    final plan = _entitlement?.plan ?? BillingPlan.free;
    return plan == BillingPlan.pro
        ? l10n.subscriptionPlanPro
        : l10n.subscriptionPlanFree;
  }

  Future<void> _startCheckout(BillingInterval interval) async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).subscriptionWebOnlyHint),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await BillingCheckout.startCheckout(interval: interval);
    } on BillingCheckoutException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionCheckoutError)),
      );
      debugPrint('Checkout error: ${e.message}');
    } catch (e, stack) {
      debugPrint('Checkout error: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionCheckoutError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPortal([PortalFlow flow = PortalFlow.defaultFlow]) async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).subscriptionWebOnlyHint),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await BillingCheckout.openCustomerPortal(flow: flow);
    } on BillingCheckoutException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionPortalError)),
      );
      debugPrint('Portal error: ${e.message}');
    } catch (e, stack) {
      debugPrint('Portal error: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionPortalError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _scrollToCompare() {
    final ctx = _compareKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entitlement = _entitlement ??
        const Entitlement(
          plan: BillingPlan.free,
          subscriptionPlan: BillingPlan.free,
          status: BillingStatus.none,
        );
    final isPro = entitlement.isPro;
    final isStripePro = isPro && entitlement.isStripeBilling;
    final desktop = Breakpoints.isDesktop(context);
    final phone = !Breakpoints.isTabletOrWider(context);

    return Scaffold(
      backgroundColor: phone
          ? StitchMobileColors.surface
          : MarketingDarkColors.stitchPageBg,
      appBar: phone
          ? null
          : StitchSecondaryAppBar(
              title: l10n.settingsSubscriptionTitle,
              onBack: () => navigateBackFromSubscription(context),
            ),
      body: SafeArea(
        bottom: false,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  phone ? 16 : 24,
                  phone ? 16 : 24,
                  phone ? 16 : 24,
                  phone ? 80 : 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SubscriptionPageHeader(
                      isPro: isPro,
                      phone: phone,
                      onViewCompare: phone ? null : _scrollToCompare,
                    ),
                    SizedBox(height: phone ? 24 : 24),
                    if (desktop && !isPro)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: SubscriptionStatusCard(
                                entitlement: entitlement,
                                planLabel: _planLabel(l10n),
                                activeCustomerCount: _activeCustomerCount,
                                nearLimit: _planUsage
                                    .isNearCustomerLimit(_activeCustomerCount),
                                atLimit: _planUsage
                                    .isAtCustomerLimit(_activeCustomerCount),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SubscriptionUpgradeCard(
                                busy: _busy,
                                yearly: _yearly,
                                onCheckoutStarted: _startCheckout,
                                onYearlyChanged: (v) =>
                                    setState(() => _yearly = v),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      SubscriptionStatusCard(
                        entitlement: entitlement,
                        planLabel: _planLabel(l10n),
                        activeCustomerCount: _activeCustomerCount,
                        nearLimit:
                            _planUsage.isNearCustomerLimit(_activeCustomerCount),
                        atLimit:
                            _planUsage.isAtCustomerLimit(_activeCustomerCount),
                      ),
                      if (!isPro) ...[
                        const SizedBox(height: 16),
                        SubscriptionUpgradeCard(
                          busy: _busy,
                          yearly: _yearly,
                          onCheckoutStarted: _startCheckout,
                          onYearlyChanged: (v) => setState(() => _yearly = v),
                        ),
                      ],
                    ],
                    SizedBox(height: phone ? 24 : 32),
                    KeyedSubtree(
                      key: _compareKey,
                      child: SubscriptionPlanCompareCard(
                        yearly: _yearly,
                        onYearlyChanged: (v) => setState(() => _yearly = v),
                      ),
                    ),
                    if (isStripePro) ...[
                      const SizedBox(height: 24),
                      SubscriptionBillingDetailsCard(entitlement: entitlement),
                      const SizedBox(height: 16),
                      SubscriptionProActionsCard(
                        entitlement: entitlement,
                        busy: _busy,
                        onPortalOpened: _openPortal,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _busy ? null : () => _openPortal(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: phone
                              ? StitchMobileColors.onSurfaceVariant
                              : MarketingDarkColors.slate300,
                          side: BorderSide(
                            color: phone
                                ? StitchMobileColors.outline
                                    .withValues(alpha: 0.4)
                                : MarketingDarkColors.stitchBorderMuted,
                          ),
                        ),
                        child: Text(l10n.subscriptionManage),
                      ),
                    ] else if (!isPro && !phone) ...[
                      const SizedBox(height: 28),
                      _SubscriptionCtaBanner(
                        busy: _busy,
                        onCheckoutStarted: _startCheckout,
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

class _SubscriptionPageHeader extends StatelessWidget {
  const _SubscriptionPageHeader({
    required this.isPro,
    required this.phone,
    this.onViewCompare,
  });

  final bool isPro;
  final bool phone;
  final VoidCallback? onViewCompare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => navigateBackFromSubscription(context),
                icon: const Icon(Icons.arrow_back),
                color: StitchMobileColors.onSurface,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: StitchMobileColors.touchMin,
                  minHeight: StitchMobileColors.touchMin,
                ),
              ),
              Expanded(
                child: Text(
                  l10n.subscriptionPageTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: StitchMobileColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: StitchMobileColors.headlineSize,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StitchMobileColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isPro
                      ? l10n.subscriptionProActiveBadge
                      : l10n.subscriptionFreeLimitedBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: StitchMobileColors.outline,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.subscriptionPageSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: StitchMobileColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPro
                ? MarketingDarkColors.emerald.withValues(alpha: 0.1)
                : MarketingDarkColors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isPro
                  ? MarketingDarkColors.emeraldBorder
                  : MarketingDarkColors.amber.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isPro
                      ? MarketingDarkColors.emerald
                      : MarketingDarkColors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isPro
                    ? l10n.subscriptionProActiveBadge
                    : l10n.subscriptionFreeLimitedBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isPro
                      ? MarketingDarkColors.emerald
                      : MarketingDarkColors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.subscriptionPageTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.subscriptionPageSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: MarketingDarkColors.slate400,
          ),
        ),
        if (onViewCompare != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onViewCompare,
            style: TextButton.styleFrom(
              foregroundColor: MarketingDarkColors.brandLight,
              padding: EdgeInsets.zero,
            ),
            child: Text(l10n.subscriptionCompareTitle),
          ),
        ],
      ],
    );
  }
}

class _SubscriptionCtaBanner extends StatelessWidget {
  const _SubscriptionCtaBanner({
    required this.busy,
    required this.onCheckoutStarted,
  });

  final bool busy;
  final Future<void> Function(BillingInterval interval) onCheckoutStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MarketingDarkColors.stitchCardElevated,
            MarketingDarkColors.stitchPageBg,
          ],
        ),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius3xl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MarketingDarkColors.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: MarketingDarkColors.brandMid.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check,
                  size: 14,
                  color: MarketingDarkColors.brandLight,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.subscriptionCtaNoLock,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.brandLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.subscriptionCtaTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.subscriptionUpgradeHighlightBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.slate300,
            ),
          ),
          const SizedBox(height: 24),
          if (!kIsWeb)
            Text(
              l10n.subscriptionWebOnlyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: busy
                      ? null
                      : () => onCheckoutStarted(BillingInterval.monthly),
                  style: FilledButton.styleFrom(
                    backgroundColor: MarketingDarkColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketingDarkColors.radiusXl),
                    ),
                  ),
                  child: Text(l10n.subscriptionUpgradeMonthly),
                ),
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => onCheckoutStarted(BillingInterval.yearly),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: MarketingDarkColors.brandMid.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(MarketingDarkColors.radiusXl),
                    ),
                  ),
                  child: Text(l10n.subscriptionUpgradeYearly),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/billing/billing_checkout.dart';
import 'package:powercoach_studio/core/billing/billing_promo.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';
import 'package:powercoach_studio/core/billing/plan_usage.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_billing_details_card.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_plan_compare_card.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_pro_actions_card.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_promo_card.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_status_card.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_usage_card.dart';

import '../../../../l10n/app_localizations.dart';

/// Subscription Settings – Stitch screen ID 1224a49f9c5849fcb205e965ebc0b9a4.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  bool _busy = false;
  Entitlement? _entitlement;
  int _activeCustomerCount = 0;
  final PlanUsage _planUsage = PlanUsage();

  @override
  void initState() {
    super.initState();
    EntitlementRepository.instance.entitlement.addListener(_onEntitlementChanged);
    _load();
  }

  @override
  void dispose() {
    EntitlementRepository.instance.entitlement.removeListener(_onEntitlementChanged);
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

  Future<void> _redeemPromoCode(String code) async {
    final l10n = AppLocalizations.of(context);
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionPromoCodeEmpty)),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await BillingPromo.redeemCode(code);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyPro
                ? l10n.subscriptionPromoAlreadyPro
                : l10n.subscriptionPromoRedeemSuccess,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on BillingPromoException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e, stack) {
      debugPrint('Promo redeem error: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionPromoRedeemError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestCoupon(String? message) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final result = await BillingPromo.requestCoupon(message: message);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyPending
                ? l10n.subscriptionCouponRequestPending
                : l10n.subscriptionCouponRequestSuccess,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on BillingPromoException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e, stack) {
      debugPrint('Coupon request error: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subscriptionCouponRequestError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPortal([PortalFlow flow = PortalFlow.defaultFlow]) async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).subscriptionWebOnlyHint)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final entitlement = _entitlement ??
        const Entitlement(
          plan: BillingPlan.free,
          subscriptionPlan: BillingPlan.free,
          status: BillingStatus.none,
        );
    final isPro = entitlement.isPro;
    final isStripePro = isPro && entitlement.isStripeBilling;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(
        title: l10n.settingsSubscriptionTitle,
        onBack: () => navigateBackFromSubscription(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SubscriptionStatusCard(
                      entitlement: entitlement,
                      planLabel: _planLabel(l10n),
                    ),
                    if (!isPro) ...[
                      const SizedBox(height: 16),
                      SubscriptionUsageCard(
                        activeCustomerCount: _activeCustomerCount,
                        nearLimit: _planUsage.isNearCustomerLimit(_activeCustomerCount),
                        atLimit: _planUsage.isAtCustomerLimit(_activeCustomerCount),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const SubscriptionPlanCompareCard(),
                    if (isStripePro) ...[
                      const SizedBox(height: 16),
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
                        child: Text(l10n.subscriptionManage),
                      ),
                    ] else if (isPro) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.subscriptionPromoProActiveHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      SubscriptionPromoCard(
                        busy: _busy,
                        hasPendingCouponRequest: entitlement.hasPendingCouponRequest,
                        onRedeem: _redeemPromoCode,
                        onRequestCoupon: _requestCoupon,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

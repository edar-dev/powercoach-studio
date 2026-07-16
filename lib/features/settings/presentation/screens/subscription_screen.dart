import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/billing/billing_checkout.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';

/// Subscription Settings – Stitch screen ID 1224a49f9c5849fcb205e965ebc0b9a4.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  bool _busy = false;
  BillingPlan _plan = BillingPlan.free;
  bool _checkoutHandled = false;

  @override
  void initState() {
    super.initState();
    EntitlementRepository.instance.entitlement.addListener(_onEntitlementChanged);
    _loadPlan();
  }

  @override
  void dispose() {
    EntitlementRepository.instance.entitlement.removeListener(_onEntitlementChanged);
    super.dispose();
  }

  void _onEntitlementChanged() {
    final value = EntitlementRepository.instance.cached;
    if (value == null || !mounted) return;
    setState(() => _plan = value.plan);
  }

  Future<void> _loadPlan() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _plan = BillingPlan.free;
        });
      }
      return;
    }

    final entitlement = await EntitlementRepository.instance.refresh();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _plan = entitlement?.plan ?? BillingPlan.free;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkoutHandled) return;
    final checkout = GoRouterState.of(context).uri.queryParameters['checkout'];
    if (checkout == null) return;
    _checkoutHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleCheckoutReturn(checkout));
  }

  Future<void> _handleCheckoutReturn(String checkout) async {
    final l10n = AppLocalizations.of(context);
    if (checkout == 'success') {
      await EntitlementRepository.instance.refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.subscriptionCheckoutSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _planLabel(AppLocalizations l10n) {
    return _plan == BillingPlan.pro
        ? l10n.subscriptionPlanPro
        : l10n.subscriptionPlanFree;
  }

  Future<void> _startCheckout(BillingInterval interval) async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).subscriptionWebOnlyHint)),
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

  Future<void> _openPortal() async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).subscriptionWebOnlyHint)),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await BillingCheckout.openCustomerPortal();
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
    final isPro = _plan == BillingPlan.pro;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.settingsSubscriptionTitle),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      side: BorderSide(color: cs.outline),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.subscriptionCurrentPlan,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _planLabel(l10n),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isPro) ...[
                    FilledButton(
                      onPressed: _busy ? null : () => _startCheckout(BillingInterval.monthly),
                      child: Text(l10n.subscriptionUpgradeMonthly),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _busy ? null : () => _startCheckout(BillingInterval.yearly),
                      child: Text(l10n.subscriptionUpgradeYearly),
                    ),
                  ] else
                    OutlinedButton(
                      onPressed: _busy ? null : _openPortal,
                      child: Text(l10n.subscriptionManage),
                    ),
                ],
              ),
            ),
    );
  }
}

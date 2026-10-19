import 'package:flutter/material.dart';

import '../../../../../core/billing/billing_promo.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../../core/ui/breakpoints.dart';
import '../../../../../l10n/app_localizations.dart';
import '../settings_stitch_field.dart';

/// Free-plan card: redeem a Pro promo code or request an invite.
class SubscriptionPromoRedeemCard extends StatefulWidget {
  const SubscriptionPromoRedeemCard({
    super.key,
    required this.hasPendingCouponRequest,
    required this.onRedeemed,
    this.onRedeemCode,
    this.onRequestCoupon,
  });

  final bool hasPendingCouponRequest;
  final Future<void> Function() onRedeemed;

  /// Test seam; defaults to [BillingPromo.redeemCode].
  final Future<RedeemPromoResult> Function(String code)? onRedeemCode;

  /// Test seam; defaults to [BillingPromo.requestCoupon].
  final Future<CouponRequestResult> Function({String? message})?
      onRequestCoupon;

  @override
  State<SubscriptionPromoRedeemCard> createState() =>
      _SubscriptionPromoRedeemCardState();
}

class _SubscriptionPromoRedeemCardState
    extends State<SubscriptionPromoRedeemCard> {
  final _codeController = TextEditingController();
  var _redeemBusy = false;
  var _requestBusy = false;
  String? _fieldError;

  bool get _busy => _redeemBusy || _requestBusy;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _fieldError = l10n.subscriptionPromoCodeRequired);
      return;
    }

    setState(() {
      _redeemBusy = true;
      _fieldError = null;
    });

    final redeem = widget.onRedeemCode ?? BillingPromo.redeemCode;
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await redeem(code);
      if (!mounted) return;

      // Snackbar before refresh: parent removes this card when plan becomes Pro.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyPro
                ? l10n.subscriptionPromoAlreadyPro
                : l10n.subscriptionPromoRedeemSuccess,
            style: TextStyle(color: cs.onPrimaryContainer),
          ),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _codeController.clear();
      await widget.onRedeemed();
    } on BillingPromoException catch (e) {
      if (!mounted) return;
      final message = _mapRedeemError(l10n, e.message);
      setState(() => _fieldError = message);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stack) {
      debugPrint('Promo redeem error: $e\n$stack');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.subscriptionPromoRedeemError,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _redeemBusy = false);
    }
  }

  Future<void> _requestInvite() async {
    if (widget.hasPendingCouponRequest) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _requestBusy = true);

    final request = widget.onRequestCoupon ?? BillingPromo.requestCoupon;
    final cs = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await request();
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyPending
                ? l10n.subscriptionPromoRequestAlreadyPending
                : l10n.subscriptionPromoRequestSuccess,
            style: TextStyle(color: cs.onPrimaryContainer),
          ),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await widget.onRedeemed();
    } on BillingPromoException catch (e) {
      debugPrint('Promo request error: ${e.message}');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.subscriptionPromoRequestError,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stack) {
      debugPrint('Promo request error: $e\n$stack');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.subscriptionPromoRequestError,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _requestBusy = false);
    }
  }

  String _mapRedeemError(AppLocalizations l10n, String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('enter a promo') || lower.contains('enter a code')) {
      return l10n.subscriptionPromoCodeRequired;
    }
    if (lower.contains('already used')) {
      return l10n.subscriptionPromoAlreadyUsed;
    }
    if (lower.contains('expired')) {
      return l10n.subscriptionPromoExpiredCode;
    }
    if (lower.contains('redemption limit') || lower.contains('reached its')) {
      return l10n.subscriptionPromoCodeLimit;
    }
    if (lower.contains('invalid') || lower.contains('inactive')) {
      return l10n.subscriptionPromoInvalidCode;
    }
    return l10n.subscriptionPromoRedeemError;
  }

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.subscriptionPromoSectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: StitchMobileColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.subscriptionPromoSectionBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: StitchMobileColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SettingsStitchField(
            label: l10n.subscriptionPromoCodeLabel,
            controller: _codeController,
            hint: l10n.subscriptionPromoCodeHint,
            mobileStyle: true,
            textInputAction: TextInputAction.done,
            readOnly: _busy,
          ),
          if (_fieldError != null) ...[
            const SizedBox(height: 8),
            Text(
              _fieldError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: StitchMobileColors.error,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _busy ? null : _redeem,
              style: FilledButton.styleFrom(
                backgroundColor: StitchMobileColors.primaryContainer,
                foregroundColor: StitchMobileColors.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(StitchMobileColors.radiusLg),
                ),
              ),
              child: _redeemBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.subscriptionPromoRedeemCta,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          _RequestInviteButton(
            busy: _busy,
            requesting: _requestBusy,
            hasPending: widget.hasPendingCouponRequest,
            phone: true,
            onPressed: _requestInvite,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.subscriptionPromoSectionTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.subscriptionPromoSectionBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate300,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 520;
              final field = SettingsStitchField(
                label: l10n.subscriptionPromoCodeLabel,
                controller: _codeController,
                hint: l10n.subscriptionPromoCodeHint,
                textInputAction: TextInputAction.done,
                readOnly: _busy,
              );
              final button = SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _redeem,
                  style: FilledButton.styleFrom(
                    backgroundColor: MarketingDarkColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MarketingDarkColors.radiusXl,
                      ),
                    ),
                  ),
                  child: _redeemBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.subscriptionPromoRedeemCta,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    field,
                    if (_fieldError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _fieldError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    button,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: field),
                      const SizedBox(width: 12),
                      button,
                    ],
                  ),
                  if (_fieldError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _fieldError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _RequestInviteButton(
            busy: _busy,
            requesting: _requestBusy,
            hasPending: widget.hasPendingCouponRequest,
            phone: false,
            onPressed: _requestInvite,
          ),
        ],
      ),
    );
  }
}

class _RequestInviteButton extends StatelessWidget {
  const _RequestInviteButton({
    required this.busy,
    required this.requesting,
    required this.hasPending,
    required this.phone,
    required this.onPressed,
  });

  final bool busy;
  final bool requesting;
  final bool hasPending;
  final bool phone;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (hasPending) {
      return Text(
        l10n.subscriptionPromoRequestPending,
        style: theme.textTheme.bodySmall?.copyWith(
          color: phone
              ? StitchMobileColors.onSurfaceVariant
              : MarketingDarkColors.slate400,
          height: 1.35,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: busy ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: phone
              ? StitchMobileColors.primary
              : MarketingDarkColors.brandLight,
          padding: EdgeInsets.zero,
        ),
        child: requesting
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: phone
                      ? StitchMobileColors.primary
                      : MarketingDarkColors.brandLight,
                ),
              )
            : Text(l10n.subscriptionPromoRequestCta),
      ),
    );
  }
}

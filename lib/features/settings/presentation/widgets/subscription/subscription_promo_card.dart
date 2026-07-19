import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../../../../l10n/app_localizations.dart';

class SubscriptionPromoCard extends StatefulWidget {
  const SubscriptionPromoCard({
    super.key,
    required this.busy,
    required this.hasPendingCouponRequest,
    required this.onRedeem,
    required this.onRequestCoupon,
  });

  final bool busy;
  final bool hasPendingCouponRequest;
  final Future<void> Function(String code) onRedeem;
  final Future<void> Function(String? message) onRequestCoupon;

  @override
  State<SubscriptionPromoCard> createState() => _SubscriptionPromoCardState();
}

class _SubscriptionPromoCardState extends State<SubscriptionPromoCard> {
  final _codeController = TextEditingController();
  final _messageController = TextEditingController();
  bool _showRequestForm = false;

  @override
  void dispose() {
    _codeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    await widget.onRedeem(_codeController.text);
  }

  Future<void> _submitRequest() async {
    await widget.onRequestCoupon(
      _messageController.text.trim().isEmpty ? null : _messageController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        side: BorderSide(color: cs.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.subscriptionPromoCardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.subscriptionPromoCardSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              enabled: !widget.busy,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.subscriptionPromoCodeLabel,
                hintText: l10n.subscriptionPromoCodeHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: widget.busy ? null : (_) => _submitCode(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.busy ? null : _submitCode,
              child: Text(l10n.subscriptionPromoRedeemButton),
            ),
            const SizedBox(height: 20),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 12),
            if (widget.hasPendingCouponRequest)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top_outlined, color: cs.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.subscriptionCouponRequestPending,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                l10n.subscriptionCouponRequestIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (_showRequestForm) ...[
                TextField(
                  controller: _messageController,
                  enabled: !widget.busy,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionCouponRequestMessageLabel,
                    hintText: l10n.subscriptionCouponRequestMessageHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: widget.busy ? null : _submitRequest,
                  child: Text(l10n.subscriptionCouponRequestSubmit),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: widget.busy
                      ? null
                      : () => setState(() => _showRequestForm = false),
                  child: Text(l10n.customerCancel),
                ),
              ] else
                OutlinedButton(
                  onPressed: widget.busy
                      ? null
                      : () => setState(() => _showRequestForm = true),
                  child: Text(l10n.subscriptionCouponRequestButton),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

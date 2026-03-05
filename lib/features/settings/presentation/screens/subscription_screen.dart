import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../../core/utils/not_implemented.dart';
import '../../../../l10n/app_localizations.dart';

/// Subscription Settings – Stitch screen ID 1224a49f9c5849fcb205e965ebc0b9a4.
/// Shows current plan (from profiles.subscription_plan, default free), Upgrade / Manage.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  String _plan = 'free';

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _plan = 'free';
      });
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('subscription_plan')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) {
        final raw = res?['subscription_plan'] as String?;
        setState(() {
          _isLoading = false;
          _plan = (raw?.trim().toLowerCase() == 'pro') ? 'pro' : 'free';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _plan = 'free';
        });
      }
    }
  }

  String _planLabel(AppLocalizations l10n) {
    return _plan == 'pro' ? l10n.subscriptionPlanPro : l10n.subscriptionPlanFree;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: StitchM3Theme.bgSecondary,
      appBar: AppBar(
        backgroundColor: StitchM3Theme.bg,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
        title: Text(
          l10n.settingsSubscriptionTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: StitchM3Theme.textPrimary,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: StitchM3Theme.border, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      side: const BorderSide(color: StitchM3Theme.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.subscriptionCurrentPlan,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: StitchM3Theme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _planLabel(l10n),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: StitchM3Theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_plan != 'pro')
                    FilledButton(
                      onPressed: () => showNotImplementedAlert(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                        ),
                      ),
                      child: Text(l10n.subscriptionUpgrade),
                    ),
                  if (_plan == 'pro') ...[
                    OutlinedButton(
                      onPressed: () => showNotImplementedAlert(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                        ),
                      ),
                      child: Text(l10n.subscriptionManage),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

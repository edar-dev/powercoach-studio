import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/local_user_profile_store.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../core/utils/not_implemented.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/stitch_secondary_app_bar.dart';

/// Subscription Settings – Stitch screen ID 1224a49f9c5849fcb205e965ebc0b9a4.
/// Shows current plan from local profile storage.
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
    final localProfile = await LocalUserProfileStore.instance.read(user.id);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _plan = localProfile.subscriptionPlan == 'pro' ? 'pro' : 'free';
    });
  }

  String _planLabel(AppLocalizations l10n) {
    return _plan == 'pro' ? l10n.subscriptionPlanPro : l10n.subscriptionPlanFree;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final cs = theme.colorScheme;
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

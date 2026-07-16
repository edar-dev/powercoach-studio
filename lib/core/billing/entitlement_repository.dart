import 'package:flutter/foundation.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/features/auth/data/local_coach_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'entitlement_models.dart';

/// Fetches billing entitlements from Supabase Edge Functions and caches locally.
class EntitlementRepository {
  EntitlementRepository._();

  static final EntitlementRepository instance = EntitlementRepository._();

  final ValueNotifier<Entitlement?> entitlement = ValueNotifier<Entitlement?>(null);

  Entitlement? get cached => entitlement.value;

  bool get isProEffective => cached?.isPro ?? false;

  Future<Entitlement?> refresh() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      entitlement.value = null;
      return null;
    }

    if (!SupabaseBootstrap.isInitialized) {
      return _loadFromLocalProfile(user.id);
    }

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-entitlement',
        method: HttpMethod.get,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw FormatException('Unexpected entitlement payload: $data');
      }

      final parsed = Entitlement.fromJson(data);
      entitlement.value = parsed;
      await _syncLocalProfile(user.id, parsed);
      return parsed;
    } catch (e, stack) {
      debugPrint('EntitlementRepository.refresh failed: $e\n$stack');
      return _loadFromLocalProfile(user.id);
    }
  }

  Future<Entitlement?> _loadFromLocalProfile(String userId) async {
    final profile =
        await LocalCoachProfileRepository.instance.getProfile(userId);
    final plan = profile.subscriptionPlan == 'pro'
        ? BillingPlan.pro
        : BillingPlan.free;
    final fallback = Entitlement(
      plan: plan,
      subscriptionPlan: plan,
      status: plan == BillingPlan.pro ? BillingStatus.active : BillingStatus.none,
    );
    entitlement.value = fallback;
    return fallback;
  }

  Future<void> _syncLocalProfile(String userId, Entitlement value) async {
    final current =
        await LocalCoachProfileRepository.instance.getProfile(userId);
    final planLabel = value.plan == BillingPlan.pro ? 'pro' : 'free';
    if (current.subscriptionPlan == planLabel) return;

    await LocalCoachProfileRepository.instance.saveProfile(
      userId,
      LocalUserProfileData(
        displayName: current.displayName,
        phone: current.phone,
        bio: current.bio,
        avatarUrl: current.avatarUrl,
        website: current.website,
        subscriptionPlan: planLabel,
      ),
    );
  }
}

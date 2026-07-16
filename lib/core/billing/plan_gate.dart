import 'package:flutter/material.dart';

import 'entitlement_repository.dart';
import 'plan_limits.dart';
import 'paywall_dialog.dart';

export 'paywall_dialog.dart' show PaywallFeature;

/// Client-side plan checks (UX). Source of truth remains Supabase entitlements.
abstract final class PlanGate {
  static Future<bool> isPro() async {
    final cached = EntitlementRepository.instance.cached;
    if (cached != null) return cached.isPro;
    final refreshed = await EntitlementRepository.instance.refresh();
    return refreshed?.isPro ?? false;
  }

  static Future<bool> canAddCustomer(int activeCustomerCount) async {
    if (await isPro()) return true;
    return activeCustomerCount < PlanLimits.maxActiveCustomers;
  }

  static Future<bool> canExportProgress() => isPro();

  static Future<bool> canUseHevy() => isPro();

  static Future<bool> canExportWorkoutPdfOrExcel() => isPro();

  /// Returns `true` when the action is allowed; otherwise shows paywall and returns `false`.
  static Future<bool> requirePro(
    BuildContext context, {
    required PaywallFeature feature,
    int? activeCustomerCount,
  }) async {
    if (await isPro()) return true;
    if (!context.mounted) return false;
    await showPaywallDialog(
      context,
      feature: feature,
      activeCustomerCount: activeCustomerCount,
    );
    return false;
  }
}

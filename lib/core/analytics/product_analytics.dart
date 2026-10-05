import 'posthog_bootstrap.dart';
import 'posthog_web.dart';

/// High-signal product event names (web PostHog). No PII in properties.
abstract final class AnalyticsEvents {
  static const loginCompleted = 'login_completed';
  static const signupCompleted = 'signup_completed';
  static const customerCreated = 'customer_created';
  static const workoutPlanCreated = 'workout_plan_created';
  static const workoutPlanSaved = 'workout_plan_saved';
  static const pdfExported = 'pdf_exported';
  static const subscriptionCheckoutStarted = 'subscription_checkout_started';
  static const subscribed = 'subscribed';
}

/// Thin product-analytics facade. No-op off-web, when disabled, or before consent.
abstract final class ProductAnalytics {
  /// Captures [name] with optional non-PII [properties].
  static void capture(
    String name, [
    Map<String, Object?> properties = const <String, Object?>{},
  ]) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (!PostHogBootstrap.isEnabled) return;
    capturePosthogWebEvent(trimmed, properties);
  }

  static void loginCompleted() => capture(AnalyticsEvents.loginCompleted);

  static void signupCompleted() => capture(AnalyticsEvents.signupCompleted);

  static void customerCreated() => capture(AnalyticsEvents.customerCreated);

  static void workoutPlanCreated() =>
      capture(AnalyticsEvents.workoutPlanCreated);

  static void workoutPlanSaved() => capture(AnalyticsEvents.workoutPlanSaved);

  static void pdfExported({required String source}) => capture(
        AnalyticsEvents.pdfExported,
        <String, Object?>{'source': source},
      );

  static void subscriptionCheckoutStarted({required String billingInterval}) =>
      capture(
        AnalyticsEvents.subscriptionCheckoutStarted,
        <String, Object?>{'billing_interval': billingInterval},
      );

  static void subscribed({String source = 'stripe_checkout'}) => capture(
        AnalyticsEvents.subscribed,
        <String, Object?>{'source': source},
      );
}

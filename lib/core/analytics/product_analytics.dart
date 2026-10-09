import '../remote/coach_entities_exceptions.dart';
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
  static const firstSaveFailed = 'first_save_failed';
  static const offlineSaveBlocked = 'offline_save_blocked';
  static const sessionLogged = 'session_logged';
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

  /// Non-PII reason token for cloud-save failures (`offline`, `not_authenticated`,
  /// `remote`, `network`, `unknown`). Never include exception messages.
  static String reasonFromError(Object error) {
    if (error is CoachEntitiesOnlineRequiredException) {
      return switch (error.reason) {
        CoachEntitiesOnlineRequiredReason.offline => 'offline',
        CoachEntitiesOnlineRequiredReason.notAuthenticated =>
          'not_authenticated',
      };
    }
    if (error is CoachEntitiesRemoteException) {
      return 'remote';
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('network') ||
        msg.contains('connection')) {
      return 'network';
    }
    return 'unknown';
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

  /// First cloud create of a workout plan failed (editor had no [loadedPlanId]).
  static void firstSaveFailed({
    required bool silent,
    required String reason,
  }) =>
      capture(
        AnalyticsEvents.firstSaveFailed,
        <String, Object?>{'silent': silent, 'reason': reason},
      );

  /// Remote write blocked because the coach is offline or not authenticated.
  static void offlineSaveBlocked({required String reason}) => capture(
        AnalyticsEvents.offlineSaveBlocked,
        <String, Object?>{'reason': reason},
      );

  /// Coach logged a completed training session (diary / Today / calendar).
  static void sessionLogged({
    String source = 'unknown',
    bool hasExerciseData = false,
  }) =>
      capture(
        AnalyticsEvents.sessionLogged,
        <String, Object?>{
          'source': source,
          'has_exercise_data': hasExerciseData,
        },
      );
}

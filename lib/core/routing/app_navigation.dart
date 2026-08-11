import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';

/// Declarative navigation that always updates the browser URL on web.
///
/// Prefer this when leaving a route branch (e.g. `/dashboard` → `/workouts/*`,
/// `/` → `/customers`) or when navigating between sibling routes under a parent
/// shell without its own builder (e.g. `/workouts/templates` → `/workouts/editor`).
///
/// Use [navigatePush] only for child routes under the current branch when you
/// need a return value or `pop` back to the parent (e.g. `/settings` →
/// `/settings/personal-info`, `/customers/:id` → `/customers/:id/notes`).
void navigateTo(BuildContext context, String location) {
  context.go(location);
}

/// Replaces the current route and updates the browser URL without adding history.
void navigateReplace(BuildContext context, String location) {
  context.replace(location);
}

/// Pushes [location] so the current route stays on the stack and can refresh on return.
///
/// Avoid for customer workout editor routes on web — [navigateTo] keeps the URL in sync.
Future<T?> navigatePush<T>(BuildContext context, String location) {
  return context.push<T>(location);
}

void navigateBack(BuildContext context, {required String fallback}) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallback);
}

/// Opens subscription with a dedicated URL (`/subscription`) on web.
///
/// Top-level routes must use [navigateTo] — [navigatePush] keeps the old URL in
/// the address bar when leaving `/settings` or other hubs.
void navigateToSubscription(BuildContext context) {
  final current = GoRouterState.of(context).uri.toString();
  if (current == AppPaths.subscription ||
      current.startsWith('${AppPaths.subscription}?')) {
    navigateTo(context, AppPaths.subscription);
    return;
  }
  navigateTo(
    context,
    Uri(
      path: AppPaths.subscription,
      queryParameters: {'from': current},
    ).toString(),
  );
}

void navigateBackFromSubscription(BuildContext context) {
  final from = GoRouterState.of(context).uri.queryParameters['from'];
  navigateBack(
    context,
    fallback: (from != null && from.isNotEmpty) ? from : '/settings',
  );
}

String customerPath(String customerId) => '/customers/$customerId';

String customerWorkoutsPath(String customerId) =>
    '/customers/$customerId/workouts';

String workoutDiaryPath({
  String? customerId,
  String? planId,
  String? sessionKey,
}) {
  final params = <String, String>{};
  if (customerId != null && customerId.isNotEmpty) {
    params['customerId'] = customerId;
  }
  if (planId != null && planId.isNotEmpty) {
    params['planId'] = planId;
  }
  if (sessionKey != null && sessionKey.isNotEmpty) {
    params['sessionKey'] = sessionKey;
  }
  if (params.isEmpty) return '/workouts/diary';
  return Uri(path: '/workouts/diary', queryParameters: params).toString();
}

String workoutDiaryEntryPath({
  required String planId,
  required String sessionKey,
}) =>
    '/workouts/diary/$planId/$sessionKey';

String scheduleSessionDetailPath({
  required String customerId,
  required String planId,
  required int weekIndex,
  required int dayIndex,
  DateTime? date,
}) {
  return Uri(
    path: '/dashboard/schedule/detail',
    queryParameters: {
      'customerId': customerId,
      'planId': planId,
      'week': '$weekIndex',
      'day': '$dayIndex',
      if (date != null)
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
    },
  ).toString();
}

/// Gym mode runner for a specific plan/week/day slot.
String gymSessionPath({
  required String customerId,
  required String planId,
  required int weekIndex,
  required int dayIndex,
  DateTime? date,
}) {
  return Uri(
    path: '${AppPaths.gym}/session',
    queryParameters: {
      'customerId': customerId,
      'planId': planId,
      'week': '$weekIndex',
      'day': '$dayIndex',
      if (date != null)
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
    },
  ).toString();
}

/// Plan version comparison for [customerId]; [planIdB] omitted shows a picker.
String planDiffPath({
  required String customerId,
  required String planIdA,
  String? planIdB,
}) {
  return Uri(
    path: AppPaths.planDiff,
    queryParameters: {
      'customerId': customerId,
      'planIdA': planIdA,
      if (planIdB != null && planIdB.isNotEmpty) 'planIdB': planIdB,
    },
  ).toString();
}

/// New plan editor for [customerId], or edit when [planId] is set.
String customerWorkoutEditorPath(
  String customerId, {
  String? planId,
  int? weekIndex,
  int? dayIndex,
}) {
  final path = (planId != null && planId.isNotEmpty)
      ? '/customers/$customerId/workouts/$planId'
      : '/customers/$customerId/workouts/new';
  if (weekIndex == null || dayIndex == null) {
    return path;
  }
  return Uri(
    path: path,
    queryParameters: {'week': '$weekIndex', 'day': '$dayIndex'},
  ).toString();
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';

/// Declarative navigation that always updates the browser URL on web.
///
/// Prefer this when leaving a route branch (e.g. `/dashboard` → `/workouts/*`,
/// `/` → `/customers`) or when navigating between sibling routes under a parent
/// shell without its own builder (e.g. `/workouts` → `/workouts/builder`).
///
/// Authenticated hub fallback for empty-stack back / Home is
/// [AppPaths.dashboard] — never `/` while logged in.
///
/// Use [navigatePush] only for nested child routes under the current branch when
/// you need a return value or `pop` back to the parent (e.g. `/settings` →
/// `/settings/personal-info`). Sibling detail routes such as notes and
/// measurement history should use [navigateTo] instead.
void navigateTo(BuildContext context, String location) {
  context.go(location);
}

/// Replaces the current route and updates the browser URL without adding history.
void navigateReplace(BuildContext context, String location) {
  context.replace(location);
}

/// Pushes [location] so the current route stays on the stack and can refresh on return.
///
/// Prefer [navigateTo] for sibling routes (notes, measurement history, calendar)
/// and for customer workout editor routes on web so the URL stays in sync.
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
    fallback: (from != null && from.isNotEmpty) ? from : AppPaths.dashboard,
  );
}

String customerPath(String customerId) =>
    '${AppPaths.customers}/$customerId';

String customerWorkoutsPath(String customerId) =>
    '${AppPaths.customers}/$customerId/workouts';

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
  if (params.isEmpty) return AppPaths.workoutDiary;
  return Uri(
    path: AppPaths.workoutDiary,
    queryParameters: params,
  ).toString();
}

String workoutDiaryEntryPath({
  required String planId,
  required String sessionKey,
}) =>
    '${AppPaths.workoutDiary}/$planId/$sessionKey';

String scheduleSessionDetailPath({
  required String customerId,
  required String planId,
  required int weekIndex,
  required int dayIndex,
  DateTime? date,
}) {
  return Uri(
    path: '${AppPaths.dashboard}/schedule/detail',
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

/// New plan editor for [customerId], or edit when [planId] is set.
String customerWorkoutEditorPath(
  String customerId, {
  String? planId,
  int? weekIndex,
  int? dayIndex,
}) {
  final path = (planId != null && planId.isNotEmpty)
      ? '${AppPaths.customers}/$customerId/workouts/$planId'
      : '${AppPaths.customers}/$customerId/workouts/new';
  if (weekIndex == null || dayIndex == null) {
    return path;
  }
  return Uri(
    path: path,
    queryParameters: {'week': '$weekIndex', 'day': '$dayIndex'},
  ).toString();
}

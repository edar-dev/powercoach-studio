import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Declarative navigation that always updates the browser URL on web.
///
/// Prefer this for customer workout editor/list routes so refresh and deep links
/// keep the current screen. Returning screens reload in [initState] when needed.
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

String customerPath(String customerId) => '/customers/$customerId';

String customerWorkoutsPath(String customerId) =>
    '/customers/$customerId/workouts';

String workoutDiaryPath({String? customerId}) {
  if (customerId == null || customerId.isEmpty) return '/workouts/diary';
  return Uri(
    path: '/workouts/diary',
    queryParameters: {'customerId': customerId},
  ).toString();
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Declarative navigation that always updates the browser URL on web.
void navigateTo(BuildContext context, String location) {
  context.go(location);
}

/// Pushes [location] so the current route stays on the stack and can refresh on return.
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
    queryParameters: {
      'week': '$weekIndex',
      'day': '$dayIndex',
    },
  ).toString();
}

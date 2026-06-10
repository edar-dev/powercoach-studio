import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Declarative navigation that always updates the browser URL on web.
void navigateTo(BuildContext context, String location) {
  context.go(location);
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
String customerWorkoutEditorPath(String customerId, {String? planId}) {
  if (planId != null && planId.isNotEmpty) {
    return '/customers/$customerId/workouts/$planId';
  }
  return '/customers/$customerId/workouts/new';
}

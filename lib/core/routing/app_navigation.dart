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

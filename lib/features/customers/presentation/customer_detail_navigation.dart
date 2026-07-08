import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';

Future<void> openCustomerDetailNotes({
  required BuildContext context,
  required String customerId,
  required String customerName,
  required Future<void> Function() onReturn,
}) async {
  final name = customerName.trim();
  final uri = name.isEmpty
      ? '/customers/$customerId/notes'
      : '/customers/$customerId/notes?customerName=${Uri.encodeComponent(name)}';
  await context.push(uri);
  if (context.mounted) {
    await onReturn();
  }
}

void openCustomerMeasurementHistory({
  required BuildContext context,
  required String customerId,
  required String customerName,
}) {
  final name = customerName.trim();
  final uri = name.isEmpty
      ? '/customers/$customerId/measurements/history'
      : '/customers/$customerId/measurements/history?customerName=${Uri.encodeComponent(name)}';
  navigateTo(context, uri);
}

void openCustomerWorkoutEditor({
  required BuildContext context,
  required String customerId,
  String? planId,
}) {
  navigateTo(
    context,
    customerWorkoutEditorPath(customerId, planId: planId),
  );
}

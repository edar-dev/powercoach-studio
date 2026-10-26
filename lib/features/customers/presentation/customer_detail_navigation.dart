import 'package:flutter/material.dart';

import '../../../core/routing/app_navigation.dart';

void openCustomerDetailNotes({
  required BuildContext context,
  required String customerId,
  required String customerName,
}) {
  final name = customerName.trim();
  final uri = name.isEmpty
      ? '/customers/$customerId/notes'
      : '/customers/$customerId/notes?customerName=${Uri.encodeComponent(name)}';
  navigateTo(context, uri);
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

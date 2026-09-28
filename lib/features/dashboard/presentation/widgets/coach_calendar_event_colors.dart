import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../domain/plan_calendar_event.dart';

/// Stable palette color for a calendar event (by status, then customer).
Color coachCalendarEventColor(PlanCalendarEvent event) {
  if (event.status == PlanSessionStatus.completed) {
    return MarketingDarkColors.emerald;
  }
  if (event.status == PlanSessionStatus.skipped) {
    return const Color(0xFFFB7185);
  }
  final palette = <Color>[
    MarketingDarkColors.brandMid,
    MarketingDarkColors.indigo,
    MarketingDarkColors.cyanBright,
    MarketingDarkColors.brandLight,
    const Color(0xFFA78BFA),
  ];
  final hash = event.customerId.hashCode.abs();
  return palette[hash % palette.length];
}

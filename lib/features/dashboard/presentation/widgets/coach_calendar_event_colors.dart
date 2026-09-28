import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
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

/// Phone Stitch legend / dot colors (workout / completed / check-in-mapped).
///
/// Planned → workout (`primaryContainer`), completed → tertiary,
/// skipped → secondary (no check-in model; maps third legend slot).
Color coachCalendarPhoneEventColor(PlanCalendarEvent event) {
  return switch (event.status) {
    PlanSessionStatus.completed => StitchMobileColors.tertiary,
    PlanSessionStatus.skipped => StitchMobileColors.secondary,
    PlanSessionStatus.planned => StitchMobileColors.primaryContainer,
  };
}

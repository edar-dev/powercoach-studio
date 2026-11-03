import 'package:flutter/material.dart';

import '../../../../core/billing/plan_gate.dart';
import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/widgets/stitch_secondary_app_bar.dart';
import '../backup_onboarding_dialog.dart';
import 'settings_hub_nav.dart';

/// Dual-chrome shell for settings child routes.
///
/// Wide layouts: left [SettingsHubNav] (280px) + content.
/// Phone: [StitchSecondaryAppBar] with [title] (and optional [actions]).
/// Optional [footer] sits sticky at the bottom for unsaved CTAs.
class SettingsChildShell extends StatelessWidget {
  const SettingsChildShell({
    super.key,
    required this.activeSection,
    required this.title,
    required this.body,
    this.footer,
    this.actions,
  });

  final SettingsHubSection activeSection;
  final String title;
  final Widget body;
  final Widget? footer;
  final List<Widget>? actions;

  static const double navWidth = 280;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    final languageTrailing =
        AppLocaleController.instance.locale.languageCode.toUpperCase();

    if (phone) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.stitchPageBg,
        appBar: StitchSecondaryAppBar(
          title: title,
          actions: actions,
        ),
        body: _BodyStack(body: body, footer: footer),
      );
    }

    final nav = SettingsHubNav(
      active: activeSection,
      languageTrailing: languageTrailing,
      onSelect: (section) => navigateSettingsHubSection(context, section),
    );

    return Scaffold(
      backgroundColor: MarketingDarkColors.stitchPageBg,
      // Overlay routes still need a back affordance outside the primary rail.
      appBar: StitchSecondaryAppBar(title: title, actions: actions),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: navWidth,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(child: nav),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _BodyStack(body: body, footer: footer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyStack extends StatelessWidget {
  const _BodyStack({required this.body, this.footer});

  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: body),
        if (footer != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: footer!,
          ),
      ],
    );
  }
}

/// Shared settings-hub section navigation used by the hub and child shell.
Future<void> navigateSettingsHubSection(
  BuildContext context,
  SettingsHubSection section,
) async {
  switch (section) {
    case SettingsHubSection.personalInfo:
      navigateTo(context, AppPaths.personalInfo);
      return;
    case SettingsHubSection.pdfBrand:
      if (!await PlanGate.requirePro(
        context,
        feature: PaywallFeature.pdfBrand,
      )) {
        return;
      }
      if (!context.mounted) return;
      navigateTo(context, AppPaths.pdfBrand);
      return;
    case SettingsHubSection.dataHealth:
      navigateTo(context, AppPaths.dataHealth);
      return;
    case SettingsHubSection.language:
      navigateTo(context, AppPaths.localization);
      return;
    case SettingsHubSection.subscription:
      navigateToSubscription(context);
      return;
    case SettingsHubSection.privacy:
      openPrivacyPolicy();
      return;
    case SettingsHubSection.terms:
      openTermsOfService();
      return;
    case SettingsHubSection.notifications:
      navigateTo(context, '${AppPaths.settings}?section=notifications');
      return;
    case SettingsHubSection.backup:
      navigateTo(context, '${AppPaths.settings}?section=backup');
      return;
  }
}

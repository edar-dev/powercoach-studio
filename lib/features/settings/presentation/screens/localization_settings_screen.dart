import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_child_shell.dart';
import '../widgets/settings_hub_nav.dart';
import '../widgets/settings_unsaved_bar.dart';

/// Settings child: language + live format preview + regional readouts.
///
/// Timezone is system-derived and read-only — persisted TZ preference is deferred.
class LocalizationSettingsScreen extends StatefulWidget {
  const LocalizationSettingsScreen({super.key});

  @override
  State<LocalizationSettingsScreen> createState() =>
      _LocalizationSettingsScreenState();
}

class _LocalizationSettingsScreenState
    extends State<LocalizationSettingsScreen> {
  late String _pendingCode;
  late String _appliedCode;

  @override
  void initState() {
    super.initState();
    _appliedCode = AppLocaleController.instance.locale.languageCode;
    _pendingCode = _appliedCode;
    AppLocaleController.instance.addListener(_onExternalLocale);
  }

  @override
  void dispose() {
    AppLocaleController.instance.removeListener(_onExternalLocale);
    super.dispose();
  }

  bool get _dirty => _pendingCode != _appliedCode;

  void _onExternalLocale() {
    final live = AppLocaleController.instance.locale.languageCode;
    if (!mounted || _dirty || live == _appliedCode) return;
    setState(() {
      _appliedCode = live;
      _pendingCode = live;
    });
  }

  void _selectLocale(String code) {
    if (_pendingCode == code) return;
    setState(() => _pendingCode = code);
  }

  void _cancel() {
    setState(() => _pendingCode = _appliedCode);
  }

  Future<void> _apply() async {
    if (!_dirty) return;
    final l10n = AppLocalizations.of(context);
    await AppLocaleController.instance.setLocale(Locale(_pendingCode));
    if (!mounted) return;
    setState(() => _appliedCode = _pendingCode);
    showAppSnackBar(context, content: Text(l10n.settingsLanguageSaved));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = !Breakpoints.isTabletOrWider(context);

    return SettingsChildShell(
      activeSection: SettingsHubSection.language,
      title: l10n.settingsLocalizationTitle,
      footer: _dirty
          ? SettingsUnsavedBar(
              saving: false,
              onCancel: _cancel,
              onSave: _apply,
              saveLabel: l10n.settingsLocalizationApply,
              showUnsavedHint: !phone,
            )
          : null,
      body: SafeArea(
        child: _LocalizationBody(
          pendingCode: _pendingCode,
          onSelectLocale: _selectLocale,
          bottomPad: _dirty ? (phone ? 120.0 : 96.0) : 24.0,
        ),
      ),
    );
  }
}

class _LocalizationBody extends StatelessWidget {
  const _LocalizationBody({
    required this.pendingCode,
    required this.onSelectLocale,
    required this.bottomPad,
  });

  final String pendingCode;
  final ValueChanged<String> onSelectLocale;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formats = LocalizationFormatPreview.forLanguageCode(pendingCode);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsLocalizationSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
            const SizedBox(height: 20),
            _LivePreviewCard(formats: formats),
            const SizedBox(height: 20),
            Text(
              l10n.settingsLanguageDescription,
              style: theme.textTheme.titleSmall?.copyWith(
                color: MarketingDarkColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 520;
                final it = _LocaleChoiceCard(
                  code: 'it',
                  title: l10n.settingsLanguageItalian,
                  description: l10n.settingsLocalizationItalianDesc,
                  selected: pendingCode == 'it',
                  badge: l10n.settingsLocalizationDefaultBadge,
                  onTap: () => onSelectLocale('it'),
                );
                final en = _LocaleChoiceCard(
                  code: 'en',
                  title: l10n.settingsLanguageEnglish,
                  description: l10n.settingsLocalizationEnglishDesc,
                  selected: pendingCode == 'en',
                  onTap: () => onSelectLocale('en'),
                );
                if (!sideBySide) {
                  return Column(
                    children: [
                      it,
                      const SizedBox(height: 12),
                      en,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: it),
                    const SizedBox(width: 12),
                    Expanded(child: en),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.settingsLocalizationRegionalTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: MarketingDarkColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _ReadOnlyField(
              label: l10n.settingsLocalizationDateFormatLabel,
              value: formats.dateFormatLabel,
            ),
            const SizedBox(height: 10),
            _ReadOnlyField(
              label: l10n.settingsLocalizationNumberFormatLabel,
              value: formats.numberFormatLabel,
            ),
            const SizedBox(height: 10),
            _ReadOnlyField(
              label: l10n.settingsLocalizationFirstDayLabel,
              value: formats.firstDayLabel,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.settingsLocalizationTimezoneTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: MarketingDarkColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _ReadOnlyField(
              label: l10n.settingsLocalizationTimezoneSystem,
              value: formats.systemTimezoneLabel,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.settingsLocalizationTimezoneHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
            // Deferred: persisted studio timezone preference + imperial /
            // true regional format overrides. Values above follow pending UI locale
            // or the device timezone only.
          ],
        ),
      ),
    );
  }
}

/// Locale-driven format samples for the localization live preview.
@visibleForTesting
class LocalizationFormatPreview {
  const LocalizationFormatPreview({
    required this.livePreviewLine,
    required this.dateFormatLabel,
    required this.numberFormatLabel,
    required this.firstDayLabel,
    required this.systemTimezoneLabel,
  });

  final String livePreviewLine;
  final String dateFormatLabel;
  final String numberFormatLabel;
  final String firstDayLabel;
  final String systemTimezoneLabel;

  static LocalizationFormatPreview forLanguageCode(
    String languageCode, {
    DateTime? now,
  }) {
    final locale = languageCode == 'en' ? 'en' : 'it';
    final sample = now ?? DateTime(2026, 11, 2, 12);
    final datePart = DateFormat('EEE d MMM y', locale).format(sample);
    final kg = NumberFormat('#,##0.0', locale).format(1250.5);
    final datePattern = locale == 'it' ? 'DD/MM/YYYY' : 'MM/DD/YYYY';
    final dateSample = DateFormat.yMd(locale).format(sample);
    final numberSample = NumberFormat('#,##0.00', locale).format(1234.56);
    final firstDay = locale == 'it'
        ? DateFormat.EEEE(locale).format(DateTime(2024, 1, 1)) // Monday
        : DateFormat.EEEE(locale).format(DateTime(2023, 12, 31)); // Sunday

    return LocalizationFormatPreview(
      livePreviewLine: '$datePart • $kg kg',
      dateFormatLabel: '$datePattern ($dateSample)',
      numberFormatLabel: '$numberSample ($locale)',
      firstDayLabel: firstDay,
      systemTimezoneLabel: _systemTimezoneLabel(DateTime.now()),
    );
  }

  static String _systemTimezoneLabel(DateTime now) {
    final offset = now.timeZoneOffset;
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final abs = totalMinutes.abs();
    final hours = (abs ~/ 60).toString().padLeft(2, '0');
    final mins = (abs % 60).toString().padLeft(2, '0');
    final name = now.timeZoneName;
    return '(GMT$sign$hours:$mins) $name';
  }
}

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.formats});

  final LocalizationFormatPreview formats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCard,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: MarketingDarkColors.brand),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 20,
                      color: MarketingDarkColors.brandLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsLocalizationPreviewTitle.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: MarketingDarkColors.slate400,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formats.livePreviewLine,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: MarketingDarkColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MarketingDarkColors.brand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.settingsLocalizationPreviewBadge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: MarketingDarkColors.brandLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocaleChoiceCard extends StatelessWidget {
  const _LocaleChoiceCard({
    required this.code,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String code;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: MarketingDarkColors.stitchCard,
      borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
            border: Border.all(
              color: selected
                  ? MarketingDarkColors.brand
                  : MarketingDarkColors.stitchBorderMuted,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? MarketingDarkColors.brand.withValues(alpha: 0.18)
                      : MarketingDarkColors.stitchCardElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? MarketingDarkColors.brandLight
                        : MarketingDarkColors.slate300,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: MarketingDarkColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: selected
                              ? MarketingDarkColors.brand
                              : MarketingDarkColors.slate500,
                        ),
                      ],
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MarketingDarkColors.brand.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: MarketingDarkColors.brandLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MarketingDarkColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: MarketingDarkColors.slate300,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: MarketingDarkColors.stitchCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

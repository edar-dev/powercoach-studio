import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_app_bar.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/settings_hub_nav.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/settings_screen_content.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('slim hub AppBar omits Impostazioni title text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              appBar: StitchAppBar(
                title: l10n.settingsTitle,
                showLogo: false,
                showTitle: false,
              ),
              body: const SizedBox.shrink(),
            );
          },
        ),
      ),
    );

    expect(find.text('Impostazioni'), findsNothing);
  });

  testWidgets('hub nav shows destinations with primary selected fill', (
    tester,
  ) async {
    SettingsHubSection? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsHubNav(
            active: SettingsHubSection.personalInfo,
            languageTrailing: 'IT',
            onSelect: (section) => selected = section,
          ),
        ),
      ),
    );

    expect(find.text('Informazioni personali'), findsOneWidget);
    expect(find.text('Brand PDF'), findsOneWidget);
    expect(find.text('Abbonamento'), findsOneWidget);
    expect(find.text('Notifiche & Promemoria'), findsOneWidget);
    expect(find.text('Backup offline & Cloud'), findsOneWidget);
    expect(find.text('Salute dati'), findsOneWidget);
    expect(find.text('Lingua e formato'), findsOneWidget);
    expect(find.text('Informativa Privacy'), findsOneWidget);
    expect(find.text('Termini di servizio'), findsOneWidget);

    final selectedMaterial = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Informazioni personali'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(selectedMaterial.color, StitchM3Theme.dark.colorScheme.primary);

    await tester.tap(find.text('Abbonamento'));
    await tester.pump();
    expect(selected, SettingsHubSection.subscription);
  });

  testWidgets('wide settings content shows short hub H1 and short subtitle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final scrollController = ScrollController();
    final displayName = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final bio = TextEditingController();
    final avatar = TextEditingController();
    final website = TextEditingController();
    addTearDown(() {
      scrollController.dispose();
      displayName.dispose();
      email.dispose();
      phone.dispose();
      bio.dispose();
      avatar.dispose();
      website.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: const StitchAppBar(
            title: 'Impostazioni',
            showLogo: false,
            showTitle: false,
          ),
          body: SettingsScreenContent(
            l10n: lookupAppLocalizations(const Locale('it')),
            scrollController: scrollController,
            personalKey: GlobalKey(),
            notificationsKey: GlobalKey(),
            backupKey: GlobalKey(),
            activeSection: SettingsHubSection.personalInfo,
            onSectionSelected: (_) {},
            formKey: GlobalKey<FormState>(),
            displayNameController: displayName,
            emailController: email,
            phoneController: phone,
            bioController: bio,
            avatarUrlController: avatar,
            websiteController: website,
            emailVerified: true,
            profileLoadError: null,
            notificationsEnabled: true,
            calendarRemindersEnabled: false,
            calendarReminderLeadHours: 24,
            maximalWeightRoundingKg: 1,
            onNotificationsToggle: (_) {},
            onCalendarRemindersToggle: (_) {},
            onPickCalendarLeadHours: () {},
            onMaximalWeightRoundingChanged: (_) {},
            onExportBackup: () {},
            onImportBackup: () {},
            onUploadCloudBackup: () {},
            onRestoreCloudBackup: () {},
            onSignOut: () {},
            isDirty: false,
            isSaving: false,
            onCancelChanges: () {},
            onSaveProfile: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Impostazioni & Profilo'), findsNothing);
    expect(find.text('Gestione studio e profilo.'), findsOneWidget);
    expect(find.text('Informazioni personali'), findsOneWidget);
    expect(find.text('Abbonamento'), findsOneWidget);
  });

  testWidgets('phone settings pins section headers while scrolling', (
    tester,
  ) async {
    final scrollController = ScrollController();
    final displayName = TextEditingController(text: 'Coach');
    final email = TextEditingController();
    final phoneCtrl = TextEditingController();
    final bio = TextEditingController();
    final avatar = TextEditingController();
    final website = TextEditingController();
    addTearDown(() {
      scrollController.dispose();
      displayName.dispose();
      email.dispose();
      phoneCtrl.dispose();
      bio.dispose();
      avatar.dispose();
      website.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(
            body: SettingsScreenContent(
              l10n: lookupAppLocalizations(const Locale('it')),
              scrollController: scrollController,
              personalKey: GlobalKey(),
              notificationsKey: GlobalKey(),
              backupKey: GlobalKey(),
              activeSection: SettingsHubSection.personalInfo,
              onSectionSelected: (_) {},
              formKey: GlobalKey<FormState>(),
              displayNameController: displayName,
              emailController: email,
              phoneController: phoneCtrl,
              bioController: bio,
              avatarUrlController: avatar,
              websiteController: website,
              emailVerified: true,
              profileLoadError: null,
              notificationsEnabled: true,
              calendarRemindersEnabled: false,
              calendarReminderLeadHours: 24,
              maximalWeightRoundingKg: 1,
              onNotificationsToggle: (_) {},
              onCalendarRemindersToggle: (_) {},
              onPickCalendarLeadHours: () {},
              onMaximalWeightRoundingChanged: (_) {},
              onExportBackup: () {},
              onImportBackup: () {},
              onUploadCloudBackup: () {},
              onRestoreCloudBackup: () {},
              onSignOut: () {},
              isDirty: false,
              isSaving: false,
              onCancelChanges: () {},
              onSaveProfile: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.text('Informazioni personali'), findsWidgets);

    // Later pinned sections are lazy; scroll to bring them into the viewport.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2400));
    await tester.pumpAndSettle();

    expect(find.text('Altro'), findsOneWidget);
    expect(find.byType(SliverPersistentHeader), findsWidgets);
  });
}

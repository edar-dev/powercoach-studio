import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio'**
  String get appTitle;

  /// No description provided for @landingHeroBadge.
  ///
  /// In en, this message translates to:
  /// **'Early access — Beta Coach Studio v2.4'**
  String get landingHeroBadge;

  /// No description provided for @landingTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get landingTitlePrefix;

  /// No description provided for @landingTitleSuffix.
  ///
  /// In en, this message translates to:
  /// **'Coach Studio'**
  String get landingTitleSuffix;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage workout plans for your clients with scientific precision.'**
  String get landingSubtitle;

  /// No description provided for @landingCtaPrimary.
  ///
  /// In en, this message translates to:
  /// **'Start free — No card required'**
  String get landingCtaPrimary;

  /// No description provided for @landingCtaSecondary.
  ///
  /// In en, this message translates to:
  /// **'See pricing & demo'**
  String get landingCtaSecondary;

  /// No description provided for @notImplementedMessage.
  ///
  /// In en, this message translates to:
  /// **'Feature not yet implemented.'**
  String get notImplementedMessage;

  /// No description provided for @landingBrandPowerCoach.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach'**
  String get landingBrandPowerCoach;

  /// No description provided for @landingBrandStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get landingBrandStudio;

  /// No description provided for @landingEarlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Early access'**
  String get landingEarlyAccess;

  /// No description provided for @landingBetaVersion.
  ///
  /// In en, this message translates to:
  /// **'Beta Coach Studio v2.4'**
  String get landingBetaVersion;

  /// No description provided for @landingHeroLeadBefore.
  ///
  /// In en, this message translates to:
  /// **'Create and manage workout plans for your clients with '**
  String get landingHeroLeadBefore;

  /// No description provided for @landingHeroLeadEmphasis.
  ///
  /// In en, this message translates to:
  /// **'scientific precision'**
  String get landingHeroLeadEmphasis;

  /// No description provided for @landingHeroLeadAfter.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get landingHeroLeadAfter;

  /// No description provided for @landingHeroSupporting.
  ///
  /// In en, this message translates to:
  /// **'The modular platform built for strength coaches, athletic trainers, and professional personal trainers. Block periodization, customizable microcycles, and real-time load tracking.'**
  String get landingHeroSupporting;

  /// No description provided for @landingCtaStartFreeNoCard.
  ///
  /// In en, this message translates to:
  /// **'Already invited? Sign in'**
  String get landingCtaStartFreeNoCard;

  /// No description provided for @landingCtaSeePricingDemo.
  ///
  /// In en, this message translates to:
  /// **'See pricing & demo'**
  String get landingCtaSeePricingDemo;

  /// No description provided for @landingTrustExercises.
  ///
  /// In en, this message translates to:
  /// **'266+ Preconfigured exercises'**
  String get landingTrustExercises;

  /// No description provided for @landingTrustOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline-First architecture'**
  String get landingTrustOffline;

  /// No description provided for @landingTrustExport.
  ///
  /// In en, this message translates to:
  /// **'PDF export & fast sharing'**
  String get landingTrustExport;

  /// No description provided for @landingPreviewEditorLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan editor — Max Strength Mesocycle (Accumulation W2)'**
  String get landingPreviewEditorLabel;

  /// No description provided for @landingStatusOfflineFirst.
  ///
  /// In en, this message translates to:
  /// **'Offline-First'**
  String get landingStatusOfflineFirst;

  /// No description provided for @landingNavFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get landingNavFeatures;

  /// No description provided for @landingNavLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get landingNavLibrary;

  /// No description provided for @landingNavPhases.
  ///
  /// In en, this message translates to:
  /// **'Phase Planning'**
  String get landingNavPhases;

  /// No description provided for @landingFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get landingFeaturesTitle;

  /// No description provided for @landingFeaturesHeadline.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to scale.'**
  String get landingFeaturesHeadline;

  /// No description provided for @landingFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on what you do best—coaching. We handle logistics, block periodization, and tracking.'**
  String get landingFeaturesDesc;

  /// No description provided for @landingFeaturesCustomers.
  ///
  /// In en, this message translates to:
  /// **'Client & plan management'**
  String get landingFeaturesCustomers;

  /// No description provided for @landingFeaturesEditor.
  ///
  /// In en, this message translates to:
  /// **'Visual editor for modular phase plans'**
  String get landingFeaturesEditor;

  /// No description provided for @landingFeaturesClientData.
  ///
  /// In en, this message translates to:
  /// **'Client data & library'**
  String get landingFeaturesClientData;

  /// No description provided for @landingFeaturesExport.
  ///
  /// In en, this message translates to:
  /// **'PDF export & custom exercise DB'**
  String get landingFeaturesExport;

  /// No description provided for @landingFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Client & plan management'**
  String get landingFeature1Title;

  /// No description provided for @landingFeature1Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Visual editor for modular phase plans'**
  String get landingFeature1Eyebrow;

  /// No description provided for @landingFeature1Body.
  ///
  /// In en, this message translates to:
  /// **'Structure advanced programming into microcycles and mesocycles (Accumulation, Intensification, Realization, Deload). Assign volume progressions, 1RM-based percentages, RPE, and detailed execution notes.'**
  String get landingFeature1Body;

  /// No description provided for @landingFeature1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Visual timeline with automatic tonnage calculation'**
  String get landingFeature1Bullet1;

  /// No description provided for @landingFeature1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Duplicate mesocycles across athletes with automated progression'**
  String get landingFeature1Bullet2;

  /// No description provided for @landingFeature1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-ins with immediate alerts'**
  String get landingFeature1Bullet3;

  /// No description provided for @landingFeature1FooterLeft.
  ///
  /// In en, this message translates to:
  /// **'Responsive drag & drop editor'**
  String get landingFeature1FooterLeft;

  /// No description provided for @landingFeature1FooterRight.
  ///
  /// In en, this message translates to:
  /// **'100% Customizable'**
  String get landingFeature1FooterRight;

  /// No description provided for @landingFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Client data & library'**
  String get landingFeature2Title;

  /// No description provided for @landingFeature2Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'PDF export & custom exercise DB'**
  String get landingFeature2Eyebrow;

  /// No description provided for @landingFeature2Body.
  ///
  /// In en, this message translates to:
  /// **'Internal database with 266+ exercises classified by muscle group, resistance curve, and biomechanical pattern. Generate high-resolution PDF prints or share interactive links ready for your client\'s phone.'**
  String get landingFeature2Body;

  /// No description provided for @landingFeature2Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Fast folders: Presses, Squats, Push, Pull'**
  String get landingFeature2Bullet1;

  /// No description provided for @landingFeature2Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Professional PDF export with tutorial video QR codes'**
  String get landingFeature2Bullet2;

  /// No description provided for @landingFeature2Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Custom fields for angles, wedges, and grip type'**
  String get landingFeature2Bullet3;

  /// No description provided for @landingFeature2FooterLeft.
  ///
  /// In en, this message translates to:
  /// **'266+ Ready variants'**
  String get landingFeature2FooterLeft;

  /// No description provided for @landingFeature2FooterRight.
  ///
  /// In en, this message translates to:
  /// **'A4 & Mobile export'**
  String get landingFeature2FooterRight;

  /// No description provided for @landingFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Superset, Cluster & Jump Set'**
  String get landingFeature3Title;

  /// No description provided for @landingFeature3Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Advanced intensity methodology tools'**
  String get landingFeature3Eyebrow;

  /// No description provided for @landingFeature3Body.
  ///
  /// In en, this message translates to:
  /// **'Group exercises in one click. Configure antagonist pairings, drop sets, myo-reps, and differentiated intra/inter-set rests with a preset audio timer.'**
  String get landingFeature3Body;

  /// No description provided for @landingFeature3Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Letter color coding (A1-A2, B1-B2)'**
  String get landingFeature3Bullet1;

  /// No description provided for @landingFeature3Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Session density calculation (kg per minute of work)'**
  String get landingFeature3Bullet2;

  /// No description provided for @landingFeature3Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Timed circuits, EMOM, and AMRAP for conditioning'**
  String get landingFeature3Bullet3;

  /// No description provided for @landingFeature3FooterLeft.
  ///
  /// In en, this message translates to:
  /// **'Advanced methodologies'**
  String get landingFeature3FooterLeft;

  /// No description provided for @landingFeature3FooterRight.
  ///
  /// In en, this message translates to:
  /// **'Zero Confusion'**
  String get landingFeature3FooterRight;

  /// No description provided for @landingFeature4Title.
  ///
  /// In en, this message translates to:
  /// **'Protected data & Offline-First'**
  String get landingFeature4Title;

  /// No description provided for @landingFeature4Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Data stays stored locally on your device'**
  String get landingFeature4Eyebrow;

  /// No description provided for @landingFeature4Body.
  ///
  /// In en, this message translates to:
  /// **'Never lose an edit even if the gym Wi‑Fi drops. All programs are stored on-device. Use JSON backups or optional snapshots to move between devices.'**
  String get landingFeature4Body;

  /// No description provided for @landingFeature4Bullet1.
  ///
  /// In en, this message translates to:
  /// **'One-click JSON/CSV backup export'**
  String get landingFeature4Bullet1;

  /// No description provided for @landingFeature4Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Native-speed performance with no loading delays'**
  String get landingFeature4Bullet2;

  /// No description provided for @landingFeature4Bullet3.
  ///
  /// In en, this message translates to:
  /// **'GDPR-aligned security standards for athlete data'**
  String get landingFeature4Bullet3;

  /// No description provided for @landingFeature4FooterLeft.
  ///
  /// In en, this message translates to:
  /// **'Local database'**
  String get landingFeature4FooterLeft;

  /// No description provided for @landingFeature4FooterRight.
  ///
  /// In en, this message translates to:
  /// **'Always Available'**
  String get landingFeature4FooterRight;

  /// No description provided for @landingHowItWorksLabel.
  ///
  /// In en, this message translates to:
  /// **'Scientific planning'**
  String get landingHowItWorksLabel;

  /// No description provided for @landingHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'Linear or block periodization—without unreadable spreadsheets.'**
  String get landingHowItWorksTitle;

  /// No description provided for @landingHowItWorksStep1.
  ///
  /// In en, this message translates to:
  /// **'Create a customer profile'**
  String get landingHowItWorksStep1;

  /// No description provided for @landingHowItWorksStep2.
  ///
  /// In en, this message translates to:
  /// **'Create workout plans'**
  String get landingHowItWorksStep2;

  /// No description provided for @landingHowItWorksStep3.
  ///
  /// In en, this message translates to:
  /// **'Add exercises, sets, and reps'**
  String get landingHowItWorksStep3;

  /// No description provided for @landingHowItWorksStep4.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get landingHowItWorksStep4;

  /// No description provided for @landingPhasesBadge.
  ///
  /// In en, this message translates to:
  /// **'Scientific planning'**
  String get landingPhasesBadge;

  /// No description provided for @landingPhasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Linear or block periodization—without unreadable spreadsheets.'**
  String get landingPhasesTitle;

  /// No description provided for @landingPhasesBody.
  ///
  /// In en, this message translates to:
  /// **'Drop chaotic tables. Coach Studio charts weekly volume, suggests load increases based on RPE/RIR, and lets athletes log results in their own logbook.'**
  String get landingPhasesBody;

  /// No description provided for @landingPhasesCtaPrimary.
  ///
  /// In en, this message translates to:
  /// **'Already invited? Sign in'**
  String get landingPhasesCtaPrimary;

  /// No description provided for @landingPhasesCtaSecondary.
  ///
  /// In en, this message translates to:
  /// **'Explore the Exercise Library'**
  String get landingPhasesCtaSecondary;

  /// No description provided for @landingCtaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to reinvent your coaching method?'**
  String get landingCtaSectionTitle;

  /// No description provided for @landingCtaSectionSubtext.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio is an invite-only beta. If you received an invite email, sign in and manage athletes with modern tools.'**
  String get landingCtaSectionSubtext;

  /// No description provided for @landingCtaSectionButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingCtaSectionButton;

  /// No description provided for @landingCtaSectionSubtextLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Go to your profile or dashboard to continue.'**
  String get landingCtaSectionSubtextLoggedIn;

  /// No description provided for @landingCtaSectionButtonLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get landingCtaSectionButtonLoggedIn;

  /// No description provided for @landingCtaCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Already invited? Sign in'**
  String get landingCtaCreateAccount;

  /// No description provided for @landingCtaFootnote.
  ///
  /// In en, this message translates to:
  /// **'Invite-only access · No public registration'**
  String get landingCtaFootnote;

  /// No description provided for @landingNavPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get landingNavPricing;

  /// No description provided for @landingBetaBadge.
  ///
  /// In en, this message translates to:
  /// **'Early access — Beta Coach Studio v2.4'**
  String get landingBetaBadge;

  /// No description provided for @landingCtaStartFree.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingCtaStartFree;

  /// No description provided for @landingCtaSeePricing.
  ///
  /// In en, this message translates to:
  /// **'See pricing'**
  String get landingCtaSeePricing;

  /// No description provided for @landingFooterTagline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first athletic monitoring and planning for coaches, trainers, and demanding athletes.'**
  String get landingFooterTagline;

  /// No description provided for @landingFooterSystemsOk.
  ///
  /// In en, this message translates to:
  /// **'All systems operational'**
  String get landingFooterSystemsOk;

  /// No description provided for @landingPricingLabel.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get landingPricingLabel;

  /// No description provided for @landingPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that fits you'**
  String get landingPricingTitle;

  /// No description provided for @landingPricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan up to 5 clients (invite-only access). Upgrade to Pro as you grow.'**
  String get landingPricingSubtitle;

  /// No description provided for @landingPricingFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get landingPricingFreeTitle;

  /// No description provided for @landingPricingFreePrice.
  ///
  /// In en, this message translates to:
  /// **'€0'**
  String get landingPricingFreePrice;

  /// No description provided for @landingPricingFreePeriod.
  ///
  /// In en, this message translates to:
  /// **'forever'**
  String get landingPricingFreePeriod;

  /// No description provided for @landingPricingFreeCta.
  ///
  /// In en, this message translates to:
  /// **'Already invited? Sign in'**
  String get landingPricingFreeCta;

  /// No description provided for @landingPricingProTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get landingPricingProTitle;

  /// No description provided for @landingPricingProPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'€12/month'**
  String get landingPricingProPriceMonthly;

  /// No description provided for @landingPricingProPriceYearly.
  ///
  /// In en, this message translates to:
  /// **'€99/year'**
  String get landingPricingProPriceYearly;

  /// No description provided for @landingPricingProCta.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get landingPricingProCta;

  /// No description provided for @landingPricingProCtaLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get landingPricingProCtaLoggedIn;

  /// No description provided for @landingPricingBetaNote.
  ///
  /// In en, this message translates to:
  /// **'During the closed beta you can activate Pro for free with a Pro promo code after signing in.'**
  String get landingPricingBetaNote;

  /// No description provided for @landingPricingFeatureCustomersFree.
  ///
  /// In en, this message translates to:
  /// **'Up to {max} active clients'**
  String landingPricingFeatureCustomersFree(int max);

  /// No description provided for @landingPricingFeatureCustomersPro.
  ///
  /// In en, this message translates to:
  /// **'Unlimited clients'**
  String get landingPricingFeatureCustomersPro;

  /// No description provided for @landingPricingFeatureBuilder.
  ///
  /// In en, this message translates to:
  /// **'Full workout builder'**
  String get landingPricingFeatureBuilder;

  /// No description provided for @landingPricingFeatureExportPro.
  ///
  /// In en, this message translates to:
  /// **'PDF, Excel & CSV export'**
  String get landingPricingFeatureExportPro;

  /// No description provided for @landingFaqLabel.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get landingFaqLabel;

  /// No description provided for @landingFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get landingFaqTitle;

  /// No description provided for @landingFaqLocalDataQ.
  ///
  /// In en, this message translates to:
  /// **'Where is my data stored?'**
  String get landingFaqLocalDataQ;

  /// No description provided for @landingFaqLocalDataA.
  ///
  /// In en, this message translates to:
  /// **'On your device or browser (local-first) — your data stays yours. No automatic sync: use a JSON backup or an optional cloud snapshot on your account to move between devices.'**
  String get landingFaqLocalDataA;

  /// No description provided for @landingFaqDeskGymQ.
  ///
  /// In en, this message translates to:
  /// **'Can I plan on desktop and train at the gym?'**
  String get landingFaqDeskGymQ;

  /// No description provided for @landingFaqDeskGymA.
  ///
  /// In en, this message translates to:
  /// **'Yes. Build the program on desktop, then open the same account on your phone at the gym to log sets, RPE, and pain — no separate app, no sync setup to configure.'**
  String get landingFaqDeskGymA;

  /// No description provided for @landingFaqFreeProQ.
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between Free and Pro?'**
  String get landingFaqFreeProQ;

  /// No description provided for @landingFaqFreeProA.
  ///
  /// In en, this message translates to:
  /// **'Free includes up to 5 clients and all core builder features. Pro unlocks unlimited clients and advanced exports (PDF, Excel, progress CSV).'**
  String get landingFaqFreeProA;

  /// No description provided for @landingFaqBetaQ.
  ///
  /// In en, this message translates to:
  /// **'How do I join the beta?'**
  String get landingFaqBetaQ;

  /// No description provided for @landingFaqBetaA.
  ///
  /// In en, this message translates to:
  /// **'App access is invite-only: an admin invites you by email. After the invite, set your password and sign in. Separately, Pro promo codes unlock Pro after login — they are not the key to app access.'**
  String get landingFaqBetaA;

  /// No description provided for @landingFaqBrowserQ.
  ///
  /// In en, this message translates to:
  /// **'What if I clear browser data?'**
  String get landingFaqBrowserQ;

  /// No description provided for @landingFaqBrowserA.
  ///
  /// In en, this message translates to:
  /// **'Local data may be lost. Export a JSON backup (or save a cloud snapshot) from Settings before clearing cache or cookies.'**
  String get landingFaqBrowserA;

  /// No description provided for @landingFaqBillingQ.
  ///
  /// In en, this message translates to:
  /// **'How does billing work?'**
  String get landingFaqBillingQ;

  /// No description provided for @landingFaqBillingA.
  ///
  /// In en, this message translates to:
  /// **'Pro is activated via Stripe on the web. Manage renewal and invoices from the Subscription screen.'**
  String get landingFaqBillingA;

  /// No description provided for @landingPwaTitle.
  ///
  /// In en, this message translates to:
  /// **'Use PowerCoach like an app'**
  String get landingPwaTitle;

  /// No description provided for @landingPwaMessage.
  ///
  /// In en, this message translates to:
  /// **'On Chrome/Edge: browser menu → Install app. On iPhone: Share → Add to Home Screen.'**
  String get landingPwaMessage;

  /// No description provided for @landingFooterCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} PowerCoach Studio'**
  String landingFooterCopyright(int year);

  /// No description provided for @landingFooterPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get landingFooterPrivacy;

  /// No description provided for @landingFooterTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get landingFooterTerms;

  /// No description provided for @subscriptionCheckoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Checkout cancelled.'**
  String get subscriptionCheckoutCancel;

  /// No description provided for @headerLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get headerLogin;

  /// No description provided for @headerJoinNow.
  ///
  /// In en, this message translates to:
  /// **'Join now'**
  String get headerJoinNow;

  /// No description provided for @registrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registrationTitle;

  /// No description provided for @registrationEmail.
  ///
  /// In en, this message translates to:
  /// **'Professional email'**
  String get registrationEmail;

  /// No description provided for @registrationEmailHint.
  ///
  /// In en, this message translates to:
  /// **'mario.rossi@powercoach.it'**
  String get registrationEmailHint;

  /// No description provided for @registrationPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registrationPassword;

  /// No description provided for @registrationConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registrationConfirmPassword;

  /// No description provided for @registrationSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account and start free trial'**
  String get registrationSubmit;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account.'**
  String get registrationSuccessMessage;

  /// No description provided for @registrationSuccessReady.
  ///
  /// In en, this message translates to:
  /// **'Account created. Signing you in…'**
  String get registrationSuccessReady;

  /// No description provided for @registrationCheckEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get registrationCheckEmailTitle;

  /// No description provided for @registrationCheckEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Open the link, then sign in.'**
  String registrationCheckEmailBody(String email);

  /// No description provided for @registrationCheckEmailSpamHint.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Check your spam folder too.'**
  String get registrationCheckEmailSpamHint;

  /// No description provided for @registrationResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend confirmation email'**
  String get registrationResendEmail;

  /// No description provided for @registrationResendEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Confirmation email sent again.'**
  String get registrationResendEmailSuccess;

  /// No description provided for @registrationResendEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not resend the email. Try again in a few minutes.'**
  String get registrationResendEmailError;

  /// No description provided for @registrationGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get registrationGoToLogin;

  /// No description provided for @registrationErrorAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get registrationErrorAlreadyRegistered;

  /// No description provided for @registrationErrorPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters, 1 number, and 1 special character.'**
  String get registrationErrorPasswordWeak;

  /// No description provided for @registrationErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get registrationErrorInvalidEmail;

  /// No description provided for @registrationErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registrationErrorPasswordMismatch;

  /// No description provided for @registrationErrorPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get registrationErrorPasswordEmpty;

  /// No description provided for @registrationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationErrorGeneric;

  /// No description provided for @registrationErrorSignupsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Public registration is not available. Access is invite-only: if you received an invite, sign in with your credentials.'**
  String get registrationErrorSignupsDisabled;

  /// No description provided for @registrationErrorNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Required field.'**
  String get registrationErrorNameEmpty;

  /// No description provided for @registrationAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have a coach account?'**
  String get registrationAlreadyHaveAccount;

  /// No description provided for @registrationLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get registrationLoginLink;

  /// No description provided for @registrationHeadline.
  ///
  /// In en, this message translates to:
  /// **'Create your Coach account'**
  String get registrationHeadline;

  /// No description provided for @registrationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio'**
  String get registrationEyebrow;

  /// No description provided for @registrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the scientific programming and athlete management platform.'**
  String get registrationSubtitle;

  /// No description provided for @registrationTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'14-day free trial · No card required'**
  String get registrationTrialBadge;

  /// No description provided for @registrationTrustExercises.
  ///
  /// In en, this message translates to:
  /// **'266+ Exercises included'**
  String get registrationTrustExercises;

  /// No description provided for @registrationTrustOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline-First'**
  String get registrationTrustOffline;

  /// No description provided for @registrationTrustMesocycles.
  ///
  /// In en, this message translates to:
  /// **'Advanced mesocycles'**
  String get registrationTrustMesocycles;

  /// No description provided for @registrationFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registrationFirstName;

  /// No description provided for @registrationFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mario'**
  String get registrationFirstNameHint;

  /// No description provided for @registrationLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registrationLastName;

  /// No description provided for @registrationLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Rossi'**
  String get registrationLastNameHint;

  /// No description provided for @registrationSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Primary specialization'**
  String get registrationSpecialty;

  /// No description provided for @registrationSpecialtyPt.
  ///
  /// In en, this message translates to:
  /// **'Personal Trainer'**
  String get registrationSpecialtyPt;

  /// No description provided for @registrationSpecialtyAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic Prep'**
  String get registrationSpecialtyAthletic;

  /// No description provided for @registrationSpecialtyPowerlifting.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get registrationSpecialtyPowerlifting;

  /// No description provided for @registrationPasswordRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 chars · 1 num. · 1 special'**
  String get registrationPasswordRulesHint;

  /// No description provided for @registrationPasswordSecurity.
  ///
  /// In en, this message translates to:
  /// **'Strength:'**
  String get registrationPasswordSecurity;

  /// No description provided for @registrationPasswordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get registrationPasswordStrengthWeak;

  /// No description provided for @registrationPasswordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get registrationPasswordStrengthFair;

  /// No description provided for @registrationPasswordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get registrationPasswordStrengthGood;

  /// No description provided for @registrationPasswordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get registrationPasswordStrengthStrong;

  /// No description provided for @registrationTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get registrationTermsPrefix;

  /// No description provided for @registrationTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get registrationTermsOfService;

  /// No description provided for @registrationTermsMiddle.
  ///
  /// In en, this message translates to:
  /// **'and confirm I have read the'**
  String get registrationTermsMiddle;

  /// No description provided for @registrationPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get registrationPrivacyPolicy;

  /// No description provided for @registrationAcceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue.'**
  String get registrationAcceptTermsError;

  /// No description provided for @registrationOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get registrationOrContinueWith;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginTitle;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Coach!'**
  String get loginHeadline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your workspace to manage athletes, mesocycles, and the biomechanics library.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get loginEmail;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. marco@coachstudio.it'**
  String get loginEmailHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in to workspace'**
  String get loginSubmit;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Access is invite-only.'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'How to get access'**
  String get loginRegisterLink;

  /// No description provided for @loginTrialChip.
  ///
  /// In en, this message translates to:
  /// **'14-day trial'**
  String get loginTrialChip;

  /// No description provided for @loginRoleCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach / Trainer'**
  String get loginRoleCoach;

  /// No description provided for @loginRoleAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get loginRoleAthlete;

  /// No description provided for @loginAthleteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Athlete login is not available yet. PowerCoach Studio is built for coaches.'**
  String get loginAthleteUnavailable;

  /// No description provided for @loginStaySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in on this device'**
  String get loginStaySignedIn;

  /// No description provided for @loginStaySignedInOffline.
  ///
  /// In en, this message translates to:
  /// **'(Offline-First)'**
  String get loginStaySignedInOffline;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get loginErrorPasswordEmpty;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginErrorGeneric;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email before signing in.'**
  String get loginErrorEmailNotConfirmed;

  /// No description provided for @loginErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get loginErrorTooManyRequests;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginSuccessMessage;

  /// No description provided for @authInviteOnlyBadge.
  ///
  /// In en, this message translates to:
  /// **'Invite-only access'**
  String get authInviteOnlyBadge;

  /// No description provided for @authInviteOnlyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Access by invitation only'**
  String get authInviteOnlyHeadline;

  /// No description provided for @authInviteOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio does not offer public registration. An admin invites you by email: after the invite, set your password and sign in to your coach workspace.'**
  String get authInviteOnlyBody;

  /// No description provided for @authInviteOnlyLoginCta.
  ///
  /// In en, this message translates to:
  /// **'Already invited? Sign in'**
  String get authInviteOnlyLoginCta;

  /// No description provided for @authInviteOnlyProNote.
  ///
  /// In en, this message translates to:
  /// **'Pro promo codes unlock Pro after you have an account — they do not grant app access.'**
  String get authInviteOnlyProNote;

  /// No description provided for @authBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get authBackHome;

  /// No description provided for @authBackLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authBackLogin;

  /// No description provided for @authEncryptionBadge.
  ///
  /// In en, this message translates to:
  /// **'256-bit encryption active'**
  String get authEncryptionBadge;

  /// No description provided for @authEncryptionBadgeShort.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get authEncryptionBadgeShort;

  /// No description provided for @authSocialUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google/Apple sign-in is not available yet. Use email and password.'**
  String get authSocialUnavailable;

  /// No description provided for @authFooterCompliance.
  ///
  /// In en, this message translates to:
  /// **'256-bit AES encryption · GDPR compliant · Secure local backup'**
  String get authFooterCompliance;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordInstruction;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordSubmit;

  /// No description provided for @forgotPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your email for the reset link.'**
  String get forgotPasswordSuccessMessage;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email. Try again.'**
  String get forgotPasswordError;

  /// No description provided for @headerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get headerProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileAvatarUrl.
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get profileAvatarUrl;

  /// No description provided for @profileWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get profileWebsite;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSavedMessage;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile.'**
  String get profileLoadError;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile.'**
  String get profileSaveError;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get settingsPersonalInfo;

  /// No description provided for @settingsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscription;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsPersonalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get settingsPersonalInfoTitle;

  /// No description provided for @settingsSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSubscriptionTitle;

  /// No description provided for @subscriptionCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get subscriptionCurrentPlan;

  /// No description provided for @subscriptionPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionPlanFree;

  /// No description provided for @subscriptionPlanPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get subscriptionPlanPro;

  /// No description provided for @subscriptionUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get subscriptionUpgrade;

  /// No description provided for @subscriptionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get subscriptionManage;

  /// No description provided for @subscriptionUpgradeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Pro — €12/month'**
  String get subscriptionUpgradeMonthly;

  /// No description provided for @subscriptionUpgradeYearly.
  ///
  /// In en, this message translates to:
  /// **'Pro — €99/year'**
  String get subscriptionUpgradeYearly;

  /// No description provided for @subscriptionCheckoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated. Thank you!'**
  String get subscriptionCheckoutSuccess;

  /// No description provided for @subscriptionCheckoutError.
  ///
  /// In en, this message translates to:
  /// **'Could not start checkout. Please try again.'**
  String get subscriptionCheckoutError;

  /// No description provided for @subscriptionPortalError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the subscription portal.'**
  String get subscriptionPortalError;

  /// No description provided for @subscriptionWebOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Stripe subscription management is available on the web app only.'**
  String get subscriptionWebOnlyHint;

  /// No description provided for @subscriptionStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionStatusActive;

  /// No description provided for @subscriptionStatusTrialing.
  ///
  /// In en, this message translates to:
  /// **'Trialing'**
  String get subscriptionStatusTrialing;

  /// No description provided for @subscriptionStatusPastDue.
  ///
  /// In en, this message translates to:
  /// **'Payment past due'**
  String get subscriptionStatusPastDue;

  /// No description provided for @subscriptionStatusPastDueDetail.
  ///
  /// In en, this message translates to:
  /// **'Update your payment method in the subscription portal to avoid service interruption.'**
  String get subscriptionStatusPastDueDetail;

  /// No description provided for @subscriptionStatusGrace.
  ///
  /// In en, this message translates to:
  /// **'Canceling'**
  String get subscriptionStatusGrace;

  /// No description provided for @subscriptionStatusGraceUntil.
  ///
  /// In en, this message translates to:
  /// **'Pro access until {date}.'**
  String subscriptionStatusGraceUntil(String date);

  /// No description provided for @subscriptionStatusRenewsOn.
  ///
  /// In en, this message translates to:
  /// **'Next renewal: {date}.'**
  String subscriptionStatusRenewsOn(String date);

  /// No description provided for @subscriptionStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get subscriptionStatusExpired;

  /// No description provided for @subscriptionStatusExpiredDetail.
  ///
  /// In en, this message translates to:
  /// **'Your Pro subscription is no longer active.'**
  String get subscriptionStatusExpiredDetail;

  /// No description provided for @subscriptionStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionStatusFree;

  /// No description provided for @subscriptionStatusFreeDetail.
  ///
  /// In en, this message translates to:
  /// **'Request a Pro promo code or enter one you received to unlock Pro.'**
  String get subscriptionStatusFreeDetail;

  /// No description provided for @subscriptionUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan usage'**
  String get subscriptionUsageTitle;

  /// No description provided for @subscriptionUsageCustomers.
  ///
  /// In en, this message translates to:
  /// **'{current} / {max} active clients'**
  String subscriptionUsageCustomers(int current, int max);

  /// No description provided for @subscriptionUsageNearLimit.
  ///
  /// In en, this message translates to:
  /// **'You are close to the Free plan client limit.'**
  String get subscriptionUsageNearLimit;

  /// No description provided for @subscriptionUsageAtLimit.
  ///
  /// In en, this message translates to:
  /// **'You reached the active client limit. Upgrade to Pro to add more.'**
  String get subscriptionUsageAtLimit;

  /// No description provided for @subscriptionCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get subscriptionCompareTitle;

  /// No description provided for @subscriptionCompareFeatureColumn.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get subscriptionCompareFeatureColumn;

  /// No description provided for @subscriptionCompareCustomers.
  ///
  /// In en, this message translates to:
  /// **'Active clients'**
  String get subscriptionCompareCustomers;

  /// No description provided for @subscriptionCompareCustomersFree.
  ///
  /// In en, this message translates to:
  /// **'Up to {max}'**
  String subscriptionCompareCustomersFree(int max);

  /// No description provided for @subscriptionCompareProgressExport.
  ///
  /// In en, this message translates to:
  /// **'Progress CSV export'**
  String get subscriptionCompareProgressExport;

  /// No description provided for @subscriptionCompareWorkoutExport.
  ///
  /// In en, this message translates to:
  /// **'Workout PDF/Excel export'**
  String get subscriptionCompareWorkoutExport;

  /// No description provided for @subscriptionCompareNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get subscriptionCompareNotIncluded;

  /// No description provided for @subscriptionStatusPromoActive.
  ///
  /// In en, this message translates to:
  /// **'Pro (promo)'**
  String get subscriptionStatusPromoActive;

  /// No description provided for @subscriptionStatusPromoActiveDetail.
  ///
  /// In en, this message translates to:
  /// **'Pro access activated with a Pro promo code.'**
  String get subscriptionStatusPromoActiveDetail;

  /// No description provided for @subscriptionBillingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get subscriptionBillingDetailsTitle;

  /// No description provided for @subscriptionBillingCycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing cycle'**
  String get subscriptionBillingCycleLabel;

  /// No description provided for @subscriptionBillingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get subscriptionBillingAmountLabel;

  /// No description provided for @subscriptionBillingRenewalLabel.
  ///
  /// In en, this message translates to:
  /// **'Renewal'**
  String get subscriptionBillingRenewalLabel;

  /// No description provided for @subscriptionBillingIntervalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionBillingIntervalMonthly;

  /// No description provided for @subscriptionBillingIntervalYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionBillingIntervalYearly;

  /// No description provided for @subscriptionBillingPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'{amount}/month'**
  String subscriptionBillingPriceMonthly(String amount);

  /// No description provided for @subscriptionBillingPriceYearly.
  ///
  /// In en, this message translates to:
  /// **'{amount}/year'**
  String subscriptionBillingPriceYearly(String amount);

  /// No description provided for @subscriptionProActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get subscriptionProActionsTitle;

  /// No description provided for @subscriptionProActionPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Update payment method'**
  String get subscriptionProActionPaymentMethod;

  /// No description provided for @subscriptionProActionSwitchYearly.
  ///
  /// In en, this message translates to:
  /// **'Switch to yearly plan'**
  String get subscriptionProActionSwitchYearly;

  /// No description provided for @subscriptionProActionSwitchYearlyHint.
  ///
  /// In en, this message translates to:
  /// **'Save about €45/year compared to monthly.'**
  String get subscriptionProActionSwitchYearlyHint;

  /// No description provided for @subscriptionProActionSwitchMonthly.
  ///
  /// In en, this message translates to:
  /// **'Switch to monthly plan'**
  String get subscriptionProActionSwitchMonthly;

  /// No description provided for @subscriptionProActionInvoices.
  ///
  /// In en, this message translates to:
  /// **'View invoices'**
  String get subscriptionProActionInvoices;

  /// No description provided for @subscriptionProActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get subscriptionProActionCancel;

  /// No description provided for @billingAlertPastDue.
  ///
  /// In en, this message translates to:
  /// **'Your Pro subscription payment failed.'**
  String get billingAlertPastDue;

  /// No description provided for @billingAlertUpdatePayment.
  ///
  /// In en, this message translates to:
  /// **'Update payment'**
  String get billingAlertUpdatePayment;

  /// No description provided for @billingAlertGraceEnding.
  ///
  /// In en, this message translates to:
  /// **'Pro access ends in {days} days.'**
  String billingAlertGraceEnding(int days);

  /// No description provided for @billingAlertManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get billingAlertManageSubscription;

  /// No description provided for @paywallMessageCustomersAtLimit.
  ///
  /// In en, this message translates to:
  /// **'You reached the limit of {current}/{max} active clients. Upgrade to Pro to add more.'**
  String paywallMessageCustomersAtLimit(int current, int max);

  /// No description provided for @paywallMessageCustomersNearLimit.
  ///
  /// In en, this message translates to:
  /// **'You have {current}/{max} active clients. Pro gives you unlimited clients.'**
  String paywallMessageCustomersNearLimit(int current, int max);

  /// No description provided for @customerListUpgradeAtLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit reached ({current}/{max} clients). Upgrade to Pro to add more.'**
  String customerListUpgradeAtLimit(int current, int max);

  /// No description provided for @customerListUpgradeNearLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'re close to the Free limit ({current}/{max} clients). Upgrade to Pro.'**
  String customerListUpgradeNearLimit(int current, int max);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro feature'**
  String get paywallTitle;

  /// No description provided for @paywallMessageCustomers.
  ///
  /// In en, this message translates to:
  /// **'The Free plan includes up to {maxCustomers} active clients. Upgrade to Pro for unlimited clients.'**
  String paywallMessageCustomers(int maxCustomers);

  /// No description provided for @paywallMessageExport.
  ///
  /// In en, this message translates to:
  /// **'Client progress CSV export is included in PowerCoach Pro.'**
  String get paywallMessageExport;

  /// No description provided for @paywallMessageWorkoutExport.
  ///
  /// In en, this message translates to:
  /// **'Workout PDF and Excel export is included in PowerCoach Pro.'**
  String get paywallMessageWorkoutExport;

  /// No description provided for @paywallUpgradeCta.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get paywallUpgradeCta;

  /// No description provided for @paywallNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get paywallNotNow;

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Local reminders for sessions and clients'**
  String get settingsNotificationsDescription;

  /// No description provided for @settingsNotificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Enable them in system settings to turn this on.'**
  String get settingsNotificationPermissionDenied;

  /// No description provided for @reminderWebNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Reminders are not supported in the web version of the app.'**
  String get reminderWebNotSupported;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsLanguageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get settingsLanguageItalian;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSaved.
  ///
  /// In en, this message translates to:
  /// **'Language updated.'**
  String get settingsLanguageSaved;

  /// No description provided for @settingsBackupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline backup'**
  String get settingsBackupSectionTitle;

  /// No description provided for @settingsBackupSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export or replace all local data for this account as a JSON file — your data stays yours. Use this to move data between devices.'**
  String get settingsBackupSectionSubtitle;

  /// No description provided for @settingsBackupExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsBackupExport;

  /// No description provided for @settingsBackupImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsBackupImport;

  /// No description provided for @settingsBackupImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace local data?'**
  String get settingsBackupImportConfirmTitle;

  /// No description provided for @settingsBackupImportConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This deletes all offline data for your account on this device and replaces it with the backup file. Other devices are not updated automatically. The file must belong to this signed-in account.'**
  String get settingsBackupImportConfirmMessage;

  /// No description provided for @settingsBackupImportConfirmReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace local data'**
  String get settingsBackupImportConfirmReplace;

  /// No description provided for @settingsBackupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to share.'**
  String get settingsBackupExportSuccess;

  /// No description provided for @settingsBackupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local data restored from backup.'**
  String get settingsBackupImportSuccess;

  /// No description provided for @settingsBackupErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get settingsBackupErrorGeneric;

  /// No description provided for @settingsBackupErrorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to export or import a backup.'**
  String get settingsBackupErrorNotSignedIn;

  /// No description provided for @settingsBackupErrorWrongAccount.
  ///
  /// In en, this message translates to:
  /// **'This backup belongs to another account.'**
  String get settingsBackupErrorWrongAccount;

  /// No description provided for @settingsBackupErrorUnsupportedSchema.
  ///
  /// In en, this message translates to:
  /// **'This backup format is not supported by this app version.'**
  String get settingsBackupErrorUnsupportedSchema;

  /// No description provided for @settingsBackupSectionSubtitleWeb.
  ///
  /// In en, this message translates to:
  /// **'Your coach data is stored in this browser — it stays yours. Export a JSON backup regularly so you can restore it or move to another device.'**
  String get settingsBackupSectionSubtitleWeb;

  /// No description provided for @settingsBackupErrorInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file.'**
  String get settingsBackupErrorInvalidFile;

  /// No description provided for @settingsCloudBackupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup (optional)'**
  String get settingsCloudBackupSectionTitle;

  /// No description provided for @settingsCloudBackupSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save or restore a manual snapshot on Supabase Storage, visible only to your account. This is not an automatic sync.'**
  String get settingsCloudBackupSectionSubtitle;

  /// No description provided for @settingsCloudBackupUpload.
  ///
  /// In en, this message translates to:
  /// **'Save to cloud'**
  String get settingsCloudBackupUpload;

  /// No description provided for @settingsCloudBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from cloud'**
  String get settingsCloudBackupRestore;

  /// No description provided for @settingsCloudBackupUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded to the cloud.'**
  String get settingsCloudBackupUploadSuccess;

  /// No description provided for @settingsCloudBackupEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cloud backups found for this account.'**
  String get settingsCloudBackupEmpty;

  /// No description provided for @settingsCloudBackupErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete the cloud operation. Try again.'**
  String get settingsCloudBackupErrorGeneric;

  /// No description provided for @settingsCloudBackupListTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup to restore'**
  String get settingsCloudBackupListTitle;

  /// No description provided for @settingsCloudBackupListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cloud backups available.'**
  String get settingsCloudBackupListEmpty;

  /// No description provided for @settingsCloudBackupDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete this cloud backup'**
  String get settingsCloudBackupDeleteTooltip;

  /// No description provided for @settingsCloudBackupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup deleted.'**
  String get settingsCloudBackupDeleted;

  /// No description provided for @settingsAutoCloudBackupToggle.
  ///
  /// In en, this message translates to:
  /// **'Automatic cloud backup'**
  String get settingsAutoCloudBackupToggle;

  /// No description provided for @settingsAutoCloudBackupHint.
  ///
  /// In en, this message translates to:
  /// **'After edits, upload a snapshot to Supabase Storage (debounced).'**
  String get settingsAutoCloudBackupHint;

  /// No description provided for @settingsStoragePersistHint.
  ///
  /// In en, this message translates to:
  /// **'The browser may clear local data. Enable automatic cloud backup and export regularly.'**
  String get settingsStoragePersistHint;

  /// No description provided for @settingsStoragePersistHintDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get settingsStoragePersistHintDismiss;

  /// No description provided for @settingsStoragePersistHintDismissSemantic.
  ///
  /// In en, this message translates to:
  /// **'Dismiss storage persist hint'**
  String get settingsStoragePersistHintDismissSemantic;

  /// No description provided for @settingsBackupLastSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {timestamp}'**
  String settingsBackupLastSuccess(String timestamp);

  /// No description provided for @settingsBackupLastCloud.
  ///
  /// In en, this message translates to:
  /// **'Last cloud backup: {timestamp}'**
  String settingsBackupLastCloud(String timestamp);

  /// No description provided for @settingsBackupLastError.
  ///
  /// In en, this message translates to:
  /// **'Last cloud error: {message}'**
  String settingsBackupLastError(String message);

  /// No description provided for @settingsCloudLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last cloud sync: {timestamp}'**
  String settingsCloudLastSync(String timestamp);

  /// No description provided for @settingsCloudSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync from cloud'**
  String get settingsCloudSyncNow;

  /// No description provided for @settingsCloudSyncNowHint.
  ///
  /// In en, this message translates to:
  /// **'Pull newer cloud data onto this device.'**
  String get settingsCloudSyncNowHint;

  /// No description provided for @settingsCloudSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud data merged into this device.'**
  String get settingsCloudSyncSuccess;

  /// No description provided for @cloudRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore latest cloud backup?'**
  String get cloudRecoveryTitle;

  /// No description provided for @cloudRecoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no clients or workout plans on this device, but cloud snapshots exist. Restore the latest backup?'**
  String get cloudRecoveryMessage;

  /// No description provided for @cloudRecoveryRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get cloudRecoveryRestore;

  /// No description provided for @cloudRecoveryNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get cloudRecoveryNotNow;

  /// No description provided for @coachEntitiesMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your coach data to the cloud'**
  String get coachEntitiesMigrationTitle;

  /// No description provided for @coachEntitiesMigrationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your clients and workout plans are still only on this device. We will upload them to your account so they stay available across devices.'**
  String get coachEntitiesMigrationMessage;

  /// No description provided for @coachEntitiesMigrationPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing upload…'**
  String get coachEntitiesMigrationPreparing;

  /// No description provided for @coachEntitiesMigrationProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {done} of {total}…'**
  String coachEntitiesMigrationProgress(int done, int total);

  /// No description provided for @coachEntitiesMigrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Coach data uploaded to the cloud.'**
  String get coachEntitiesMigrationSuccess;

  /// No description provided for @coachEntitiesMigrationFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not upload your coach data.'**
  String get coachEntitiesMigrationFailure;

  /// No description provided for @coachEntitiesMigrationFailureDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String coachEntitiesMigrationFailureDetail(String error);

  /// No description provided for @coachEntitiesMigrationRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get coachEntitiesMigrationRetry;

  /// No description provided for @settingsLegalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & privacy'**
  String get settingsLegalSectionTitle;

  /// No description provided for @settingsLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsLegalPrivacy;

  /// No description provided for @settingsLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsLegalTerms;

  /// No description provided for @settingsLegalAccountDeletion.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get settingsLegalAccountDeletion;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out and remove local data?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Signing out deletes all clients, workout plans, and settings stored on this device for your account. Export a backup first if you want to keep a copy.'**
  String get signOutConfirmMessage;

  /// No description provided for @signOutConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get signOutConfirmCancel;

  /// No description provided for @signOutConfirmExportFirst.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get signOutConfirmExportFirst;

  /// No description provided for @signOutConfirmUploadCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload to cloud before signing out'**
  String get signOutConfirmUploadCloud;

  /// No description provided for @signOutConfirmProceed.
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get signOutConfirmProceed;

  /// No description provided for @backupOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your coach data'**
  String get backupOnboardingTitle;

  /// No description provided for @backupOnboardingMessageAfterBrand.
  ///
  /// In en, this message translates to:
  /// **' stores clients and workout plans directly on this device ('**
  String get backupOnboardingMessageAfterBrand;

  /// No description provided for @backupOnboardingMessageAfterOffline.
  ///
  /// In en, this message translates to:
  /// **'). If you clear browser history or switch machines, that information is removed unless you have a backup.'**
  String get backupOnboardingMessageAfterOffline;

  /// No description provided for @backupOnboardingWebHint.
  ///
  /// In en, this message translates to:
  /// **'On the web, data stays in this browser’s storage on this device.'**
  String get backupOnboardingWebHint;

  /// No description provided for @backupOnboardingCalloutLead.
  ///
  /// In en, this message translates to:
  /// **'Maximum flexibility between studio and gym floor:'**
  String get backupOnboardingCalloutLead;

  /// No description provided for @backupOnboardingCalloutBody.
  ///
  /// In en, this message translates to:
  /// **' Plan on desktop at home or in the office, then bring the same archive to the gym on your phone — a simple JSON backup lets you move your data freely, '**
  String get backupOnboardingCalloutBody;

  /// No description provided for @backupOnboardingCalloutEmphasis.
  ///
  /// In en, this message translates to:
  /// **'without sharing data on unauthorized external cloud servers'**
  String get backupOnboardingCalloutEmphasis;

  /// No description provided for @backupOnboardingRecommendBefore.
  ///
  /// In en, this message translates to:
  /// **'We recommend exporting a JSON copy from '**
  String get backupOnboardingRecommendBefore;

  /// No description provided for @backupOnboardingRecommendSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get backupOnboardingRecommendSettings;

  /// No description provided for @backupOnboardingRecommendAfter.
  ///
  /// In en, this message translates to:
  /// **' after every programming block.'**
  String get backupOnboardingRecommendAfter;

  /// No description provided for @backupOnboardingOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get backupOnboardingOpenSettings;

  /// No description provided for @backupOnboardingExportNow.
  ///
  /// In en, this message translates to:
  /// **'Export backup now'**
  String get backupOnboardingExportNow;

  /// No description provided for @backupOnboardingGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get backupOnboardingGotIt;

  /// No description provided for @backupOnboardingCloseSemantic.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get backupOnboardingCloseSemantic;

  /// No description provided for @customerCreationLocalDataHint.
  ///
  /// In en, this message translates to:
  /// **'Client data is saved locally on this device. No welcome email is sent.'**
  String get customerCreationLocalDataHint;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @exerciseLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get exerciseLibraryTitle;

  /// No description provided for @exerciseLibraryBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get exerciseLibraryBack;

  /// No description provided for @exerciseLibraryImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get exerciseLibraryImport;

  /// No description provided for @exerciseLibraryExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exerciseLibraryExport;

  /// No description provided for @exerciseLibraryImportSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Import exercises'**
  String get exerciseLibraryImportSourceTitle;

  /// No description provided for @exerciseLibraryImportSourceDefault.
  ///
  /// In en, this message translates to:
  /// **'Import default catalog'**
  String get exerciseLibraryImportSourceDefault;

  /// No description provided for @exerciseLibraryImportSourceDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load 266 common exercises with variants and hierarchy (incl. powerlifting).'**
  String get exerciseLibraryImportSourceDefaultSubtitle;

  /// No description provided for @exerciseLibraryImportSourceCustom.
  ///
  /// In en, this message translates to:
  /// **'Import custom JSON'**
  String get exerciseLibraryImportSourceCustom;

  /// No description provided for @exerciseLibraryImportSourceCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load exercises from your own JSON file.'**
  String get exerciseLibraryImportSourceCustomSubtitle;

  /// No description provided for @exerciseLibraryAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get exerciseLibraryAddExercise;

  /// No description provided for @exerciseLibraryEditExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get exerciseLibraryEditExercise;

  /// No description provided for @exerciseLibraryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get exerciseLibraryEdit;

  /// No description provided for @exerciseLibraryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get exerciseLibraryDelete;

  /// No description provided for @exerciseLibraryPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get exerciseLibraryPin;

  /// No description provided for @exerciseLibraryUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get exerciseLibraryUnpin;

  /// No description provided for @exerciseLibraryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get exerciseLibraryCancel;

  /// No description provided for @exerciseLibrarySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get exerciseLibrarySave;

  /// No description provided for @exerciseLibraryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get exerciseLibraryRetry;

  /// No description provided for @exerciseLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom exercises yet.'**
  String get exerciseLibraryEmpty;

  /// No description provided for @exerciseLibraryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add exercises and variants (e.g. Squat → Squat low bar) to use them in plans.'**
  String get exerciseLibraryEmptyHint;

  /// No description provided for @exerciseLibraryTabExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exerciseLibraryTabExercises;

  /// No description provided for @exerciseLibraryTabMobilityExercises.
  ///
  /// In en, this message translates to:
  /// **'Mobility exercises'**
  String get exerciseLibraryTabMobilityExercises;

  /// No description provided for @exerciseLibraryEmptyMobility.
  ///
  /// In en, this message translates to:
  /// **'No mobility exercises yet.'**
  String get exerciseLibraryEmptyMobility;

  /// No description provided for @exerciseLibraryEmptyMobilityHint.
  ///
  /// In en, this message translates to:
  /// **'Add mobility exercises to use them in mobility routines.'**
  String get exerciseLibraryEmptyMobilityHint;

  /// No description provided for @exerciseLibraryExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export. Add exercises first.'**
  String get exerciseLibraryExportEmpty;

  /// No description provided for @exerciseLibraryClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear library'**
  String get exerciseLibraryClearAll;

  /// No description provided for @exerciseLibraryClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the entire library?'**
  String get exerciseLibraryClearAllTitle;

  /// No description provided for @exerciseLibraryClearAllMessage.
  ///
  /// In en, this message translates to:
  /// **'All exercises and mobility exercises will be removed. Workout plans are not deleted. This cannot be undone.'**
  String get exerciseLibraryClearAllMessage;

  /// No description provided for @exerciseLibraryClearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get exerciseLibraryClearAllConfirm;

  /// No description provided for @exerciseLibraryClearAllEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to clear.'**
  String get exerciseLibraryClearAllEmpty;

  /// No description provided for @exerciseLibraryClearAllSuccessCount.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} exercises.'**
  String exerciseLibraryClearAllSuccessCount(int count);

  /// No description provided for @exerciseLibraryImportInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file. Use a JSON array of exercises.'**
  String get exerciseLibraryImportInvalidFormat;

  /// No description provided for @exerciseLibraryImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import completed successfully.'**
  String get exerciseLibraryImportSuccess;

  /// No description provided for @exerciseLibraryImportSuccessCount.
  ///
  /// In en, this message translates to:
  /// **'Import completed: {count} items.'**
  String exerciseLibraryImportSuccessCount(int count);

  /// No description provided for @exerciseLibraryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get exerciseLibraryDeleteTitle;

  /// No description provided for @exerciseLibraryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String exerciseLibraryDeleteConfirm(Object name);

  /// No description provided for @exerciseLibraryDeleteHasChildren.
  ///
  /// In en, this message translates to:
  /// **'Remove child exercises (variants) first, then delete this one.'**
  String get exerciseLibraryDeleteHasChildren;

  /// No description provided for @exerciseLibraryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseLibraryNameHint;

  /// No description provided for @exerciseLibraryDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get exerciseLibraryDescriptionHint;

  /// No description provided for @exerciseLibraryMobilityToggle.
  ///
  /// In en, this message translates to:
  /// **'Mobility exercise'**
  String get exerciseLibraryMobilityToggle;

  /// No description provided for @exerciseLibraryParentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent exercise (variant of)'**
  String get exerciseLibraryParentLabel;

  /// No description provided for @exerciseLibraryParentNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get exerciseLibraryParentNone;

  /// No description provided for @exerciseLibraryAddVariant.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get exerciseLibraryAddVariant;

  /// No description provided for @exerciseLibrarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get exerciseLibrarySearchHint;

  /// No description provided for @exerciseLibrarySearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises match your search.'**
  String get exerciseLibrarySearchEmpty;

  /// No description provided for @exerciseLibraryVariantCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 variants} =1{1 variant} other{{count} variants}}'**
  String exerciseLibraryVariantCount(int count);

  /// No description provided for @exerciseLibrarySortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Sort: Alphabetical (A-Z)'**
  String get exerciseLibrarySortAlphabetical;

  /// No description provided for @exerciseLibrarySortByVariantCount.
  ///
  /// In en, this message translates to:
  /// **'Variant count'**
  String get exerciseLibrarySortByVariantCount;

  /// No description provided for @exerciseLibraryNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get exerciseLibraryNewFolder;

  /// No description provided for @exerciseLibraryExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exerciseLibraryExerciseCount(int count);

  /// No description provided for @exerciseLibraryFolderCount.
  ///
  /// In en, this message translates to:
  /// **'{count} folders'**
  String exerciseLibraryFolderCount(int count);

  /// No description provided for @placeholderBackToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get placeholderBackToDashboard;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Let\'s grow your studio! Start by adding your first client to track progress, set up mesocycles, and manage workouts.'**
  String get customersEmptyMessage;

  /// No description provided for @customersAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get customersAddCustomer;

  /// No description provided for @customersAddFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add your first client'**
  String get customersAddFirstClient;

  /// No description provided for @customersImportContacts.
  ///
  /// In en, this message translates to:
  /// **'Import from contacts'**
  String get customersImportContacts;

  /// No description provided for @customersImportContactsDenied.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is required to import.'**
  String get customersImportContactsDenied;

  /// No description provided for @customersNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get customersNewCustomer;

  /// No description provided for @customersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get customersSearchHint;

  /// No description provided for @customersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get customersFilterAll;

  /// No description provided for @customersFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get customersFilterActive;

  /// No description provided for @customersFilterPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get customersFilterPaused;

  /// No description provided for @customersFilterUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get customersFilterUnassigned;

  /// No description provided for @customersFilterCount.
  ///
  /// In en, this message translates to:
  /// **'({count})'**
  String customersFilterCount(int count);

  /// No description provided for @customersEmptyStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Profile & Target'**
  String get customersEmptyStep1Title;

  /// No description provided for @customersEmptyStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Enter anthropometrics, maxes, and primary goals (Hypertrophy, Strength, Cut).'**
  String get customersEmptyStep1Body;

  /// No description provided for @customersEmptyStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Assign a Plan'**
  String get customersEmptyStep2Title;

  /// No description provided for @customersEmptyStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Link a custom mesocycle or pick a template from the Library.'**
  String get customersEmptyStep2Body;

  /// No description provided for @customersEmptyStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Track Loads & RPE'**
  String get customersEmptyStep3Title;

  /// No description provided for @customersEmptyStep3Body.
  ///
  /// In en, this message translates to:
  /// **'View training logs, tonnage, and progressions in real time.'**
  String get customersEmptyStep3Body;

  /// No description provided for @customersOfflineFirstFooter.
  ///
  /// In en, this message translates to:
  /// **'Data syncs to the cloud when you\'re online · local cache on this device'**
  String get customersOfflineFirstFooter;

  /// No description provided for @customersSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No clients match these filters.'**
  String get customersSearchEmpty;

  /// No description provided for @customersMetricTotalAthletes.
  ///
  /// In en, this message translates to:
  /// **'Total athletes'**
  String get customersMetricTotalAthletes;

  /// No description provided for @customersMetricActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String customersMetricActiveCount(int count);

  /// No description provided for @customersMetricPlansInProgress.
  ///
  /// In en, this message translates to:
  /// **'Plans in progress'**
  String get customersMetricPlansInProgress;

  /// No description provided for @customersMetricPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'with a plan'**
  String get customersMetricPlansSubtitle;

  /// No description provided for @customersMetricPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get customersMetricPaused;

  /// No description provided for @customersMetricPausedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get customersMetricPausedSubtitle;

  /// No description provided for @customersMetricNeedsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Needs update'**
  String get customersMetricNeedsUpdate;

  /// No description provided for @customersMetricNeedsUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'due soon'**
  String get customersMetricNeedsUpdateSubtitle;

  /// No description provided for @customersSortPrefix.
  ///
  /// In en, this message translates to:
  /// **'Sort:'**
  String get customersSortPrefix;

  /// No description provided for @customersSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get customersSortRecent;

  /// No description provided for @customersSortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get customersSortNameAsc;

  /// No description provided for @customersShownOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} athletes'**
  String customersShownOfTotal(int shown, int total);

  /// No description provided for @customersRowAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String customersRowAgeYears(int age);

  /// No description provided for @customersRowGoalEmpty.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get customersRowGoalEmpty;

  /// No description provided for @customersRowNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No plan assigned'**
  String get customersRowNoPlan;

  /// No description provided for @customersRowPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last plan update: {date}'**
  String customersRowPlanUpdated(String date);

  /// No description provided for @customersRowStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get customersRowStatusActive;

  /// No description provided for @customersRowStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get customersRowStatusPaused;

  /// No description provided for @customersRowStatusUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get customersRowStatusUnassigned;

  /// No description provided for @customersRowActionOpenPlan.
  ///
  /// In en, this message translates to:
  /// **'Open plan'**
  String get customersRowActionOpenPlan;

  /// No description provided for @customersRowActionAssign.
  ///
  /// In en, this message translates to:
  /// **'+ Assign'**
  String get customersRowActionAssign;

  /// No description provided for @customersRowActionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get customersRowActionOpen;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get customerName;

  /// No description provided for @customerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get customerNameRequired;

  /// No description provided for @customerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex Johnson'**
  String get customerNameHint;

  /// No description provided for @customerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get customerEmail;

  /// No description provided for @customerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'alex.johnson@example.com'**
  String get customerEmailHint;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone / WhatsApp'**
  String get customerPhone;

  /// No description provided for @customerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'334 123 4567'**
  String get customerPhoneHint;

  /// No description provided for @customerPhoneCountryPrefix.
  ///
  /// In en, this message translates to:
  /// **'+39'**
  String get customerPhoneCountryPrefix;

  /// No description provided for @customerDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get customerDateOfBirth;

  /// No description provided for @customerEstimatedAge.
  ///
  /// In en, this message translates to:
  /// **'Estimated age'**
  String get customerEstimatedAge;

  /// No description provided for @customerEstimatedAgeUnit.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get customerEstimatedAgeUnit;

  /// No description provided for @customerHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get customerHeight;

  /// No description provided for @customerHeightHint.
  ///
  /// In en, this message translates to:
  /// **'180'**
  String get customerHeightHint;

  /// No description provided for @customerHeightUnit.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get customerHeightUnit;

  /// No description provided for @customerWeight.
  ///
  /// In en, this message translates to:
  /// **'Starting weight'**
  String get customerWeight;

  /// No description provided for @customerWeightHint.
  ///
  /// In en, this message translates to:
  /// **'78.5'**
  String get customerWeightHint;

  /// No description provided for @customerWeightUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get customerWeightUnit;

  /// No description provided for @customerNotes.
  ///
  /// In en, this message translates to:
  /// **'Coach notes, injuries, or limitations'**
  String get customerNotes;

  /// No description provided for @customerNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get customerNotesOptional;

  /// No description provided for @customerNotesHintCreation.
  ///
  /// In en, this message translates to:
  /// **'e.g. Prior right shoulder cuff discomfort; prefers training 4 days/week…'**
  String get customerNotesHintCreation;

  /// No description provided for @customerGoals.
  ///
  /// In en, this message translates to:
  /// **'Primary goal'**
  String get customerGoals;

  /// No description provided for @customerGoalHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get customerGoalHypertrophy;

  /// No description provided for @customerGoalHypertrophySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get customerGoalHypertrophySubtitle;

  /// No description provided for @customerGoalStrength.
  ///
  /// In en, this message translates to:
  /// **'Max Strength'**
  String get customerGoalStrength;

  /// No description provided for @customerGoalStrengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get customerGoalStrengthSubtitle;

  /// No description provided for @customerGoalRecomp.
  ///
  /// In en, this message translates to:
  /// **'Recomposition'**
  String get customerGoalRecomp;

  /// No description provided for @customerGoalRecompSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fat loss & tone'**
  String get customerGoalRecompSubtitle;

  /// No description provided for @customerGoalAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic prep'**
  String get customerGoalAthletic;

  /// No description provided for @customerGoalAthleticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sport-specific'**
  String get customerGoalAthleticSubtitle;

  /// No description provided for @customerExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience level'**
  String get customerExperienceLabel;

  /// No description provided for @customerExperienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner (0–1 year)'**
  String get customerExperienceBeginner;

  /// No description provided for @customerExperienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate (1–3 years)'**
  String get customerExperienceIntermediate;

  /// No description provided for @customerExperienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced (3+ years of consistent training)'**
  String get customerExperienceAdvanced;

  /// No description provided for @customerExperienceElite.
  ///
  /// In en, this message translates to:
  /// **'Competitive / elite athlete'**
  String get customerExperienceElite;

  /// No description provided for @customerExperienceNotesPrefix.
  ///
  /// In en, this message translates to:
  /// **'Experience: {level}'**
  String customerExperienceNotesPrefix(String level);

  /// No description provided for @customerCreationHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new journey'**
  String get customerCreationHeroTitle;

  /// No description provided for @customerCreationHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your athlete’s profile and goals to start planning workouts and tracking progress.'**
  String get customerCreationHeroSubtitle;

  /// No description provided for @customerCreationBadge.
  ///
  /// In en, this message translates to:
  /// **'Athlete profile'**
  String get customerCreationBadge;

  /// No description provided for @customerCreationHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio · Creation & onboarding'**
  String get customerCreationHeaderSubtitle;

  /// No description provided for @customerCreationStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get customerCreationStepProgress;

  /// No description provided for @customerCreationSectionAnagrafica.
  ///
  /// In en, this message translates to:
  /// **'1. Personal details'**
  String get customerCreationSectionAnagrafica;

  /// No description provided for @customerCreationSectionPhysical.
  ///
  /// In en, this message translates to:
  /// **'2. Physical & biometric data'**
  String get customerCreationSectionPhysical;

  /// No description provided for @customerCreationSectionGoals.
  ///
  /// In en, this message translates to:
  /// **'3. Goals & training profile'**
  String get customerCreationSectionGoals;

  /// No description provided for @customerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get customerSave;

  /// No description provided for @customerSaveAndCreatePlan.
  ///
  /// In en, this message translates to:
  /// **'Save and create plan'**
  String get customerSaveAndCreatePlan;

  /// No description provided for @customerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get customerCancel;

  /// No description provided for @customerEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get customerEdit;

  /// No description provided for @customerDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get customerDelete;

  /// No description provided for @customerDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete customer?'**
  String get customerDeleteConfirmTitle;

  /// No description provided for @customerDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get customerDeleteConfirmMessage;

  /// No description provided for @customersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load customers.'**
  String get customersLoadError;

  /// No description provided for @customerSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save customer.'**
  String get customerSaveError;

  /// No description provided for @cloudSaveRequiresLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your data to the cloud.'**
  String get cloudSaveRequiresLogin;

  /// No description provided for @cloudSaveRequiresNetwork.
  ///
  /// In en, this message translates to:
  /// **'You need an internet connection to save.'**
  String get cloudSaveRequiresNetwork;

  /// No description provided for @cloudSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save to the cloud. Try again.'**
  String get cloudSaveFailed;

  /// No description provided for @cloudSaveSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Saved to the cloud.'**
  String get cloudSaveSucceeded;

  /// No description provided for @cloudSaveRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get cloudSaveRetryAction;

  /// No description provided for @customerDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete customer.'**
  String get customerDeleteError;

  /// No description provided for @customersSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get customersSessionExpired;

  /// No description provided for @customersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get customersRetry;

  /// No description provided for @customerDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted.'**
  String get customerDeletedMessage;

  /// No description provided for @workoutExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get workoutExport;

  /// No description provided for @workoutExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get workoutExportPdf;

  /// No description provided for @workoutExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get workoutExportExcel;

  /// No description provided for @workoutImportJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get workoutImportJson;

  /// No description provided for @workoutImportJsonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout imported from JSON file.'**
  String get workoutImportJsonSuccess;

  /// No description provided for @workoutImportJsonError.
  ///
  /// In en, this message translates to:
  /// **'Invalid or unsupported JSON file.'**
  String get workoutImportJsonError;

  /// No description provided for @workoutExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Download started.'**
  String get workoutExportSuccess;

  /// No description provided for @workoutExportError.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Try again.'**
  String get workoutExportError;

  /// No description provided for @workoutExportPdfSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get workoutExportPdfSheetTitle;

  /// No description provided for @workoutPdfLayoutCanonical.
  ///
  /// In en, this message translates to:
  /// **'Full (by week)'**
  String get workoutPdfLayoutCanonical;

  /// No description provided for @workoutPdfLayoutDense.
  ///
  /// In en, this message translates to:
  /// **'Dense (recommended)'**
  String get workoutPdfLayoutDense;

  /// No description provided for @workoutPdfLayoutDenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Compact day layout with week columns, fewer pages, and single-line prescriptions.'**
  String get workoutPdfLayoutDenseDescription;

  /// No description provided for @workoutExportPdfGenerateAndDownload.
  ///
  /// In en, this message translates to:
  /// **'Generate and download'**
  String get workoutExportPdfGenerateAndDownload;

  /// No description provided for @workoutExportPdfGenerateAndPreview.
  ///
  /// In en, this message translates to:
  /// **'Generate preview'**
  String get workoutExportPdfGenerateAndPreview;

  /// No description provided for @workoutPdfIncludeMobility.
  ///
  /// In en, this message translates to:
  /// **'Include mobility / warm-up'**
  String get workoutPdfIncludeMobility;

  /// No description provided for @workoutPdfSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a preset. You can still toggle mobility and customize the layout.'**
  String get workoutPdfSheetSubtitle;

  /// No description provided for @workoutPdfSheetSubtitlePreviewFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a preset. A PDF preview opens first, then you can share or save.'**
  String get workoutPdfSheetSubtitlePreviewFirst;

  /// No description provided for @workoutPdfPresetGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get workoutPdfPresetGym;

  /// No description provided for @workoutPdfPresetGymDescription.
  ///
  /// In en, this message translates to:
  /// **'Dense layout for the gym floor. All weeks. Mobility off by default.'**
  String get workoutPdfPresetGymDescription;

  /// No description provided for @workoutPdfPresetFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get workoutPdfPresetFull;

  /// No description provided for @workoutPdfPresetFullDescription.
  ///
  /// In en, this message translates to:
  /// **'Full layout by week, including mobility when available.'**
  String get workoutPdfPresetFullDescription;

  /// No description provided for @workoutPdfPresetWeek1.
  ///
  /// In en, this message translates to:
  /// **'Week 1 only'**
  String get workoutPdfPresetWeek1;

  /// No description provided for @workoutPdfPresetWeek1Description.
  ///
  /// In en, this message translates to:
  /// **'Dense layout for the first week only.'**
  String get workoutPdfPresetWeek1Description;

  /// No description provided for @workoutPdfPersonalizeLayout.
  ///
  /// In en, this message translates to:
  /// **'Customize layout'**
  String get workoutPdfPersonalizeLayout;

  /// No description provided for @workoutPdfPersonalizeLayoutHide.
  ///
  /// In en, this message translates to:
  /// **'Hide layout options'**
  String get workoutPdfPersonalizeLayoutHide;

  /// No description provided for @pdfBrandName.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio'**
  String get pdfBrandName;

  /// No description provided for @pdfCoachPrefix.
  ///
  /// In en, this message translates to:
  /// **'Coach:'**
  String get pdfCoachPrefix;

  /// No description provided for @pdfColExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get pdfColExercise;

  /// No description provided for @pdfColSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get pdfColSets;

  /// No description provided for @pdfColReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get pdfColReps;

  /// No description provided for @pdfColLoadRpe.
  ///
  /// In en, this message translates to:
  /// **'Load/RPE'**
  String get pdfColLoadRpe;

  /// No description provided for @pdfColNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pdfColNotes;

  /// No description provided for @pdfMobilitySection.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get pdfMobilitySection;

  /// No description provided for @pdfSuperset.
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get pdfSuperset;

  /// No description provided for @pdfDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String pdfDayNumber(int day);

  /// No description provided for @pdfEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get pdfEmptyValue;

  /// No description provided for @pdfFooterDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This document is intended for the designated client only. Please consult a physician before beginning any new exercise program.'**
  String get pdfFooterDisclaimer;

  /// No description provided for @pdfPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pdfPageOf(int current, int total);

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String pdfGeneratedOn(String date);

  /// No description provided for @pdfExportGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF…'**
  String get pdfExportGenerating;

  /// No description provided for @pdfMeasurementRecordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String pdfMeasurementRecordCount(int count);

  /// No description provided for @pdfDenseWeekShort.
  ///
  /// In en, this message translates to:
  /// **'W{n}'**
  String pdfDenseWeekShort(int n);

  /// No description provided for @pdfDenseAllWeeks.
  ///
  /// In en, this message translates to:
  /// **'all'**
  String get pdfDenseAllWeeks;

  /// No description provided for @pdfDenseDitto.
  ///
  /// In en, this message translates to:
  /// **'\"'**
  String get pdfDenseDitto;

  /// No description provided for @pdfDenseWeekLegendEntry.
  ///
  /// In en, this message translates to:
  /// **'W{n} = {name}'**
  String pdfDenseWeekLegendEntry(int n, String name);

  /// No description provided for @pdfDenseWeeksSpan.
  ///
  /// In en, this message translates to:
  /// **'W{first}-W{last}'**
  String pdfDenseWeeksSpan(int first, int last);

  /// No description provided for @pdfDenseLegend.
  ///
  /// In en, this message translates to:
  /// **'W1-W4 = all weeks | \" = same prescription'**
  String get pdfDenseLegend;

  /// No description provided for @pdfClientPlanFor.
  ///
  /// In en, this message translates to:
  /// **'Plan for: {name}'**
  String pdfClientPlanFor(String name);

  /// No description provided for @pdfPlanPeriod.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String pdfPlanPeriod(String start, String end);

  /// No description provided for @pdfPlanPeriodOpen.
  ///
  /// In en, this message translates to:
  /// **'From {start}'**
  String pdfPlanPeriodOpen(String start);

  /// No description provided for @workoutExerciseShortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF name (optional)'**
  String get workoutExerciseShortNameLabel;

  /// No description provided for @workoutExerciseScopeAllWeeks.
  ///
  /// In en, this message translates to:
  /// **'Same prescription every week'**
  String get workoutExerciseScopeAllWeeks;

  /// No description provided for @mobilityShortTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Short PDF title (optional)'**
  String get mobilityShortTitleLabel;

  /// No description provided for @mobilitySectionScheduleHintLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule / timing (optional)'**
  String get mobilitySectionScheduleHintLabel;

  /// No description provided for @workoutShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get workoutShare;

  /// No description provided for @workoutStartingWeek.
  ///
  /// In en, this message translates to:
  /// **'Starting week'**
  String get workoutStartingWeek;

  /// No description provided for @workoutStartingWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Week 1, 2, 3...'**
  String get workoutStartingWeekHint;

  /// Label for the calendar start date of a workout routine in the builder
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get workoutRoutineStartDate;

  /// Shown when no start date is set yet
  ///
  /// In en, this message translates to:
  /// **'Tap to choose'**
  String get workoutRoutineStartDatePlaceholder;

  /// No description provided for @workoutRoutineEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get workoutRoutineEndDate;

  /// No description provided for @workoutRoutineEndDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose'**
  String get workoutRoutineEndDatePlaceholder;

  /// No description provided for @workoutRoutineCurrentWeek.
  ///
  /// In en, this message translates to:
  /// **'Current week'**
  String get workoutRoutineCurrentWeek;

  /// No description provided for @workoutRoutineCurrentWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Select week'**
  String get workoutRoutineCurrentWeekHint;

  /// No description provided for @workoutPlanNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan notes'**
  String get workoutPlanNotesLabel;

  /// No description provided for @workoutPlanNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Internal notes for this plan'**
  String get workoutPlanNotesHint;

  /// No description provided for @workoutBuilderDetailsOptionsSection.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get workoutBuilderDetailsOptionsSection;

  /// No description provided for @workoutBuilderDetailsDatesSection.
  ///
  /// In en, this message translates to:
  /// **'Dates and week'**
  String get workoutBuilderDetailsDatesSection;

  /// No description provided for @workoutBuilderDetailsMetadataSection.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get workoutBuilderDetailsMetadataSection;

  /// No description provided for @workoutBuilderAddSheetExerciseSection.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get workoutBuilderAddSheetExerciseSection;

  /// No description provided for @workoutBuilderAddSheetSetsSection.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workoutBuilderAddSheetSetsSection;

  /// No description provided for @workoutBuilderAddSheetNotesSection.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get workoutBuilderAddSheetNotesSection;

  /// No description provided for @workoutCreateNewFromThis.
  ///
  /// In en, this message translates to:
  /// **'Create follow-up from this'**
  String get workoutCreateNewFromThis;

  /// No description provided for @workoutDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate workout'**
  String get workoutDuplicateTitle;

  /// No description provided for @workoutDuplicateNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name for the copy'**
  String get workoutDuplicateNameHint;

  /// No description provided for @workoutDuplicateAction.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get workoutDuplicateAction;

  /// No description provided for @workoutFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create follow-up workout'**
  String get workoutFollowUpTitle;

  /// No description provided for @workoutFollowUpNameHint.
  ///
  /// In en, this message translates to:
  /// **'Workout name'**
  String get workoutFollowUpNameHint;

  /// No description provided for @workoutFollowUpStartDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional start date'**
  String get workoutFollowUpStartDateOptional;

  /// No description provided for @workoutFollowUpStartDateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get workoutFollowUpStartDateClear;

  /// No description provided for @workoutFollowUpCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create follow-up'**
  String get workoutFollowUpCreateAction;

  /// No description provided for @workoutFollowUpCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Follow-up workout created.'**
  String get workoutFollowUpCreatedMessage;

  /// No description provided for @workoutFollowUpDefaultSuffix.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get workoutFollowUpDefaultSuffix;

  /// No description provided for @workoutDuplicateOf.
  ///
  /// In en, this message translates to:
  /// **'Copy of {name}'**
  String workoutDuplicateOf(Object name);

  /// No description provided for @workoutDuplicatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Workout created.'**
  String get workoutDuplicatedMessage;

  /// No description provided for @workoutNewPlanName.
  ///
  /// In en, this message translates to:
  /// **'New workout'**
  String get workoutNewPlanName;

  /// No description provided for @workoutDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get workoutDelete;

  /// No description provided for @workoutDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout?'**
  String get workoutDeleteConfirmTitle;

  /// No description provided for @workoutDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get workoutDeleteConfirmMessage;

  /// No description provided for @workoutDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Workout deleted.'**
  String get workoutDeletedMessage;

  /// No description provided for @workoutDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete workout.'**
  String get workoutDeleteError;

  /// No description provided for @workoutPlanArchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get workoutPlanArchiveAction;

  /// No description provided for @workoutPlanUnarchiveAction.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get workoutPlanUnarchiveAction;

  /// No description provided for @workoutPlanCompleteAction.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get workoutPlanCompleteAction;

  /// No description provided for @workoutPlanStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get workoutPlanStatusArchived;

  /// No description provided for @mobilityAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add mobility exercise'**
  String get mobilityAddExercise;

  /// No description provided for @mobilityCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get mobilityCreateNew;

  /// No description provided for @mobilityFromMobilityLibrary.
  ///
  /// In en, this message translates to:
  /// **'From mobility library'**
  String get mobilityFromMobilityLibrary;

  /// No description provided for @mobilityFromExerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'From exercise library'**
  String get mobilityFromExerciseLibrary;

  /// No description provided for @mobilitySaveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to mobility library'**
  String get mobilitySaveToLibrary;

  /// No description provided for @mobilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get mobilityTitle;

  /// No description provided for @mobilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get mobilitySubtitle;

  /// No description provided for @customerDetailOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get customerDetailOverview;

  /// No description provided for @customerDetailMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get customerDetailMeasurements;

  /// No description provided for @recordSearchExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get recordSearchExerciseHint;

  /// No description provided for @workoutBuilderLoadPercentGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Typical powerlifting intensities'**
  String get workoutBuilderLoadPercentGuideTitle;

  /// No description provided for @workoutBuilderLoadPercentGuideIntroMass.
  ///
  /// In en, this message translates to:
  /// **'Load for each percentage of the latest record.'**
  String get workoutBuilderLoadPercentGuideIntroMass;

  /// No description provided for @workoutBuilderLoadPercentGuideIntroReps.
  ///
  /// In en, this message translates to:
  /// **'Approximate reps per set at each % of your logged max (guideline).'**
  String get workoutBuilderLoadPercentGuideIntroReps;

  /// No description provided for @workoutBuilderLoadPercentGuideRow.
  ///
  /// In en, this message translates to:
  /// **'{percent}% — {weight} {unit}'**
  String workoutBuilderLoadPercentGuideRow(
    String percent,
    String weight,
    String unit,
  );

  /// No description provided for @workoutBuilderLoadPercentGuideBody.
  ///
  /// In en, this message translates to:
  /// **'100% — max / ~1 rep\n95% — ~2 reps\n90% — ~4 reps\n85% — ~6 reps\n80% — ~8 reps\n75% — ~10 reps\n70% — ~12 reps\n65% — ~15 reps\n60% — ~18+ reps\n55% — accessory work\n50% — recovery / technique'**
  String get workoutBuilderLoadPercentGuideBody;

  /// No description provided for @workoutBuilderLoadPercentCalculator.
  ///
  /// In en, this message translates to:
  /// **'Load from percentage'**
  String get workoutBuilderLoadPercentCalculator;

  /// No description provided for @workoutBuilderLoadPercentFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get workoutBuilderLoadPercentFieldLabel;

  /// No description provided for @workoutBuilderLoadPercentFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 77.5'**
  String get workoutBuilderLoadPercentFieldHint;

  /// No description provided for @workoutBuilderLoadPercentInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 1 and 100.'**
  String get workoutBuilderLoadPercentInvalid;

  /// No description provided for @workoutBuilderLoadPercentMassOnly.
  ///
  /// In en, this message translates to:
  /// **'Log a weight record (kg or lb) to use the percentage calculator.'**
  String get workoutBuilderLoadPercentMassOnly;

  /// No description provided for @workoutBuilderLoadPercentResult.
  ///
  /// In en, this message translates to:
  /// **'{weight} {unit} ({percent}% of record)'**
  String workoutBuilderLoadPercentResult(
    String weight,
    String unit,
    String percent,
  );

  /// No description provided for @workoutBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Builder'**
  String get workoutBuilderTitle;

  /// No description provided for @workoutBuilderPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Plan saved'**
  String get workoutBuilderPlanSaved;

  /// No description provided for @workoutBuilderRoutineSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine saved'**
  String get workoutBuilderRoutineSaved;

  /// No description provided for @workoutEditorUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get workoutEditorUnsavedTitle;

  /// No description provided for @workoutEditorUnsavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Save before leaving this screen?'**
  String get workoutEditorUnsavedMessage;

  /// No description provided for @workoutEditorSaveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save and exit'**
  String get workoutEditorSaveAndExit;

  /// No description provided for @workoutEditorDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get workoutEditorDiscard;

  /// No description provided for @workoutEditorCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workoutEditorCancel;

  /// No description provided for @workoutEditorAutosaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get workoutEditorAutosaving;

  /// No description provided for @workoutEditorSavedState.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get workoutEditorSavedState;

  /// No description provided for @workoutEditorUnsavedState.
  ///
  /// In en, this message translates to:
  /// **'Unsaved'**
  String get workoutEditorUnsavedState;

  /// No description provided for @workoutEditorSaveFailedState.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get workoutEditorSaveFailedState;

  /// No description provided for @workoutEditorRetrySave.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get workoutEditorRetrySave;

  /// No description provided for @workoutEditorAutosaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Autosave failed. You can keep editing and retry.'**
  String get workoutEditorAutosaveFailed;

  /// No description provided for @workoutEditorAutosaveHint.
  ///
  /// In en, this message translates to:
  /// **'Changes save automatically. Use Save to force an immediate save.'**
  String get workoutEditorAutosaveHint;

  /// No description provided for @workoutBuilderWeekMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions for the selected week'**
  String get workoutBuilderWeekMenuTooltip;

  /// No description provided for @workoutBuilderDayMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions for the selected day'**
  String get workoutBuilderDayMenuTooltip;

  /// No description provided for @workoutBuilderExerciseMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions for this exercise'**
  String get workoutBuilderExerciseMenuTooltip;

  /// No description provided for @workoutBuilderEditSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit section'**
  String get workoutBuilderEditSectionTitle;

  /// No description provided for @workoutBuilderDeleteSection.
  ///
  /// In en, this message translates to:
  /// **'Delete section'**
  String get workoutBuilderDeleteSection;

  /// No description provided for @workoutBuilderSectionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Section name'**
  String get workoutBuilderSectionNameLabel;

  /// No description provided for @workoutBuilderDeleteWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete week?'**
  String get workoutBuilderDeleteWeekTitle;

  /// No description provided for @workoutBuilderDeleteWeekMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this week and all its days and exercises. This cannot be undone.'**
  String get workoutBuilderDeleteWeekMessage;

  /// No description provided for @workoutBuilderRenameDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename day'**
  String get workoutBuilderRenameDayTitle;

  /// No description provided for @workoutBuilderDayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Day name'**
  String get workoutBuilderDayNameLabel;

  /// No description provided for @workoutBuilderRenameWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename week'**
  String get workoutBuilderRenameWeekTitle;

  /// No description provided for @workoutBuilderWeekNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Week name'**
  String get workoutBuilderWeekNameLabel;

  /// No description provided for @workoutBuilderDuplicateWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate week'**
  String get workoutBuilderDuplicateWeekTitle;

  /// No description provided for @workoutBuilderDuplicateWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Name for the new week'**
  String get workoutBuilderDuplicateWeekHint;

  /// No description provided for @workoutBuilderEditMobilityExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit mobility exercise'**
  String get workoutBuilderEditMobilityExerciseTitle;

  /// No description provided for @workoutBuilderAddMobilityExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add mobility exercise'**
  String get workoutBuilderAddMobilityExerciseTitle;

  /// No description provided for @workoutBuilderWeekNumbered.
  ///
  /// In en, this message translates to:
  /// **'Week {n}'**
  String workoutBuilderWeekNumbered(int n);

  /// No description provided for @workoutBuilderDayNumbered.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String workoutBuilderDayNumbered(int n);

  /// No description provided for @workoutBuilderSectionNumbered.
  ///
  /// In en, this message translates to:
  /// **'Section {n}'**
  String workoutBuilderSectionNumbered(int n);

  /// No description provided for @workoutBuilderNewExerciseDefault.
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get workoutBuilderNewExerciseDefault;

  /// No description provided for @workoutBuilderNameCopySuffix.
  ///
  /// In en, this message translates to:
  /// **' (copy)'**
  String get workoutBuilderNameCopySuffix;

  /// No description provided for @workoutBuilderRoutineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'ROUTINE NAME'**
  String get workoutBuilderRoutineNameLabel;

  /// No description provided for @workoutBuilderRoutineNameHint.
  ///
  /// In en, this message translates to:
  /// **'Add routine title'**
  String get workoutBuilderRoutineNameHint;

  /// No description provided for @workoutBuilderMobilityRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobility routine'**
  String get workoutBuilderMobilityRoutineTitle;

  /// No description provided for @workoutBuilderAddShort.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get workoutBuilderAddShort;

  /// No description provided for @workoutBuilderSectionHeading.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get workoutBuilderSectionHeading;

  /// No description provided for @workoutBuilderAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get workoutBuilderAddExercise;

  /// No description provided for @workoutBuilderAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get workoutBuilderAddSet;

  /// No description provided for @workoutBuilderPrescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add sets'**
  String get workoutBuilderPrescriptionPlaceholder;

  /// No description provided for @workoutBuilderAddExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get workoutBuilderAddExerciseTitle;

  /// No description provided for @workoutBuilderEditExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get workoutBuilderEditExerciseTitle;

  /// No description provided for @workoutBuilderExerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get workoutBuilderExerciseLabel;

  /// No description provided for @workoutBuilderExerciseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the exercise library.'**
  String get workoutBuilderExerciseLoadError;

  /// No description provided for @workoutBuilderExerciseRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get workoutBuilderExerciseRetry;

  /// No description provided for @workoutBuilderFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'From library'**
  String get workoutBuilderFromLibrary;

  /// No description provided for @workoutBuilderCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get workoutBuilderCreateNew;

  /// No description provided for @workoutBuilderCouldNotCreateExercise.
  ///
  /// In en, this message translates to:
  /// **'Could not create exercise. Try again or add without saving to library.'**
  String get workoutBuilderCouldNotCreateExercise;

  /// No description provided for @workoutBuilderEnterNameOrSelect.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or select an exercise.'**
  String get workoutBuilderEnterNameOrSelect;

  /// No description provided for @workoutBuilderSelectLibraryExercise.
  ///
  /// In en, this message translates to:
  /// **'Select an exercise from the library, or type the exact name.'**
  String get workoutBuilderSelectLibraryExercise;

  /// No description provided for @workoutBuilderSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get workoutBuilderSetLabel;

  /// No description provided for @workoutBuilderSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workoutBuilderSetsLabel;

  /// No description provided for @workoutBuilderRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get workoutBuilderRepsLabel;

  /// No description provided for @workoutBuilderLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get workoutBuilderLoadLabel;

  /// No description provided for @workoutBuilderRpeOrLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'RPE / Load'**
  String get workoutBuilderRpeOrLoadLabel;

  /// No description provided for @workoutBuilderNoteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get workoutBuilderNoteOptionalLabel;

  /// No description provided for @workoutBuilderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get workoutBuilderNameLabel;

  /// No description provided for @workoutBuilderNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get workoutBuilderNoteLabel;

  /// No description provided for @workoutBuilderEditSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit set'**
  String get workoutBuilderEditSetTitle;

  /// No description provided for @workoutBuilderTrainingProgram.
  ///
  /// In en, this message translates to:
  /// **'Training program'**
  String get workoutBuilderTrainingProgram;

  /// No description provided for @workoutBuilderNewWeek.
  ///
  /// In en, this message translates to:
  /// **'New week'**
  String get workoutBuilderNewWeek;

  /// No description provided for @workoutBuilderDuplicateWeek.
  ///
  /// In en, this message translates to:
  /// **'Duplicate week'**
  String get workoutBuilderDuplicateWeek;

  /// No description provided for @workoutBuilderRenameWeekMenu.
  ///
  /// In en, this message translates to:
  /// **'Rename week'**
  String get workoutBuilderRenameWeekMenu;

  /// No description provided for @workoutBuilderDeleteWeekMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete week'**
  String get workoutBuilderDeleteWeekMenu;

  /// No description provided for @workoutBuilderClone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get workoutBuilderClone;

  /// No description provided for @workoutBuilderAddDayToWeek.
  ///
  /// In en, this message translates to:
  /// **'Add day to week {n}'**
  String workoutBuilderAddDayToWeek(int n);

  /// No description provided for @workoutBuilderNoWeeksYet.
  ///
  /// In en, this message translates to:
  /// **'No weeks yet. Add a week above.'**
  String get workoutBuilderNoWeeksYet;

  /// No description provided for @workoutPhaseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Phase'**
  String get workoutPhaseAdd;

  /// No description provided for @workoutPhaseDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Phase'**
  String get workoutPhaseDuplicate;

  /// No description provided for @workoutPhaseSettings.
  ///
  /// In en, this message translates to:
  /// **'Phase Settings'**
  String get workoutPhaseSettings;

  /// No description provided for @workoutPhaseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No phases yet'**
  String get workoutPhaseEmptyTitle;

  /// No description provided for @workoutPhaseEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a phase to start structuring your training weeks.'**
  String get workoutPhaseEmptyMessage;

  /// No description provided for @workoutPhaseNumbered.
  ///
  /// In en, this message translates to:
  /// **'Phase {n}'**
  String workoutPhaseNumbered(int n);

  /// No description provided for @workoutPhaseWeeksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 Weeks} =1{1 Week} other{{count} Weeks}}'**
  String workoutPhaseWeeksCount(int count);

  /// No description provided for @workoutPhaseObjectiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get workoutPhaseObjectiveLabel;

  /// No description provided for @workoutPhaseObjectiveHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Volume accumulation, squat technique…'**
  String get workoutPhaseObjectiveHint;

  /// No description provided for @workoutPhaseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase name'**
  String get workoutPhaseNameLabel;

  /// No description provided for @workoutPhaseDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutPhaseDurationLabel;

  /// No description provided for @workoutPhaseFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get workoutPhaseFrequencyLabel;

  /// No description provided for @workoutPhaseFrequencyValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 sessions/wk} =1{1 session/wk} other{{count} sessions/wk}}'**
  String workoutPhaseFrequencyValue(int count);

  /// No description provided for @workoutPhaseProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get workoutPhaseProgressLabel;

  /// No description provided for @workoutPhaseProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String workoutPhaseProgressValue(int percent);

  /// No description provided for @workoutPhaseAddWeek.
  ///
  /// In en, this message translates to:
  /// **'Add week to phase'**
  String get workoutPhaseAddWeek;

  /// No description provided for @workoutPhaseEditSession.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get workoutPhaseEditSession;

  /// No description provided for @workoutPhaseCreateSession.
  ///
  /// In en, this message translates to:
  /// **'Create a new session'**
  String get workoutPhaseCreateSession;

  /// No description provided for @workoutPhaseCreateSessionForWeek.
  ///
  /// In en, this message translates to:
  /// **'Create a new session for Week {n}'**
  String workoutPhaseCreateSessionForWeek(int n);

  /// No description provided for @workoutPhaseAddDay.
  ///
  /// In en, this message translates to:
  /// **'Add Day'**
  String get workoutPhaseAddDay;

  /// No description provided for @workoutPhaseMoreExercises.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String workoutPhaseMoreExercises(int count);

  /// No description provided for @workoutPhaseNoExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get workoutPhaseNoExercisesYet;

  /// No description provided for @workoutPhaseSetsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 sets total} =1{1 set total} other{{count} sets total}}'**
  String workoutPhaseSetsTotal(int count);

  /// No description provided for @workoutPhaseWeeksCountShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 wks} =1{1 wk} other{{count} wks}}'**
  String workoutPhaseWeeksCountShort(int count);

  /// No description provided for @workoutPhaseExpandWeek.
  ///
  /// In en, this message translates to:
  /// **'Expand week'**
  String get workoutPhaseExpandWeek;

  /// No description provided for @workoutPhaseCollapseWeek.
  ///
  /// In en, this message translates to:
  /// **'Collapse week'**
  String get workoutPhaseCollapseWeek;

  /// No description provided for @workoutPhaseSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Phase settings'**
  String get workoutPhaseSettingsTitle;

  /// No description provided for @workoutPhaseDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this phase?'**
  String get workoutPhaseDeleteTitle;

  /// No description provided for @workoutPhaseDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This phase and all of its weeks will be removed. This cannot be undone.'**
  String get workoutPhaseDeleteMessage;

  /// No description provided for @workoutPhaseDeleteMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete phase'**
  String get workoutPhaseDeleteMenu;

  /// No description provided for @workoutPhaseCustomNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom phase'**
  String get workoutPhaseCustomNameTitle;

  /// No description provided for @workoutPhasePresetAccumulo.
  ///
  /// In en, this message translates to:
  /// **'Accumulation'**
  String get workoutPhasePresetAccumulo;

  /// No description provided for @workoutPhasePresetIntensificazione.
  ///
  /// In en, this message translates to:
  /// **'Intensification'**
  String get workoutPhasePresetIntensificazione;

  /// No description provided for @workoutPhasePresetPicco.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get workoutPhasePresetPicco;

  /// No description provided for @workoutPhasePresetDeload.
  ///
  /// In en, this message translates to:
  /// **'Deload'**
  String get workoutPhasePresetDeload;

  /// No description provided for @workoutPhasePresetMassa.
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get workoutPhasePresetMassa;

  /// No description provided for @workoutPhasePresetDefinizione.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get workoutPhasePresetDefinizione;

  /// No description provided for @workoutPhasePresetVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get workoutPhasePresetVolume;

  /// No description provided for @workoutPhasePresetAcclimatazione.
  ///
  /// In en, this message translates to:
  /// **'Acclimation'**
  String get workoutPhasePresetAcclimatazione;

  /// No description provided for @workoutPhasePresetGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get workoutPhasePresetGeneral;

  /// No description provided for @workoutPhasePresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get workoutPhasePresetCustom;

  /// No description provided for @workoutPhaseRemoved.
  ///
  /// In en, this message translates to:
  /// **'Phase removed'**
  String get workoutPhaseRemoved;

  /// No description provided for @workoutBuilderSuperSetHeading.
  ///
  /// In en, this message translates to:
  /// **'SUPER SET'**
  String get workoutBuilderSuperSetHeading;

  /// No description provided for @builderSupersetPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage superset'**
  String get builderSupersetPanelTitle;

  /// No description provided for @builderSupersetAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise to superset'**
  String get builderSupersetAddExercise;

  /// No description provided for @workoutBuilderAssignedPlanBadge.
  ///
  /// In en, this message translates to:
  /// **'Assigned plan · {customerName}'**
  String workoutBuilderAssignedPlanBadge(String customerName);

  /// No description provided for @workoutBuilderSessionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this session'**
  String get workoutBuilderSessionEmptyTitle;

  /// No description provided for @workoutSessionEditTitleWithDay.
  ///
  /// In en, this message translates to:
  /// **'Edit Session · {dayName}'**
  String workoutSessionEditTitleWithDay(String dayName);

  /// No description provided for @workoutSessionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get workoutSessionSaveChanges;

  /// No description provided for @workoutSessionHistoryShort.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get workoutSessionHistoryShort;

  /// No description provided for @workoutSessionDuplicateShort.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get workoutSessionDuplicateShort;

  /// No description provided for @workoutSessionAssignedPlanPill.
  ///
  /// In en, this message translates to:
  /// **'Assigned plan: {customerName}'**
  String workoutSessionAssignedPlanPill(String customerName);

  /// No description provided for @workoutSessionMetricExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get workoutSessionMetricExercises;

  /// No description provided for @workoutSessionMetricTotalSets.
  ///
  /// In en, this message translates to:
  /// **'Total sets'**
  String get workoutSessionMetricTotalSets;

  /// No description provided for @workoutSessionMetricSetsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String workoutSessionMetricSetsCount(int count);

  /// No description provided for @workoutSessionMetricEstimatedVolume.
  ///
  /// In en, this message translates to:
  /// **'Estimated volume'**
  String get workoutSessionMetricEstimatedVolume;

  /// No description provided for @workoutSessionMetricAvgRest.
  ///
  /// In en, this message translates to:
  /// **'Avg. rest'**
  String get workoutSessionMetricAvgRest;

  /// No description provided for @workoutSessionMetricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get workoutSessionMetricUnavailable;

  /// No description provided for @workoutSessionVolumeKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg'**
  String workoutSessionVolumeKg(String kg);

  /// No description provided for @workoutSessionAddFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add exercise from library'**
  String get workoutSessionAddFromLibrary;

  /// No description provided for @workoutSessionCreateSupersetCircuit.
  ///
  /// In en, this message translates to:
  /// **'Create Superset / Circuit'**
  String get workoutSessionCreateSupersetCircuit;

  /// No description provided for @workoutSessionAutosaveActive.
  ///
  /// In en, this message translates to:
  /// **'Draft autosave active'**
  String get workoutSessionAutosaveActive;

  /// No description provided for @workoutSessionAthletePreview.
  ///
  /// In en, this message translates to:
  /// **'Athlete plan preview →'**
  String get workoutSessionAthletePreview;

  /// No description provided for @workoutSessionTechnicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Technical notes'**
  String get workoutSessionTechnicalNotes;

  /// No description provided for @workoutSessionTechnicalNotesForAthlete.
  ///
  /// In en, this message translates to:
  /// **'Technical notes for athlete ({name}):'**
  String workoutSessionTechnicalNotesForAthlete(String name);

  /// No description provided for @workoutSessionSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get workoutSessionSavedHint;

  /// No description provided for @workoutSessionDuplicateLastSet.
  ///
  /// In en, this message translates to:
  /// **'Duplicate last set'**
  String get workoutSessionDuplicateLastSet;

  /// No description provided for @workoutSessionDuplicateLastSetN.
  ///
  /// In en, this message translates to:
  /// **'Duplicate last set (Set {n})'**
  String workoutSessionDuplicateLastSetN(int n);

  /// No description provided for @workoutSessionColSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get workoutSessionColSet;

  /// No description provided for @workoutSessionColReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get workoutSessionColReps;

  /// No description provided for @workoutSessionColLoadRpe.
  ///
  /// In en, this message translates to:
  /// **'LOAD / RPE'**
  String get workoutSessionColLoadRpe;

  /// No description provided for @workoutSessionColNote.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get workoutSessionColNote;

  /// No description provided for @builderSupersetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this superset.'**
  String get builderSupersetEmpty;

  /// No description provided for @builderSupersetPrescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescription (lead exercise)'**
  String get builderSupersetPrescriptionLabel;

  /// No description provided for @builderSupersetManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get builderSupersetManage;

  /// No description provided for @workoutBuilderDeleteDayMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete day'**
  String get workoutBuilderDeleteDayMenu;

  /// No description provided for @workoutBuilderNewSuperset.
  ///
  /// In en, this message translates to:
  /// **'New superset'**
  String get workoutBuilderNewSuperset;

  /// No description provided for @workoutBuilderRemoveFromSuperset.
  ///
  /// In en, this message translates to:
  /// **'Remove from superset'**
  String get workoutBuilderRemoveFromSuperset;

  /// No description provided for @workoutBuilderTabTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get workoutBuilderTabTraining;

  /// No description provided for @workoutBuilderTabMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get workoutBuilderTabMobility;

  /// No description provided for @workoutBuilderTabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get workoutBuilderTabDetails;

  /// No description provided for @workoutBuilderNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add note…'**
  String get workoutBuilderNotePlaceholder;

  /// No description provided for @workoutBuilderMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get workoutBuilderMoreActions;

  /// No description provided for @workoutBuilderMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get workoutBuilderMoveUp;

  /// No description provided for @workoutBuilderMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get workoutBuilderMoveDown;

  /// No description provided for @workoutBuilderEditExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get workoutBuilderEditExercise;

  /// No description provided for @workoutBuilderDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get workoutBuilderDeleteExercise;

  /// No description provided for @workoutBuilderDuplicateExercise.
  ///
  /// In en, this message translates to:
  /// **'Duplicate exercise'**
  String get workoutBuilderDuplicateExercise;

  /// No description provided for @workoutBuilderExerciseRemoved.
  ///
  /// In en, this message translates to:
  /// **'Exercise removed'**
  String get workoutBuilderExerciseRemoved;

  /// No description provided for @workoutBuilderUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get workoutBuilderUndo;

  /// No description provided for @workoutBuilderWeekRemoved.
  ///
  /// In en, this message translates to:
  /// **'Week removed'**
  String get workoutBuilderWeekRemoved;

  /// No description provided for @workoutBuilderSupersetUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Removed from superset'**
  String get workoutBuilderSupersetUnlinked;

  /// No description provided for @workoutBuilderMobilityItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Mobility item removed'**
  String get workoutBuilderMobilityItemRemoved;

  /// No description provided for @workoutBuilderOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting started with the workout builder'**
  String get workoutBuilderOnboardingTitle;

  /// No description provided for @workoutBuilderOnboardingStep1.
  ///
  /// In en, this message translates to:
  /// **'Pick a week and day in the Training tab.'**
  String get workoutBuilderOnboardingStep1;

  /// No description provided for @workoutBuilderOnboardingStep2.
  ///
  /// In en, this message translates to:
  /// **'Add exercises from your library or create new ones.'**
  String get workoutBuilderOnboardingStep2;

  /// No description provided for @workoutBuilderOnboardingStep3.
  ///
  /// In en, this message translates to:
  /// **'Set start/end dates in Details so sessions appear on the calendar.'**
  String get workoutBuilderOnboardingStep3;

  /// No description provided for @workoutBuilderOnboardingDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get workoutBuilderOnboardingDismiss;

  /// No description provided for @workoutBuilderCompactAddSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises…'**
  String get workoutBuilderCompactAddSearchHint;

  /// No description provided for @workoutBuilderCompactAddRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent & pinned'**
  String get workoutBuilderCompactAddRecent;

  /// No description provided for @workoutBuilderCompactAddEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises match your search.'**
  String get workoutBuilderCompactAddEmpty;

  /// No description provided for @workoutBuilderCompactAddFullEditor.
  ///
  /// In en, this message translates to:
  /// **'Edit prescription'**
  String get workoutBuilderCompactAddFullEditor;

  /// No description provided for @workoutBuilderIncludeMobilityTab.
  ///
  /// In en, this message translates to:
  /// **'Include mobility tab'**
  String get workoutBuilderIncludeMobilityTab;

  /// No description provided for @workoutBuilderIncludeMobilityTabHint.
  ///
  /// In en, this message translates to:
  /// **'Show the mobility section alongside training and details.'**
  String get workoutBuilderIncludeMobilityTabHint;

  /// No description provided for @workoutBuilderDayHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get workoutBuilderDayHistory;

  /// No description provided for @workoutBuilderSessionActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Session actions'**
  String get workoutBuilderSessionActionsTooltip;

  /// No description provided for @workoutBuilderSessionMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get workoutBuilderSessionMenuLabel;

  /// No description provided for @workoutBuilderRoutineTitleFromCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add title · {name}'**
  String workoutBuilderRoutineTitleFromCustomer(String name);

  /// No description provided for @workoutDiarySessionFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Showing sessions for this plan day'**
  String get workoutDiarySessionFilterActive;

  /// No description provided for @workoutBuilderNavLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get workoutBuilderNavLibrary;

  /// No description provided for @workoutBuilderNavBuilder.
  ///
  /// In en, this message translates to:
  /// **'Builder'**
  String get workoutBuilderNavBuilder;

  /// No description provided for @workoutBuilderNavDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get workoutBuilderNavDiary;

  /// No description provided for @workoutBuilderWeeksLabel.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get workoutBuilderWeeksLabel;

  /// No description provided for @workoutBuilderDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get workoutBuilderDaysLabel;

  /// No description provided for @workoutBuilderCalendarWeekdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Calendar weekday'**
  String get workoutBuilderCalendarWeekdayLabel;

  /// No description provided for @workoutBuilderCalendarWeekdayHint.
  ///
  /// In en, this message translates to:
  /// **'Weekday used for scheduling this day in calendar views.'**
  String get workoutBuilderCalendarWeekdayHint;

  /// No description provided for @workoutBuilderScheduledWeekdayFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get workoutBuilderScheduledWeekdayFlexible;

  /// No description provided for @workoutBuilderScheduledWeekdayFlexibleHint.
  ///
  /// In en, this message translates to:
  /// **'No fixed weekday — the athlete can train on any day.'**
  String get workoutBuilderScheduledWeekdayFlexibleHint;

  /// No description provided for @workoutBuilderAddDayChip.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get workoutBuilderAddDayChip;

  /// No description provided for @workoutBuilderNoDaysInWeek.
  ///
  /// In en, this message translates to:
  /// **'No days in this week yet.'**
  String get workoutBuilderNoDaysInWeek;

  /// No description provided for @workoutBuilderDeleteDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete day?'**
  String get workoutBuilderDeleteDayTitle;

  /// No description provided for @workoutBuilderDeleteDayMessage.
  ///
  /// In en, this message translates to:
  /// **'All exercises on this day will be removed.'**
  String get workoutBuilderDeleteDayMessage;

  /// No description provided for @workoutBuilderSwipeDayHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe a day up to delete it'**
  String get workoutBuilderSwipeDayHint;

  /// No description provided for @workoutBuilderExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No exercises} =1{1 exercise} other{{count} exercises}}'**
  String workoutBuilderExerciseCount(int count);

  /// No description provided for @workoutBuilderSaveToPersistHint.
  ///
  /// In en, this message translates to:
  /// **'Save now to link the plan to this client, or keep editing — autosave creates the plan on your first edit.'**
  String get workoutBuilderSaveToPersistHint;

  /// No description provided for @workoutBuilderSaveNowAction.
  ///
  /// In en, this message translates to:
  /// **'Save now'**
  String get workoutBuilderSaveNowAction;

  /// No description provided for @customerNewWorkoutSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'New workout plan'**
  String get customerNewWorkoutSheetTitle;

  /// No description provided for @customerNewWorkoutBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank plan'**
  String get customerNewWorkoutBlank;

  /// No description provided for @customerNewWorkoutBlankHint.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch in the builder'**
  String get customerNewWorkoutBlankHint;

  /// No description provided for @customerNewWorkoutFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up from existing plan'**
  String get customerNewWorkoutFollowUp;

  /// No description provided for @customerNewWorkoutFollowUpHint.
  ///
  /// In en, this message translates to:
  /// **'Next mesocycle: reset progress, keep structure, apply logged loads when available'**
  String get customerNewWorkoutFollowUpHint;

  /// No description provided for @customerNewWorkoutFollowUpPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to continue'**
  String get customerNewWorkoutFollowUpPickTitle;

  /// No description provided for @customerNewWorkoutNoPlansForFollowUp.
  ///
  /// In en, this message translates to:
  /// **'No plans to continue for this client.'**
  String get customerNewWorkoutNoPlansForFollowUp;

  /// No description provided for @customerNewWorkoutDuplicateExisting.
  ///
  /// In en, this message translates to:
  /// **'Duplicate existing plan'**
  String get customerNewWorkoutDuplicateExisting;

  /// No description provided for @customerNewWorkoutDuplicateExistingHint.
  ///
  /// In en, this message translates to:
  /// **'Exact copy of a plan — progress and loads stay as-is'**
  String get customerNewWorkoutDuplicateExistingHint;

  /// No description provided for @customerNewWorkoutNoPlansToDuplicate.
  ///
  /// In en, this message translates to:
  /// **'No plans to duplicate for this client.'**
  String get customerNewWorkoutNoPlansToDuplicate;

  /// No description provided for @customerNewWorkoutDuplicatePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to duplicate'**
  String get customerNewWorkoutDuplicatePickTitle;

  /// No description provided for @workoutPdfPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF preview'**
  String get workoutPdfPreviewTitle;

  /// No description provided for @workoutPdfPreviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PDF is ready. Open a preview in a new tab or download it.'**
  String get workoutPdfPreviewMessage;

  /// No description provided for @workoutPdfPreviewOpen.
  ///
  /// In en, this message translates to:
  /// **'Open preview'**
  String get workoutPdfPreviewOpen;

  /// No description provided for @workoutPdfPreviewDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get workoutPdfPreviewDownload;

  /// No description provided for @workoutPdfPreviewOpened.
  ///
  /// In en, this message translates to:
  /// **'PDF preview opened in a new tab.'**
  String get workoutPdfPreviewOpened;

  /// No description provided for @pdfExportPostGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF ready'**
  String get pdfExportPostGenerateTitle;

  /// No description provided for @pdfExportPostGenerateMessage.
  ///
  /// In en, this message translates to:
  /// **'Your PDF is ready. Preview it, share it, or save it.'**
  String get pdfExportPostGenerateMessage;

  /// No description provided for @pdfExportPreviewThenShareTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF preview'**
  String get pdfExportPreviewThenShareTitle;

  /// No description provided for @pdfExportPreviewThenShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Review the PDF, then share or save.'**
  String get pdfExportPreviewThenShareMessage;

  /// No description provided for @pdfExportActionPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get pdfExportActionPreview;

  /// No description provided for @pdfExportActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pdfExportActionShare;

  /// No description provided for @pdfExportActionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pdfExportActionSave;

  /// No description provided for @pdfExportActionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get pdfExportActionClose;

  /// No description provided for @pdfExportPreviewOpened.
  ///
  /// In en, this message translates to:
  /// **'PDF preview opened.'**
  String get pdfExportPreviewOpened;

  /// No description provided for @pdfExportSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF shared.'**
  String get pdfExportSharedSuccess;

  /// No description provided for @pdfExportSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF saved to Downloads.'**
  String get pdfExportSavedSuccess;

  /// No description provided for @pdfExportSaveUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Downloads folder is not available on this device. Use Share instead.'**
  String get pdfExportSaveUnavailable;

  /// No description provided for @customerTabWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get customerTabWorkouts;

  /// No description provided for @dashboardWorkoutBuilderDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft builder'**
  String get dashboardWorkoutBuilderDraft;

  /// No description provided for @workoutBuilderSandboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft builder'**
  String get workoutBuilderSandboxTitle;

  /// No description provided for @workoutBuilderSandboxBanner.
  ///
  /// In en, this message translates to:
  /// **'Local draft on this device — not on a client'**
  String get workoutBuilderSandboxBanner;

  /// No description provided for @workoutBuilderSandboxBannerHint.
  ///
  /// In en, this message translates to:
  /// **'Save keeps the draft only here. It appears under the client only after Assign to client.'**
  String get workoutBuilderSandboxBannerHint;

  /// No description provided for @workoutBuilderAssignToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Assign to client'**
  String get workoutBuilderAssignToCustomer;

  /// No description provided for @workoutAssignCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a client'**
  String get workoutAssignCustomerTitle;

  /// No description provided for @workoutAssignCustomerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get workoutAssignCustomerSearchHint;

  /// No description provided for @workoutAssignCustomerNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No customers match your search.'**
  String get workoutAssignCustomerNoMatch;

  /// No description provided for @workoutAssignCustomersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the client list. Try again.'**
  String get workoutAssignCustomersLoadError;

  /// No description provided for @workoutBuilderAssignDraftSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan assigned to client.'**
  String get workoutBuilderAssignDraftSuccess;

  /// No description provided for @workoutBuilderLogSession.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get workoutBuilderLogSession;

  /// No description provided for @workoutBuilderLogSessionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session logged.'**
  String get workoutBuilderLogSessionSuccess;

  /// No description provided for @workoutBuilderCloneDayToTarget.
  ///
  /// In en, this message translates to:
  /// **'Duplicate to…'**
  String get workoutBuilderCloneDayToTarget;

  /// No description provided for @workoutBuilderCloneDayTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate day to'**
  String get workoutBuilderCloneDayTargetTitle;

  /// No description provided for @workoutBuilderReadOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'Read-only — duplicate the plan to edit it.'**
  String get workoutBuilderReadOnlyBanner;

  /// No description provided for @planScheduleEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Set start date'**
  String get planScheduleEmptyHint;

  /// No description provided for @workoutBuilderEmptyDayCta.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get workoutBuilderEmptyDayCta;

  /// No description provided for @workoutActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again.'**
  String get workoutActionFailed;

  /// No description provided for @workoutPlansLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this client\'s workout plans.'**
  String get workoutPlansLoadError;

  /// No description provided for @workoutDiaryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the workout diary.'**
  String get workoutDiaryLoadError;

  /// No description provided for @measurementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get measurementsEmpty;

  /// No description provided for @measurementsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a measurement to track 1RM, body composition, and circumferences.'**
  String get measurementsEmptyHint;

  /// No description provided for @measurementAdd.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get measurementAdd;

  /// No description provided for @measurementEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit measurement'**
  String get measurementEdit;

  /// No description provided for @measurementDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get measurementDate;

  /// No description provided for @measurementDateDetected.
  ///
  /// In en, this message translates to:
  /// **'Measurement date'**
  String get measurementDateDetected;

  /// No description provided for @measurementToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get measurementToday;

  /// No description provided for @measurement1RM.
  ///
  /// In en, this message translates to:
  /// **'1RM (kg)'**
  String get measurement1RM;

  /// No description provided for @measurement1RMSection.
  ///
  /// In en, this message translates to:
  /// **'Estimated or tested 1RM (kg)'**
  String get measurement1RMSection;

  /// No description provided for @measurementSquat.
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get measurementSquat;

  /// No description provided for @measurementBench.
  ///
  /// In en, this message translates to:
  /// **'Bench press'**
  String get measurementBench;

  /// No description provided for @measurementDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Deadlift'**
  String get measurementDeadlift;

  /// No description provided for @measurementSbdTotal.
  ///
  /// In en, this message translates to:
  /// **'SBD total'**
  String get measurementSbdTotal;

  /// No description provided for @measurementSbdEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated SBD total'**
  String get measurementSbdEstimated;

  /// No description provided for @measurementBodyComp.
  ///
  /// In en, this message translates to:
  /// **'Body composition'**
  String get measurementBodyComp;

  /// No description provided for @measurementFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update 1RM loads, skinfolds, and body metrics'**
  String get measurementFormSubtitle;

  /// No description provided for @measurementDeltaUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Unchanged'**
  String get measurementDeltaUnchanged;

  /// No description provided for @measurementBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat %'**
  String get measurementBodyFat;

  /// No description provided for @measurementMuscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle mass (kg)'**
  String get measurementMuscleMass;

  /// No description provided for @measurementNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get measurementNotes;

  /// No description provided for @measurementSaved.
  ///
  /// In en, this message translates to:
  /// **'Measurement saved.'**
  String get measurementSaved;

  /// No description provided for @measurementSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save measurement.'**
  String get measurementSaveError;

  /// No description provided for @measurementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted.'**
  String get measurementDeleted;

  /// No description provided for @measurementDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete measurement.'**
  String get measurementDeleteError;

  /// No description provided for @measurementDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this measurement?'**
  String get measurementDeleteConfirm;

  /// No description provided for @measurementHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement history'**
  String get measurementHistoryTitle;

  /// No description provided for @measurementHistoryMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get measurementHistoryMetricLabel;

  /// No description provided for @measurementHistoryNoMetricData.
  ///
  /// In en, this message translates to:
  /// **'No values recorded for this metric yet.'**
  String get measurementHistoryNoMetricData;

  /// No description provided for @measurementHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load measurement history.'**
  String get measurementHistoryLoadError;

  /// No description provided for @measurementHistoryOpen.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get measurementHistoryOpen;

  /// No description provided for @measurementHistoryOpenFull.
  ///
  /// In en, this message translates to:
  /// **'Open full history'**
  String get measurementHistoryOpenFull;

  /// No description provided for @measurementHistoryRange30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get measurementHistoryRange30d;

  /// No description provided for @measurementHistoryRange3m.
  ///
  /// In en, this message translates to:
  /// **'3m'**
  String get measurementHistoryRange3m;

  /// No description provided for @measurementHistoryRange6m.
  ///
  /// In en, this message translates to:
  /// **'6m'**
  String get measurementHistoryRange6m;

  /// No description provided for @measurementHistoryRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get measurementHistoryRangeAll;

  /// No description provided for @measurementHistoryCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get measurementHistoryCurrentValue;

  /// No description provided for @measurementHistoryRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered measurements'**
  String get measurementHistoryRegistered;

  /// No description provided for @customerNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Client notes'**
  String get customerNotesTitle;

  /// No description provided for @customerNotesTitleFor.
  ///
  /// In en, this message translates to:
  /// **'Notes — {customerName}'**
  String customerNotesTitleFor(String customerName);

  /// No description provided for @customerNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Write a note for this client…'**
  String get customerNotesHint;

  /// No description provided for @customerNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Add a follow-up, injury note, or preference.'**
  String get customerNotesEmpty;

  /// No description provided for @customerNotesSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get customerNotesSend;

  /// No description provided for @customerNotesOpen.
  ///
  /// In en, this message translates to:
  /// **'Open notes'**
  String get customerNotesOpen;

  /// No description provided for @customerNotesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty.'**
  String get customerNotesEmptyBody;

  /// No description provided for @customerNotesSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the note.'**
  String get customerNotesSendError;

  /// No description provided for @customerNotesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load notes.'**
  String get customerNotesLoadError;

  /// No description provided for @measurementExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get measurementExportCsv;

  /// No description provided for @measurementExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get measurementExportPdf;

  /// No description provided for @measurementExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Download started.'**
  String get measurementExportSuccess;

  /// No description provided for @measurementExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export measurements.'**
  String get measurementExportError;

  /// No description provided for @measurementHistoryExportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements — {customerName}'**
  String measurementHistoryExportPdfTitle(String customerName);

  /// No description provided for @syncConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync conflict detected'**
  String get syncConflictTitle;

  /// No description provided for @syncConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'There are conflicting local and remote changes. Choose whether to keep local changes or accept the remote version.'**
  String get syncConflictMessage;

  /// No description provided for @syncConflictMessageWithEntity.
  ///
  /// In en, this message translates to:
  /// **'Conflicting changes for {entityType}. Keep your edits or use the server copy.'**
  String syncConflictMessageWithEntity(String entityType);

  /// No description provided for @syncConflictUseRemote.
  ///
  /// In en, this message translates to:
  /// **'Use remote'**
  String get syncConflictUseRemote;

  /// No description provided for @syncConflictUseLocal.
  ///
  /// In en, this message translates to:
  /// **'Use local'**
  String get syncConflictUseLocal;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing changes...'**
  String get syncInProgress;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync: {count}'**
  String syncPending(int count);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {count} pending'**
  String syncFailed(int count);

  /// No description provided for @settingsSyncSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSyncSectionTitle;

  /// No description provided for @settingsSyncSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{pending} queued, {failed} need attention'**
  String settingsSyncSectionSubtitle(int pending, int failed);

  /// No description provided for @settingsSyncRetryFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry failed operations'**
  String get settingsSyncRetryFailed;

  /// No description provided for @syncIssuesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync issues'**
  String get syncIssuesScreenTitle;

  /// No description provided for @syncIssueDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync issue details'**
  String get syncIssueDetailTitle;

  /// No description provided for @syncIssueLocalVersion.
  ///
  /// In en, this message translates to:
  /// **'Local version'**
  String get syncIssueLocalVersion;

  /// No description provided for @syncIssueRemoteVersion.
  ///
  /// In en, this message translates to:
  /// **'Remote version'**
  String get syncIssueRemoteVersion;

  /// No description provided for @syncIssuePathLabel.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get syncIssuePathLabel;

  /// No description provided for @syncNoIssues.
  ///
  /// In en, this message translates to:
  /// **'No sync issues need attention'**
  String get syncNoIssues;

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get syncRetry;

  /// No description provided for @syncIssueDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard operation'**
  String get syncIssueDiscard;

  /// No description provided for @syncRetryStarted.
  ///
  /// In en, this message translates to:
  /// **'Retry queued for {count} operations'**
  String syncRetryStarted(int count);

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get dashboardWeeklyProgress;

  /// No description provided for @dashboardPlansUpdatedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Plans Updated This Week'**
  String get dashboardPlansUpdatedThisWeek;

  /// No description provided for @dashboardTotalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get dashboardTotalClients;

  /// No description provided for @dashboardActivePrograms.
  ///
  /// In en, this message translates to:
  /// **'Active Programs'**
  String get dashboardActivePrograms;

  /// No description provided for @dashboardCreateProgram.
  ///
  /// In en, this message translates to:
  /// **'Create Program'**
  String get dashboardCreateProgram;

  /// No description provided for @dashboardTodaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get dashboardTodaySchedule;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoScheduleToday.
  ///
  /// In en, this message translates to:
  /// **'No schedule items for today.'**
  String get dashboardNoScheduleToday;

  /// No description provided for @dashboardNoScheduledWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No scheduled workouts yet.'**
  String get dashboardNoScheduledWorkoutsYet;

  /// No description provided for @dashboardUnknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown client'**
  String get dashboardUnknownClient;

  /// No description provided for @dashboardUntitledWorkout.
  ///
  /// In en, this message translates to:
  /// **'Untitled workout'**
  String get dashboardUntitledWorkout;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarEmptyMonth.
  ///
  /// In en, this message translates to:
  /// **'No sessions on this day.'**
  String get calendarEmptyMonth;

  /// No description provided for @calendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the calendar.'**
  String get calendarLoadError;

  /// No description provided for @calendarUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update session status.'**
  String get calendarUpdateError;

  /// No description provided for @calendarUpcomingSessions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming sessions'**
  String get calendarUpcomingSessions;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionCompleted;

  /// No description provided for @sessionSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get sessionSkipped;

  /// No description provided for @sessionPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get sessionPlanned;

  /// No description provided for @sessionMarkPlanned.
  ///
  /// In en, this message translates to:
  /// **'Mark as planned'**
  String get sessionMarkPlanned;

  /// No description provided for @sessionDetailOpenBuilder.
  ///
  /// In en, this message translates to:
  /// **'Open in builder'**
  String get sessionDetailOpenBuilder;

  /// No description provided for @sessionDetailExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String sessionDetailExercisesCount(int count);

  /// No description provided for @sessionReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule session'**
  String get sessionReschedule;

  /// No description provided for @sessionSkipDate.
  ///
  /// In en, this message translates to:
  /// **'Skip this date'**
  String get sessionSkipDate;

  /// No description provided for @sessionOverrideClear.
  ///
  /// In en, this message translates to:
  /// **'Remove date override'**
  String get sessionOverrideClear;

  /// No description provided for @dashboardWorkoutBuilder.
  ///
  /// In en, this message translates to:
  /// **'Workout Builder'**
  String get dashboardWorkoutBuilder;

  /// No description provided for @dashboardSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get dashboardSessionTitle;

  /// No description provided for @dashboardDetailHint.
  ///
  /// In en, this message translates to:
  /// **'Details are based on the selected workout plan start date.'**
  String get dashboardDetailHint;

  /// No description provided for @dashboardSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardSectionToday;

  /// No description provided for @dashboardSectionAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get dashboardSectionAttention;

  /// No description provided for @dashboardSectionStalePlans.
  ///
  /// In en, this message translates to:
  /// **'Plans to refresh'**
  String get dashboardSectionStalePlans;

  /// No description provided for @dashboardSectionCustomersNoPlan.
  ///
  /// In en, this message translates to:
  /// **'Clients without a program'**
  String get dashboardSectionCustomersNoPlan;

  /// No description provided for @dashboardCoachToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach tools'**
  String get dashboardCoachToolsTitle;

  /// No description provided for @dashboardDiaryAction.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dashboardDiaryAction;

  /// No description provided for @dashboardDiarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions (30d)'**
  String dashboardDiarySubtitle(int count);

  /// No description provided for @customerOpenDiary.
  ///
  /// In en, this message translates to:
  /// **'Open diary'**
  String get customerOpenDiary;

  /// No description provided for @dashboardNoPending.
  ///
  /// In en, this message translates to:
  /// **'No items need your attention right now.'**
  String get dashboardNoPending;

  /// No description provided for @dashboardBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device. Export a backup from Settings before reinstalling or switching devices.'**
  String get dashboardBackupHint;

  /// No description provided for @dashboardOpenBackupSettings.
  ///
  /// In en, this message translates to:
  /// **'Open backup settings'**
  String get dashboardOpenBackupSettings;

  /// No description provided for @dashboardDataHealthIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} data issues need review'**
  String dashboardDataHealthIssuesTitle(int count);

  /// No description provided for @dashboardDataHealthIssuesHint.
  ///
  /// In en, this message translates to:
  /// **'Orphan plans, broken pins, or integrity problems in local data. Review and repair in Data health.'**
  String get dashboardDataHealthIssuesHint;

  /// No description provided for @dashboardOpenDataHealth.
  ///
  /// In en, this message translates to:
  /// **'Open data health'**
  String get dashboardOpenDataHealth;

  /// No description provided for @dashboardDataHealthMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String dashboardDataHealthMoreCount(int count);

  /// No description provided for @dashboardBackupReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Your last backup is over 7 days old. Export or upload a recent copy for safety.'**
  String get dashboardBackupReminderMessage;

  /// No description provided for @dashboardBackupReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect technical sheets, progressions, and max tests for your athletes.'**
  String get dashboardBackupReminderSubtitle;

  /// No description provided for @dashboardBackupReminderCta.
  ///
  /// In en, this message translates to:
  /// **'Open backup in settings →'**
  String get dashboardBackupReminderCta;

  /// No description provided for @dashboardBackupReminderSnooze.
  ///
  /// In en, this message translates to:
  /// **'Remind me in 3 days'**
  String get dashboardBackupReminderSnooze;

  /// No description provided for @dashboardBackupReminderDismissSemantic.
  ///
  /// In en, this message translates to:
  /// **'Dismiss reminder'**
  String get dashboardBackupReminderDismissSemantic;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the dashboard. Pull down to try again.'**
  String get dashboardLoadError;

  /// No description provided for @dashboardNoStalePlans.
  ///
  /// In en, this message translates to:
  /// **'All programs were updated within the last {days} days.'**
  String dashboardNoStalePlans(int days);

  /// No description provided for @dashboardNoCustomersWithoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Every client has at least one program.'**
  String get dashboardNoCustomersWithoutPlan;

  /// No description provided for @dashboardPendingDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync operation'**
  String get dashboardPendingDetailTitle;

  /// No description provided for @dashboardPendingStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String dashboardPendingStatusLabel(String status);

  /// No description provided for @dashboardPendingEntityLabel.
  ///
  /// In en, this message translates to:
  /// **'Entity: {entity}'**
  String dashboardPendingEntityLabel(String entity);

  /// No description provided for @dashboardPendingPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Path: {path}'**
  String dashboardPendingPathLabel(String path);

  /// No description provided for @dashboardSyncStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboardSyncStatusPending;

  /// No description provided for @dashboardSyncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get dashboardSyncStatusSyncing;

  /// No description provided for @dashboardSyncStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get dashboardSyncStatusFailed;

  /// No description provided for @dashboardSyncStatusConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get dashboardSyncStatusConflict;

  /// No description provided for @dashboardSyncStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dashboardSyncStatusCompleted;

  /// No description provided for @dashboardSyncStatusDeadLetter.
  ///
  /// In en, this message translates to:
  /// **'Could not sync'**
  String get dashboardSyncStatusDeadLetter;

  /// No description provided for @dashboardSyncStatusBlockedAuth.
  ///
  /// In en, this message translates to:
  /// **'Waiting for sign-in'**
  String get dashboardSyncStatusBlockedAuth;

  /// No description provided for @dashboardSemanticTodayList.
  ///
  /// In en, this message translates to:
  /// **'Programs starting today'**
  String get dashboardSemanticTodayList;

  /// No description provided for @dashboardSemanticAttentionList.
  ///
  /// In en, this message translates to:
  /// **'Sync queue and errors'**
  String get dashboardSemanticAttentionList;

  /// No description provided for @dashboardSemanticNoPlanList.
  ///
  /// In en, this message translates to:
  /// **'Clients without a program'**
  String get dashboardSemanticNoPlanList;

  /// No description provided for @dashboardSemanticStaleList.
  ///
  /// In en, this message translates to:
  /// **'Programs that may need an update'**
  String get dashboardSemanticStaleList;

  /// No description provided for @dashboardCoachStudioBadge.
  ///
  /// In en, this message translates to:
  /// **'Coach Studio'**
  String get dashboardCoachStudioBadge;

  /// No description provided for @dashboardMetricAthletes.
  ///
  /// In en, this message translates to:
  /// **'Athletes followed'**
  String get dashboardMetricAthletes;

  /// No description provided for @dashboardMetricActivePlans.
  ///
  /// In en, this message translates to:
  /// **'Active plans'**
  String get dashboardMetricActivePlans;

  /// No description provided for @dashboardMetricWeeklyUpdates.
  ///
  /// In en, this message translates to:
  /// **'Weekly updates'**
  String get dashboardMetricWeeklyUpdates;

  /// No description provided for @dashboardMetricCoachAttention.
  ///
  /// In en, this message translates to:
  /// **'Coach attention'**
  String get dashboardMetricCoachAttention;

  /// No description provided for @dashboardMetricAlertsSuffix.
  ///
  /// In en, this message translates to:
  /// **'alerts'**
  String get dashboardMetricAlertsSuffix;

  /// No description provided for @dashboardTodayEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No sessions or reminders planned for this date. Open the calendar.'**
  String get dashboardTodayEmptyHint;

  /// No description provided for @dashboardOpenAgenda.
  ///
  /// In en, this message translates to:
  /// **'Open agenda'**
  String get dashboardOpenAgenda;

  /// No description provided for @dashboardCoachToolsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} tools available'**
  String dashboardCoachToolsAvailable(int count);

  /// No description provided for @dashboardAttentionLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Your data stays stored on this device.'**
  String get dashboardAttentionLocalHint;

  /// No description provided for @dashboardNoCustomersWithoutPlanHint.
  ///
  /// In en, this message translates to:
  /// **'No athletes waiting for a first plan assignment.'**
  String get dashboardNoCustomersWithoutPlanHint;

  /// No description provided for @dashboardNoPlanAllAssignedBadge.
  ///
  /// In en, this message translates to:
  /// **'100% assigned'**
  String get dashboardNoPlanAllAssignedBadge;

  /// No description provided for @dashboardStaleWindowBadge.
  ///
  /// In en, this message translates to:
  /// **'{days}-day window'**
  String dashboardStaleWindowBadge(int days);

  /// No description provided for @dashboardNoStalePlansHint.
  ///
  /// In en, this message translates to:
  /// **'No programs older than the {days}-day refresh window.'**
  String dashboardNoStalePlansHint(int days);

  /// No description provided for @dashboardShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Management shortcuts'**
  String get dashboardShortcutsTitle;

  /// No description provided for @dashboardShortcutLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises and folders'**
  String get dashboardShortcutLibrarySubtitle;

  /// No description provided for @dashboardShortcutNewAthlete.
  ///
  /// In en, this message translates to:
  /// **'New athlete'**
  String get dashboardShortcutNewAthlete;

  /// No description provided for @dashboardShortcutNewAthleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile and plan'**
  String get dashboardShortcutNewAthleteSubtitle;

  /// No description provided for @dashboardShortcutSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and local data'**
  String get dashboardShortcutSettingsSubtitle;

  /// No description provided for @dashboardCreateWorkout.
  ///
  /// In en, this message translates to:
  /// **'New workout'**
  String get dashboardCreateWorkout;

  /// No description provided for @dashboardOfflineFooter.
  ///
  /// In en, this message translates to:
  /// **'Coach Studio · Offline-first athletic monitoring and planning.'**
  String get dashboardOfflineFooter;

  /// No description provided for @customerEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get customerEditProfile;

  /// No description provided for @customerAssignWorkout.
  ///
  /// In en, this message translates to:
  /// **'Assign Workout'**
  String get customerAssignWorkout;

  /// No description provided for @customerGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get customerGoalLabel;

  /// No description provided for @customerCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get customerCurrentWeight;

  /// No description provided for @customerMuscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle Mass'**
  String get customerMuscleMass;

  /// No description provided for @customerBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to customers'**
  String get customerBackToList;

  /// No description provided for @customerBiometricParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Key biometric parameters'**
  String get customerBiometricParamsTitle;

  /// No description provided for @customerRegisterNewMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Record new measurement'**
  String get customerRegisterNewMeasurement;

  /// No description provided for @customerJourneyStart.
  ///
  /// In en, this message translates to:
  /// **'Journey start'**
  String get customerJourneyStart;

  /// No description provided for @customerLastCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Last check-in'**
  String get customerLastCheckIn;

  /// No description provided for @customerIdChip.
  ///
  /// In en, this message translates to:
  /// **'ID: #{id}'**
  String customerIdChip(String id);

  /// No description provided for @customerAgeWithDob.
  ///
  /// In en, this message translates to:
  /// **'{age} years ({dob})'**
  String customerAgeWithDob(int age, String dob);

  /// No description provided for @customerOverviewNoMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet. Add one to track progress over time.'**
  String get customerOverviewNoMeasurements;

  /// No description provided for @customerOverviewLastMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Last measurement: {date}'**
  String customerOverviewLastMeasurement(String date);

  /// No description provided for @customerOverviewViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View measurement history'**
  String get customerOverviewViewHistory;

  /// No description provided for @customerOverviewFromProfile.
  ///
  /// In en, this message translates to:
  /// **'From profile'**
  String get customerOverviewFromProfile;

  /// No description provided for @customerOverviewProfileWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Weight from profile. Add a measurement to track changes over time.'**
  String get customerOverviewProfileWeightHint;

  /// No description provided for @customerOverviewNoSecondaryData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get customerOverviewNoSecondaryData;

  /// No description provided for @customerWorkoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout plans'**
  String get customerWorkoutPlans;

  /// No description provided for @customerViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get customerViewAll;

  /// No description provided for @customerNoWorkoutPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No workout plans yet'**
  String get customerNoWorkoutPlansYet;

  /// No description provided for @customerUnnamedPlan.
  ///
  /// In en, this message translates to:
  /// **'Unnamed plan'**
  String get customerUnnamedPlan;

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsTitle;

  /// No description provided for @workoutsNoWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get workoutsNoWorkoutsYet;

  /// No description provided for @workoutsAssignHint.
  ///
  /// In en, this message translates to:
  /// **'Assign a workout to this customer from the customer detail screen.'**
  String get workoutsAssignHint;

  /// No description provided for @customerWorkoutsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phase, or tag'**
  String get customerWorkoutsSearchHint;

  /// No description provided for @customerWorkoutsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get customerWorkoutsFilterAll;

  /// No description provided for @customerWorkoutsFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get customerWorkoutsFilterArchived;

  /// No description provided for @customerWorkoutsSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get customerWorkoutsSortTitle;

  /// No description provided for @customerWorkoutsSortStartDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Start date (newest)'**
  String get customerWorkoutsSortStartDateDesc;

  /// No description provided for @customerWorkoutsSortStartDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Start date (oldest)'**
  String get customerWorkoutsSortStartDateAsc;

  /// No description provided for @customerWorkoutsSortUpdatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Last updated (newest)'**
  String get customerWorkoutsSortUpdatedDesc;

  /// No description provided for @customerWorkoutsSortUpdatedAsc.
  ///
  /// In en, this message translates to:
  /// **'Last updated (oldest)'**
  String get customerWorkoutsSortUpdatedAsc;

  /// No description provided for @customerWorkoutsSortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get customerWorkoutsSortNameAsc;

  /// No description provided for @customerWorkoutsSortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get customerWorkoutsSortNameDesc;

  /// No description provided for @customerWorkoutsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No plans match the selected filters.'**
  String get customerWorkoutsNoMatch;

  /// No description provided for @workoutLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get workoutLibraryTitle;

  /// No description provided for @workoutDiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get workoutDiaryTitle;

  /// No description provided for @placeholderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get placeholderComingSoon;

  /// No description provided for @placeholderSectionNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'This section is not yet implemented.'**
  String get placeholderSectionNotImplemented;

  /// No description provided for @placeholderBackToBuilder.
  ///
  /// In en, this message translates to:
  /// **'Back to Builder'**
  String get placeholderBackToBuilder;

  /// No description provided for @customerDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Detail'**
  String get customerDetailTitle;

  /// No description provided for @actionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTitle;

  /// No description provided for @updatedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {count}d ago'**
  String updatedDaysAgo(int count);

  /// No description provided for @updatedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {count}h ago'**
  String updatedHoursAgo(int count);

  /// No description provided for @updatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {count}m ago'**
  String updatedMinutesAgo(int count);

  /// No description provided for @updatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get updatedJustNow;

  /// No description provided for @workoutDiaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No logged sessions yet. Mark a session complete from the schedule to start your diary.'**
  String get workoutDiaryEmpty;

  /// No description provided for @workoutDiaryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All clients'**
  String get workoutDiaryFilterAll;

  /// No description provided for @coachStatsPeriod7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get coachStatsPeriod7d;

  /// No description provided for @coachStatsPeriod30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get coachStatsPeriod30d;

  /// No description provided for @workoutDiaryFilterDate.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get workoutDiaryFilterDate;

  /// No description provided for @workoutDiaryFilterDateAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get workoutDiaryFilterDateAll;

  /// No description provided for @workoutDiaryFilterStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get workoutDiaryFilterStatusAll;

  /// No description provided for @workoutDiaryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Session detail'**
  String get workoutDiaryDetailTitle;

  /// No description provided for @workoutDiaryEntryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found or no longer available.'**
  String get workoutDiaryEntryNotFound;

  /// No description provided for @workoutDiaryOpenPlan.
  ///
  /// In en, this message translates to:
  /// **'Open workout plan'**
  String get workoutDiaryOpenPlan;

  /// No description provided for @workoutDiaryOpenSession.
  ///
  /// In en, this message translates to:
  /// **'Open in schedule'**
  String get workoutDiaryOpenSession;

  /// No description provided for @workoutDiaryNoExercisesLogged.
  ///
  /// In en, this message translates to:
  /// **'No exercises logged for this session.'**
  String get workoutDiaryNoExercisesLogged;

  /// No description provided for @sessionLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get sessionLogTitle;

  /// No description provided for @sessionLogNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Session notes (optional)'**
  String get sessionLogNotesHint;

  /// No description provided for @sessionLogSave.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get sessionLogSave;

  /// No description provided for @sessionLogExercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercises performed'**
  String get sessionLogExercisesLabel;

  /// No description provided for @sessionLogSetReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get sessionLogSetReps;

  /// No description provided for @sessionLogSetLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get sessionLogSetLoad;

  /// No description provided for @sessionLogAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get sessionLogAddSet;

  /// No description provided for @sessionLogSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String sessionLogSetLabel(int number);

  /// No description provided for @sessionLogExpandSets.
  ///
  /// In en, this message translates to:
  /// **'Show sets'**
  String get sessionLogExpandSets;

  /// No description provided for @sessionLogCollapseSets.
  ///
  /// In en, this message translates to:
  /// **'Hide sets'**
  String get sessionLogCollapseSets;

  /// No description provided for @customerProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Training progress'**
  String get customerProgressTitle;

  /// No description provided for @customerProgressAdherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence (30 days)'**
  String get customerProgressAdherence;

  /// No description provided for @customerProgressLastSession.
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get customerProgressLastSession;

  /// No description provided for @customerProgressRecentPrs.
  ///
  /// In en, this message translates to:
  /// **'Recent PRs'**
  String get customerProgressRecentPrs;

  /// No description provided for @customerProgressNoData.
  ///
  /// In en, this message translates to:
  /// **'No training data yet. Assign a plan and log sessions to see progress.'**
  String get customerProgressNoData;

  /// No description provided for @customerProgressNoSession.
  ///
  /// In en, this message translates to:
  /// **'No sessions logged'**
  String get customerProgressNoSession;

  /// No description provided for @customerProgressDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String customerProgressDaysAgo(int count);

  /// No description provided for @customerProgressToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get customerProgressToday;

  /// No description provided for @customerProgressYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get customerProgressYesterday;

  /// No description provided for @customerProgressLast4Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks'**
  String get customerProgressLast4Weeks;

  /// No description provided for @customerProgressThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get customerProgressThisWeek;

  /// No description provided for @customerProgressWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} wk ago'**
  String customerProgressWeeksAgo(int count);

  /// No description provided for @customerProgressExport.
  ///
  /// In en, this message translates to:
  /// **'Export progress'**
  String get customerProgressExport;

  /// No description provided for @customerProgressExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Progress exported'**
  String get customerProgressExportSuccess;

  /// No description provided for @customerProgressExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Progress export failed'**
  String get customerProgressExportFailed;

  /// No description provided for @customerProgressExportTitle.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach Studio'**
  String get customerProgressExportTitle;

  /// No description provided for @customerProgressExportGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get customerProgressExportGeneratedOn;

  /// No description provided for @customerProgressNarrativeSummary.
  ///
  /// In en, this message translates to:
  /// **'Over the last 30 days, adherence was {adherence} ({completed} completed, {skipped} skipped).'**
  String customerProgressNarrativeSummary(
    String adherence,
    int completed,
    int skipped,
  );

  /// No description provided for @customerProgressNarrativeLastSession.
  ///
  /// In en, this message translates to:
  /// **'Last session: {when}.'**
  String customerProgressNarrativeLastSession(String when);

  /// No description provided for @customerProgressNarrativeRecentPr.
  ///
  /// In en, this message translates to:
  /// **'Recent PR: {name} — {value} {unit}.'**
  String customerProgressNarrativeRecentPr(
    String name,
    String value,
    String unit,
  );

  /// No description provided for @customerProgressExportWeeklyCompleted.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get customerProgressExportWeeklyCompleted;

  /// No description provided for @customerProgressExportWeeklyMissed.
  ///
  /// In en, this message translates to:
  /// **'missed'**
  String get customerProgressExportWeeklyMissed;

  /// No description provided for @customerProgressExportWeeklyNoData.
  ///
  /// In en, this message translates to:
  /// **'no data'**
  String get customerProgressExportWeeklyNoData;

  /// No description provided for @customerProgressExportDataSection.
  ///
  /// In en, this message translates to:
  /// **'--- data ---'**
  String get customerProgressExportDataSection;

  /// No description provided for @customerProgressPrLine.
  ///
  /// In en, this message translates to:
  /// **'· {name} {value} {unit}'**
  String customerProgressPrLine(String name, String value, String unit);

  /// No description provided for @settingsCalendarRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Session reminders'**
  String get settingsCalendarRemindersTitle;

  /// No description provided for @settingsCalendarRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify before scheduled sessions'**
  String get settingsCalendarRemindersSubtitle;

  /// No description provided for @settingsCalendarReminderLead.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get settingsCalendarReminderLead;

  /// No description provided for @settingsCalendarReminderLeadHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours before'**
  String settingsCalendarReminderLeadHours(int hours);

  /// No description provided for @workoutFollowUpFromExecution.
  ///
  /// In en, this message translates to:
  /// **'Use loads from last execution'**
  String get workoutFollowUpFromExecution;

  /// No description provided for @workoutFollowUpFromExecutionHint.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} logged sessions'**
  String workoutFollowUpFromExecutionHint(int count);

  /// No description provided for @workoutFollowUpNoExecutionData.
  ///
  /// In en, this message translates to:
  /// **'No execution data — structure only will be copied.'**
  String get workoutFollowUpNoExecutionData;

  /// No description provided for @localDataQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Local data queue'**
  String get localDataQueueTitle;

  /// No description provided for @localDataQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pending local operations'**
  String get localDataQueueSubtitle;

  /// No description provided for @backupImportPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImportPreviewTitle;

  /// No description provided for @backupImportReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all local data'**
  String get backupImportReplaceAll;

  /// No description provided for @backupImportMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge by id (keep newer)'**
  String get backupImportMerge;

  /// No description provided for @backupImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get backupImportConfirm;

  /// No description provided for @backupImportCounts.
  ///
  /// In en, this message translates to:
  /// **'{customers} clients · {plans} plans · {executions} session logs'**
  String backupImportCounts(int customers, int plans, int executions);

  /// No description provided for @backupImportMetadata.
  ///
  /// In en, this message translates to:
  /// **'Backup from {date} · app {version}'**
  String backupImportMetadata(String date, String version);

  /// No description provided for @backupImportTypeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type IMPORT to confirm replacing all data'**
  String get backupImportTypeConfirm;

  /// No description provided for @backupImportTypeConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'IMPORT'**
  String get backupImportTypeConfirmHint;

  /// No description provided for @settingsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Profile'**
  String get settingsHubTitle;

  /// No description provided for @settingsHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage operational credentials, athlete channels, and offline-first policies.'**
  String get settingsHubSubtitle;

  /// No description provided for @settingsHubSyncPill.
  ///
  /// In en, this message translates to:
  /// **'Local data active'**
  String get settingsHubSyncPill;

  /// No description provided for @settingsNavPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get settingsNavPersonalInfo;

  /// No description provided for @settingsNavPdfBrand.
  ///
  /// In en, this message translates to:
  /// **'PDF brand'**
  String get settingsNavPdfBrand;

  /// No description provided for @settingsNavDataHealth.
  ///
  /// In en, this message translates to:
  /// **'Data health'**
  String get settingsNavDataHealth;

  /// No description provided for @settingsNavSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsNavSubscription;

  /// No description provided for @settingsNavNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Reminders'**
  String get settingsNavNotifications;

  /// No description provided for @settingsNavBackup.
  ///
  /// In en, this message translates to:
  /// **'Offline & Cloud backup'**
  String get settingsNavBackup;

  /// No description provided for @settingsNavLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language & format'**
  String get settingsNavLanguage;

  /// No description provided for @settingsNavPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsNavPrivacy;

  /// No description provided for @settingsNavTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsNavTerms;

  /// No description provided for @settingsProBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get settingsProBadge;

  /// No description provided for @settingsPersonalInfoCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Data & Bio'**
  String get settingsPersonalInfoCardTitle;

  /// No description provided for @settingsPersonalInfoCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visible to athletes'**
  String get settingsPersonalInfoCardSubtitle;

  /// No description provided for @settingsProfileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified profile'**
  String get settingsProfileVerified;

  /// No description provided for @settingsEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get settingsEmailVerified;

  /// No description provided for @settingsAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach profile photo'**
  String get settingsAvatarTitle;

  /// No description provided for @settingsAvatarHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an image URL (JPG, PNG, or WebP).'**
  String get settingsAvatarHint;

  /// No description provided for @settingsChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get settingsChangePhoto;

  /// No description provided for @settingsPhoneWhatsAppLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp contact'**
  String get settingsPhoneWhatsAppLabel;

  /// No description provided for @settingsBioCoachLabel.
  ///
  /// In en, this message translates to:
  /// **'Coach bio & philosophy'**
  String get settingsBioCoachLabel;

  /// No description provided for @settingsFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get settingsFullNameLabel;

  /// No description provided for @settingsOfficialEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Official email'**
  String get settingsOfficialEmailLabel;

  /// No description provided for @settingsUnsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes'**
  String get settingsUnsavedChanges;

  /// No description provided for @settingsCancelChanges.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancelChanges;

  /// No description provided for @settingsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSaveChanges;

  /// No description provided for @settingsNotificationsModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Reminders'**
  String get settingsNotificationsModuleTitle;

  /// No description provided for @settingsSessionRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Session notifications'**
  String get settingsSessionRemindersTitle;

  /// No description provided for @settingsSessionRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert before a scheduled workout'**
  String get settingsSessionRemindersSubtitle;

  /// No description provided for @settingsBackupModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Sync'**
  String get settingsBackupModuleTitle;

  /// No description provided for @settingsOfflineReadyPill.
  ///
  /// In en, this message translates to:
  /// **'Offline Ready'**
  String get settingsOfflineReadyPill;

  /// No description provided for @settingsBackupExportLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Export JSON backup (Local)'**
  String get settingsBackupExportLocalTitle;

  /// No description provided for @settingsBackupExportLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All athlete logs'**
  String get settingsBackupExportLocalSubtitle;

  /// No description provided for @settingsBackupDownloadAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get settingsBackupDownloadAction;

  /// No description provided for @settingsCloudSyncSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Sync snapshot to Supabase'**
  String get settingsCloudSyncSnapshot;

  /// No description provided for @workoutDiaryPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary & History'**
  String get workoutDiaryPageTitle;

  /// No description provided for @workoutDiaryPageBadge.
  ///
  /// In en, this message translates to:
  /// **'Live Session Log'**
  String get workoutDiaryPageBadge;

  /// No description provided for @workoutDiaryPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review session logs, monitor compliance, and check recorded training volume.'**
  String get workoutDiaryPageSubtitle;

  /// No description provided for @workoutDiaryLiveSync.
  ///
  /// In en, this message translates to:
  /// **'Local data active'**
  String get workoutDiaryLiveSync;

  /// No description provided for @workoutDiaryExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get workoutDiaryExportAction;

  /// No description provided for @workoutDiaryRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Log Session'**
  String get workoutDiaryRecordAction;

  /// No description provided for @workoutDiarySeeExerciseLog.
  ///
  /// In en, this message translates to:
  /// **'See Exercise Log'**
  String get workoutDiarySeeExerciseLog;

  /// No description provided for @workoutDiaryKpiSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workoutDiaryKpiSessions;

  /// No description provided for @workoutDiaryKpiVolume.
  ///
  /// In en, this message translates to:
  /// **'Load Volume'**
  String get workoutDiaryKpiVolume;

  /// No description provided for @workoutDiaryKpiVolumeUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get workoutDiaryKpiVolumeUnit;

  /// No description provided for @workoutDiaryKpiVolumeTonsUnit.
  ///
  /// In en, this message translates to:
  /// **'tons'**
  String get workoutDiaryKpiVolumeTonsUnit;

  /// No description provided for @workoutDiaryKpiCompliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get workoutDiaryKpiCompliance;

  /// No description provided for @workoutDiaryKpiSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String workoutDiaryKpiSkipped(int count);

  /// No description provided for @workoutDiaryFilterAthlete.
  ///
  /// In en, this message translates to:
  /// **'Filter athlete'**
  String get workoutDiaryFilterAthlete;

  /// No description provided for @workoutDiaryFilterStatusAllShort.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workoutDiaryFilterStatusAllShort;

  /// No description provided for @workoutDiaryShowingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} sessions'**
  String workoutDiaryShowingCount(int count);

  /// No description provided for @workoutDiaryExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String workoutDiaryExercisesCount(int count);

  /// No description provided for @workoutDiaryExercisesMetric.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get workoutDiaryExercisesMetric;

  /// No description provided for @workoutDiarySetsMetric.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workoutDiarySetsMetric;

  /// No description provided for @workoutDiaryVolumeMetric.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get workoutDiaryVolumeMetric;

  /// No description provided for @workoutDiarySetsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String workoutDiarySetsCount(int count);

  /// No description provided for @workoutDiaryVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume: {kg} kg'**
  String workoutDiaryVolumeLabel(String kg);

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarViewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarViewMonth;

  /// No description provided for @calendarViewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarViewWeek;

  /// No description provided for @calendarViewDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendarViewDay;

  /// No description provided for @calendarViewMonthShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get calendarViewMonthShort;

  /// No description provided for @calendarViewWeekShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get calendarViewWeekShort;

  /// No description provided for @calendarViewDayShort.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get calendarViewDayShort;

  /// No description provided for @calendarAddSession.
  ///
  /// In en, this message translates to:
  /// **'Add Session'**
  String get calendarAddSession;

  /// No description provided for @calendarAddSessionShort.
  ///
  /// In en, this message translates to:
  /// **'+ Session'**
  String get calendarAddSessionShort;

  /// No description provided for @calendarFilterAllAthletes.
  ///
  /// In en, this message translates to:
  /// **'All Athletes'**
  String get calendarFilterAllAthletes;

  /// No description provided for @calendarDaySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Day summary'**
  String get calendarDaySummaryTitle;

  /// No description provided for @calendarOpenSession.
  ///
  /// In en, this message translates to:
  /// **'Open Sheet'**
  String get calendarOpenSession;

  /// No description provided for @calendarLegendWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get calendarLegendWorkout;

  /// No description provided for @calendarLegendCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get calendarLegendCompleted;

  /// No description provided for @calendarLegendCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get calendarLegendCheckin;

  /// No description provided for @calendarSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sessions} one{{count} session} other{{count} sessions}}'**
  String calendarSessionsCount(int count);

  /// No description provided for @calendarStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get calendarStatusWaiting;

  /// No description provided for @calendarStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get calendarStatusScheduled;

  /// No description provided for @subscriptionPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Plans'**
  String get subscriptionPageTitle;

  /// No description provided for @subscriptionPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full analytical potential for your athletes with no lock-in.'**
  String get subscriptionPageSubtitle;

  /// No description provided for @subscriptionFreeLimitedBadge.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get subscriptionFreeLimitedBadge;

  /// No description provided for @subscriptionProActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro Plan'**
  String get subscriptionProActiveBadge;

  /// No description provided for @subscriptionPlanInUse.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get subscriptionPlanInUse;

  /// No description provided for @subscriptionFreeCoachLabel.
  ///
  /// In en, this message translates to:
  /// **'Free (Free Coach)'**
  String get subscriptionFreeCoachLabel;

  /// No description provided for @subscriptionUsageClients.
  ///
  /// In en, this message translates to:
  /// **'Active client usage'**
  String get subscriptionUsageClients;

  /// No description provided for @subscriptionUsageClientsCount.
  ///
  /// In en, this message translates to:
  /// **'{current} / {max} clients'**
  String subscriptionUsageClientsCount(int current, int max);

  /// No description provided for @subscriptionSlotsRemaining.
  ///
  /// In en, this message translates to:
  /// **'You still have {count} free athlete slots available.'**
  String subscriptionSlotsRemaining(int count);

  /// No description provided for @subscriptionLimitAtFive.
  ///
  /// In en, this message translates to:
  /// **'Limit reached at 5 clients'**
  String get subscriptionLimitAtFive;

  /// No description provided for @subscriptionRenewCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Renewal cost'**
  String get subscriptionRenewCostLabel;

  /// No description provided for @subscriptionRenewPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get subscriptionRenewPerMonth;

  /// No description provided for @subscriptionRenewPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get subscriptionRenewPerYear;

  /// No description provided for @subscriptionProExpiredBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro Expired'**
  String get subscriptionProExpiredBadge;

  /// No description provided for @subscriptionUpgradeHighlightTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Coach Pro'**
  String get subscriptionUpgradeHighlightTitle;

  /// No description provided for @subscriptionUpgradeHighlightBody.
  ///
  /// In en, this message translates to:
  /// **'Remove athlete caps and export workout sheets as PDF/Excel.'**
  String get subscriptionUpgradeHighlightBody;

  /// No description provided for @subscriptionUpgradeHighlightCta.
  ///
  /// In en, this message translates to:
  /// **'Activate Coach Pro Now'**
  String get subscriptionUpgradeHighlightCta;

  /// No description provided for @subscriptionRecommendedBadge.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get subscriptionRecommendedBadge;

  /// No description provided for @subscriptionBillingMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionBillingMonthly;

  /// No description provided for @subscriptionBillingYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly -20%'**
  String get subscriptionBillingYearly;

  /// No description provided for @subscriptionSavePercent.
  ///
  /// In en, this message translates to:
  /// **'Save 20%'**
  String get subscriptionSavePercent;

  /// No description provided for @subscriptionPriceMonthlyAmount.
  ///
  /// In en, this message translates to:
  /// **'€12'**
  String get subscriptionPriceMonthlyAmount;

  /// No description provided for @subscriptionPriceYearlyAmount.
  ///
  /// In en, this message translates to:
  /// **'€99'**
  String get subscriptionPriceYearlyAmount;

  /// No description provided for @subscriptionFeatureUnlimitedClients.
  ///
  /// In en, this message translates to:
  /// **'Unlimited clients & active plans'**
  String get subscriptionFeatureUnlimitedClients;

  /// No description provided for @subscriptionFeaturePdfLogo.
  ///
  /// In en, this message translates to:
  /// **'PDF export with logo'**
  String get subscriptionFeaturePdfLogo;

  /// No description provided for @subscriptionFeatureMetrics.
  ///
  /// In en, this message translates to:
  /// **'1RM, skinfolds'**
  String get subscriptionFeatureMetrics;

  /// No description provided for @subscriptionFeatureCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get subscriptionFeatureCloudSync;

  /// No description provided for @subscriptionCompareCustomersUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get subscriptionCompareCustomersUnlimited;

  /// No description provided for @subscriptionCompareFreeSummary.
  ///
  /// In en, this message translates to:
  /// **'5 athletes · basic metrics · 1 device'**
  String get subscriptionCompareFreeSummary;

  /// No description provided for @subscriptionCompareProPopular.
  ///
  /// In en, this message translates to:
  /// **'Coach Pro · Popular'**
  String get subscriptionCompareProPopular;

  /// No description provided for @subscriptionCompareProSummary.
  ///
  /// In en, this message translates to:
  /// **'Unlimited · PDF/CSV · multi-device'**
  String get subscriptionCompareProSummary;

  /// No description provided for @subscriptionCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PowerCoach Pro'**
  String get subscriptionCtaTitle;

  /// No description provided for @subscriptionCtaNoLock.
  ///
  /// In en, this message translates to:
  /// **'No lock-in: cancel anytime with one click'**
  String get subscriptionCtaNoLock;

  /// No description provided for @pdfBrandSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF brand kit'**
  String get pdfBrandSettingsTitle;

  /// No description provided for @pdfBrandSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize PDF export header, accent color, and disclaimer.'**
  String get pdfBrandSettingsSubtitle;

  /// No description provided for @pdfBrandStudioNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Studio name'**
  String get pdfBrandStudioNameLabel;

  /// No description provided for @pdfBrandStudioNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Force Studio Rome'**
  String get pdfBrandStudioNameHint;

  /// No description provided for @pdfBrandAccentLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get pdfBrandAccentLabel;

  /// No description provided for @pdfBrandAccentDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get pdfBrandAccentDefault;

  /// No description provided for @pdfBrandAccentHexHint.
  ///
  /// In en, this message translates to:
  /// **'#0D59F2'**
  String get pdfBrandAccentHexHint;

  /// No description provided for @pdfBrandDisclaimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Footer disclaimer'**
  String get pdfBrandDisclaimerLabel;

  /// No description provided for @pdfBrandDisclaimerHint.
  ///
  /// In en, this message translates to:
  /// **'Custom text shown in the PDF footer'**
  String get pdfBrandDisclaimerHint;

  /// No description provided for @pdfBrandWhiteLabelLabel.
  ///
  /// In en, this message translates to:
  /// **'Hide PowerCoach branding'**
  String get pdfBrandWhiteLabelLabel;

  /// No description provided for @pdfBrandWhiteLabelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes the default product name from header and disclaimer'**
  String get pdfBrandWhiteLabelSubtitle;

  /// No description provided for @pdfBrandLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF logo'**
  String get pdfBrandLogoLabel;

  /// No description provided for @pdfBrandLogoLocalHint.
  ///
  /// In en, this message translates to:
  /// **'The logo stays on this device and is not included in backups.'**
  String get pdfBrandLogoLocalHint;

  /// No description provided for @pdfBrandLogoPick.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get pdfBrandLogoPick;

  /// No description provided for @pdfBrandLogoReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace logo'**
  String get pdfBrandLogoReplace;

  /// No description provided for @pdfBrandLogoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get pdfBrandLogoRemove;

  /// No description provided for @pdfBrandLogoPickError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file'**
  String get pdfBrandLogoPickError;

  /// No description provided for @pdfBrandLogoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Logo too large (max about 1.5 MB; lower limit on web)'**
  String get pdfBrandLogoTooLarge;

  /// No description provided for @pdfBrandSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'PDF brand saved'**
  String get pdfBrandSavedMessage;

  /// No description provided for @pdfBrandSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save PDF brand'**
  String get pdfBrandSaveError;

  /// No description provided for @dataHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Data health'**
  String get dataHealthTitle;

  /// No description provided for @dataHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan local data for integrity issues. Safe repair clears orphan pin and recent exercise ids only.'**
  String get dataHealthSubtitle;

  /// No description provided for @dataHealthScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get dataHealthScanAction;

  /// No description provided for @dataHealthRescanAction.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get dataHealthRescanAction;

  /// No description provided for @dataHealthNoIssues.
  ///
  /// In en, this message translates to:
  /// **'No issues found'**
  String get dataHealthNoIssues;

  /// No description provided for @dataHealthFindingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} findings'**
  String dataHealthFindingsCount(int count);

  /// No description provided for @dataHealthClearOrphanPrefs.
  ///
  /// In en, this message translates to:
  /// **'Clear orphan pins & recents'**
  String get dataHealthClearOrphanPrefs;

  /// No description provided for @dataHealthClearOrphanPrefsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear orphan exercise ids?'**
  String get dataHealthClearOrphanPrefsConfirmTitle;

  /// No description provided for @dataHealthClearOrphanPrefsConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Removes orphan exercise ids from pinned and recent lists only. Workout plans and other entities are not deleted.'**
  String get dataHealthClearOrphanPrefsConfirmMessage;

  /// No description provided for @dataHealthClearedOrphansSnack.
  ///
  /// In en, this message translates to:
  /// **'Cleared {count} orphan exercise ids'**
  String dataHealthClearedOrphansSnack(int count);

  /// No description provided for @dataHealthScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not scan local data'**
  String get dataHealthScanFailed;

  /// No description provided for @dataHealthRepairFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear orphan pins and recents'**
  String get dataHealthRepairFailed;

  /// No description provided for @dataHealthNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to scan local data for this account.'**
  String get dataHealthNotSignedIn;

  /// No description provided for @dataHealthScannedMeta.
  ///
  /// In en, this message translates to:
  /// **'{count} entities · {timestamp}'**
  String dataHealthScannedMeta(int count, String timestamp);

  /// No description provided for @dataHealthSeverityError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get dataHealthSeverityError;

  /// No description provided for @dataHealthSeverityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get dataHealthSeverityWarning;

  /// No description provided for @dataHealthSeverityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get dataHealthSeverityInfo;

  /// No description provided for @customerPdfHeaderSection.
  ///
  /// In en, this message translates to:
  /// **'PDF header'**
  String get customerPdfHeaderSection;

  /// No description provided for @customerUseCustomPdfHeader.
  ///
  /// In en, this message translates to:
  /// **'Custom PDF header'**
  String get customerUseCustomPdfHeader;

  /// No description provided for @customerUseCustomPdfHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overrides the studio name for this client only'**
  String get customerUseCustomPdfHeaderSubtitle;

  /// No description provided for @customerPdfHeaderLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF header text'**
  String get customerPdfHeaderLabel;

  /// No description provided for @customerPdfHeaderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mario\'s plan — Alpha Studio'**
  String get customerPdfHeaderHint;

  /// No description provided for @analyticsConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics and session replay'**
  String get analyticsConsentTitle;

  /// No description provided for @analyticsConsentBody.
  ///
  /// In en, this message translates to:
  /// **'We use PostHog (EU) to understand how the web app is used and to improve it. Text and form inputs are masked. You can decline; the app still works.'**
  String get analyticsConsentBody;

  /// No description provided for @analyticsConsentAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get analyticsConsentAccept;

  /// No description provided for @analyticsConsentDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get analyticsConsentDecline;

  /// No description provided for @analyticsConsentPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get analyticsConsentPrivacyLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

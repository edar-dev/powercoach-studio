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
  /// **'Start free — No card required'**
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
  /// **'Create your first plan in 2 minutes'**
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
  /// **'Join the PowerCoach Studio beta. Manage athletes with modern tools, clean plans, and zero admin friction.'**
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
  /// **'Create your free coach account'**
  String get landingCtaCreateAccount;

  /// No description provided for @landingCtaFootnote.
  ///
  /// In en, this message translates to:
  /// **'No credit card required · Ready in 60 seconds'**
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
  /// **'Start free'**
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
  /// **'Start free with up to 5 clients. Upgrade to Pro as you grow.'**
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
  /// **'Create free account'**
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
  /// **'During the closed beta you can activate Pro for free with an invite code after signing up.'**
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
  /// **'Sign up for free, then open Subscription to request an invite code or redeem the one you receive.'**
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
  /// **'Don\'t have a coach account yet?'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up free'**
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

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile page coming soon.'**
  String get profileComingSoon;

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
  /// **'Request an invite code or enter one you received to unlock Pro.'**
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

  /// No description provided for @subscriptionPromoHint.
  ///
  /// In en, this message translates to:
  /// **'Have an invite code? Enter it below.'**
  String get subscriptionPromoHint;

  /// No description provided for @subscriptionPromoCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Pro with an invite'**
  String get subscriptionPromoCardTitle;

  /// No description provided for @subscriptionPromoCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'During early access, Pro is free with an invite code.'**
  String get subscriptionPromoCardSubtitle;

  /// No description provided for @subscriptionPromoCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get subscriptionPromoCodeLabel;

  /// No description provided for @subscriptionPromoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. POWERCOACH-2026'**
  String get subscriptionPromoCodeHint;

  /// No description provided for @subscriptionPromoCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter an invite code.'**
  String get subscriptionPromoCodeEmpty;

  /// No description provided for @subscriptionPromoRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'Activate Pro'**
  String get subscriptionPromoRedeemButton;

  /// No description provided for @subscriptionPromoRedeemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pro activated. Enjoy!'**
  String get subscriptionPromoRedeemSuccess;

  /// No description provided for @subscriptionPromoRedeemError.
  ///
  /// In en, this message translates to:
  /// **'Could not activate the code. Try again.'**
  String get subscriptionPromoRedeemError;

  /// No description provided for @subscriptionPromoAlreadyPro.
  ///
  /// In en, this message translates to:
  /// **'You already have Pro access.'**
  String get subscriptionPromoAlreadyPro;

  /// No description provided for @subscriptionPromoProActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Your Pro access is active via invite code.'**
  String get subscriptionPromoProActiveHint;

  /// No description provided for @subscriptionStatusPromoActive.
  ///
  /// In en, this message translates to:
  /// **'Pro (invite)'**
  String get subscriptionStatusPromoActive;

  /// No description provided for @subscriptionStatusPromoActiveDetail.
  ///
  /// In en, this message translates to:
  /// **'Pro access activated with an invite code.'**
  String get subscriptionStatusPromoActiveDetail;

  /// No description provided for @subscriptionCouponRequestIntro.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a code? You can request Pro access.'**
  String get subscriptionCouponRequestIntro;

  /// No description provided for @subscriptionCouponRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Request invite code'**
  String get subscriptionCouponRequestButton;

  /// No description provided for @subscriptionCouponRequestMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get subscriptionCouponRequestMessageLabel;

  /// No description provided for @subscriptionCouponRequestMessageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. how many clients you coach, how you use the app…'**
  String get subscriptionCouponRequestMessageHint;

  /// No description provided for @subscriptionCouponRequestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get subscriptionCouponRequestSubmit;

  /// No description provided for @subscriptionCouponRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent. We\'ll reply by email.'**
  String get subscriptionCouponRequestSuccess;

  /// No description provided for @subscriptionCouponRequestError.
  ///
  /// In en, this message translates to:
  /// **'Could not send the request. Try again.'**
  String get subscriptionCouponRequestError;

  /// No description provided for @subscriptionCouponRequestPending.
  ///
  /// In en, this message translates to:
  /// **'You already have a pending request. We\'ll reply by email.'**
  String get subscriptionCouponRequestPending;

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

  /// No description provided for @reminderPlatformNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Reminders are not supported on this platform.'**
  String get reminderPlatformNotSupported;

  /// No description provided for @reminderEnableNotificationsFirst.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications in Settings first.'**
  String get reminderEnableNotificationsFirst;

  /// No description provided for @reminderPastTimeError.
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future.'**
  String get reminderPastTimeError;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder saved.'**
  String get reminderSaved;

  /// No description provided for @reminderScheduleError.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule the reminder. Try again.'**
  String get reminderScheduleError;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {customerName}'**
  String reminderNotificationTitle(String customerName);

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Scheduled client reminder'**
  String get reminderNotificationBody;

  /// No description provided for @reminderDashboardSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session reminder'**
  String get reminderDashboardSessionTitle;

  /// No description provided for @customerReminderAction.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get customerReminderAction;

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
  /// **'Offline-First architecture · data saved locally on this device'**
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

  /// No description provided for @workoutExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get workoutExportJson;

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

  /// No description provided for @workoutPdfIncludeMobility.
  ///
  /// In en, this message translates to:
  /// **'Include mobility / warm-up'**
  String get workoutPdfIncludeMobility;

  /// No description provided for @workoutPdfSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the document layout. The PDF uses your coach header and print-friendly tables.'**
  String get workoutPdfSheetSubtitle;

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

  /// No description provided for @pdfCircuit.
  ///
  /// In en, this message translates to:
  /// **'Circuit'**
  String get pdfCircuit;

  /// No description provided for @pdfEmom.
  ///
  /// In en, this message translates to:
  /// **'EMOM'**
  String get pdfEmom;

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

  /// No description provided for @workoutPlanPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get workoutPlanPhaseLabel;

  /// No description provided for @workoutPlanPhaseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hypertrophy, Strength, Deload'**
  String get workoutPlanPhaseHint;

  /// No description provided for @workoutPlanTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get workoutPlanTagsLabel;

  /// No description provided for @workoutPlanTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. upper body, shoulder rehab'**
  String get workoutPlanTagsHint;

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
  /// **'Create new workout from this'**
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

  /// No description provided for @workoutPlanDiffCompareAction.
  ///
  /// In en, this message translates to:
  /// **'Compare with…'**
  String get workoutPlanDiffCompareAction;

  /// No description provided for @workoutPlanStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get workoutPlanStatusArchived;

  /// No description provided for @workoutPlanStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get workoutPlanStatusCompleted;

  /// No description provided for @workoutPlanStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get workoutPlanStatusActive;

  /// No description provided for @workoutPlanStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get workoutPlanStatusDraft;

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

  /// No description provided for @customerDetailRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get customerDetailRecords;

  /// No description provided for @recordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercise records yet.'**
  String get recordsEmpty;

  /// No description provided for @recordsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Log a value for a custom exercise (e.g. 1RM, reps) and add updates over time.'**
  String get recordsEmptyHint;

  /// No description provided for @recordAdd.
  ///
  /// In en, this message translates to:
  /// **'Add record'**
  String get recordAdd;

  /// No description provided for @recordAddUpdate.
  ///
  /// In en, this message translates to:
  /// **'Add update'**
  String get recordAddUpdate;

  /// No description provided for @recordValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get recordValue;

  /// No description provided for @recordUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get recordUnit;

  /// No description provided for @recordDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get recordDate;

  /// No description provided for @recordNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get recordNote;

  /// No description provided for @recordUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get recordUnitKg;

  /// No description provided for @recordUnitReps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get recordUnitReps;

  /// No description provided for @recordUnitSec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get recordUnitSec;

  /// No description provided for @recordUnitMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get recordUnitMin;

  /// No description provided for @recordUnitOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get recordUnitOther;

  /// No description provided for @recordDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get recordDeleteConfirm;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Record saved.'**
  String get recordSaved;

  /// No description provided for @recordSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save record.'**
  String get recordSaveError;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted.'**
  String get recordDeleted;

  /// No description provided for @recordDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete record.'**
  String get recordDeleteError;

  /// No description provided for @recordSelectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select exercise'**
  String get recordSelectExercise;

  /// No description provided for @recordSearchExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get recordSearchExerciseHint;

  /// No description provided for @recordDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get recordDeleteButton;

  /// No description provided for @workoutBuilderClientRecord.
  ///
  /// In en, this message translates to:
  /// **'Client record'**
  String get workoutBuilderClientRecord;

  /// No description provided for @workoutBuilderNoExerciseRecord.
  ///
  /// In en, this message translates to:
  /// **'No record for this exercise.'**
  String get workoutBuilderNoExerciseRecord;

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

  /// No description provided for @workoutBuilderMultiSetBlockHeader.
  ///
  /// In en, this message translates to:
  /// **'Sets (Set × Reps + Load)'**
  String get workoutBuilderMultiSetBlockHeader;

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

  /// No description provided for @workoutBuilderCircuitHeading.
  ///
  /// In en, this message translates to:
  /// **'CIRCUIT'**
  String get workoutBuilderCircuitHeading;

  /// No description provided for @workoutBuilderEmomHeading.
  ///
  /// In en, this message translates to:
  /// **'EMOM'**
  String get workoutBuilderEmomHeading;

  /// No description provided for @builderSupersetPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage superset'**
  String get builderSupersetPanelTitle;

  /// No description provided for @builderCircuitPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage circuit'**
  String get builderCircuitPanelTitle;

  /// No description provided for @builderEmomPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage EMOM'**
  String get builderEmomPanelTitle;

  /// No description provided for @builderSupersetAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise to superset'**
  String get builderSupersetAddExercise;

  /// No description provided for @builderDensityAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise to group'**
  String get builderDensityAddExercise;

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

  /// No description provided for @builderCircuitManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get builderCircuitManage;

  /// No description provided for @builderEmomManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get builderEmomManage;

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

  /// No description provided for @workoutBuilderNewCircuit.
  ///
  /// In en, this message translates to:
  /// **'New circuit'**
  String get workoutBuilderNewCircuit;

  /// No description provided for @workoutBuilderNewEmom.
  ///
  /// In en, this message translates to:
  /// **'New EMOM'**
  String get workoutBuilderNewEmom;

  /// No description provided for @workoutBuilderRemoveFromSuperset.
  ///
  /// In en, this message translates to:
  /// **'Remove from superset'**
  String get workoutBuilderRemoveFromSuperset;

  /// No description provided for @densityRoundsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get densityRoundsLabel;

  /// No description provided for @densityRestSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest (seconds)'**
  String get densityRestSecondsLabel;

  /// No description provided for @densityIntervalSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval (seconds)'**
  String get densityIntervalSecondsLabel;

  /// No description provided for @densityDurationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get densityDurationMinutesLabel;

  /// No description provided for @densityBlockTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get densityBlockTypeLabel;

  /// No description provided for @densityBlockTypeSuperset.
  ///
  /// In en, this message translates to:
  /// **'Superset'**
  String get densityBlockTypeSuperset;

  /// No description provided for @densityBlockTypeCircuit.
  ///
  /// In en, this message translates to:
  /// **'Circuit'**
  String get densityBlockTypeCircuit;

  /// No description provided for @densityBlockTypeEmom.
  ///
  /// In en, this message translates to:
  /// **'EMOM'**
  String get densityBlockTypeEmom;

  /// No description provided for @densityBlockSave.
  ///
  /// In en, this message translates to:
  /// **'Save density'**
  String get densityBlockSave;

  /// No description provided for @densityCircuitRounds.
  ///
  /// In en, this message translates to:
  /// **'{rounds} rounds'**
  String densityCircuitRounds(int rounds);

  /// No description provided for @densityCircuitRest.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s rest'**
  String densityCircuitRest(int seconds);

  /// No description provided for @densityEmomInterval.
  ///
  /// In en, this message translates to:
  /// **'EMOM {seconds}s'**
  String densityEmomInterval(int seconds);

  /// No description provided for @densityEmomDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String densityEmomDuration(int minutes);

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

  /// No description provided for @workoutBuilderNavStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get workoutBuilderNavStats;

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
  /// **'Save the plan to link it to this client. Until then, changes stay in memory only.'**
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

  /// No description provided for @customerNewWorkoutFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'From template library'**
  String get customerNewWorkoutFromTemplate;

  /// No description provided for @customerNewWorkoutFromTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Use a saved template'**
  String get customerNewWorkoutFromTemplateHint;

  /// No description provided for @customerNewWorkoutDuplicateExisting.
  ///
  /// In en, this message translates to:
  /// **'Duplicate existing plan'**
  String get customerNewWorkoutDuplicateExisting;

  /// No description provided for @customerNewWorkoutDuplicateExistingHint.
  ///
  /// In en, this message translates to:
  /// **'Copy one of this client\'s plans'**
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

  /// No description provided for @customerNewWorkoutGuided.
  ///
  /// In en, this message translates to:
  /// **'Guided setup'**
  String get customerNewWorkoutGuided;

  /// No description provided for @customerNewWorkoutGuidedHint.
  ///
  /// In en, this message translates to:
  /// **'Name, weeks, days, and a preset split'**
  String get customerNewWorkoutGuidedHint;

  /// No description provided for @workoutNewPlanWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Guided plan setup'**
  String get workoutNewPlanWizardTitle;

  /// No description provided for @workoutNewPlanWizardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get workoutNewPlanWizardBack;

  /// No description provided for @workoutNewPlanWizardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get workoutNewPlanWizardNext;

  /// No description provided for @workoutNewPlanWizardCreate.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get workoutNewPlanWizardCreate;

  /// No description provided for @workoutNewPlanWizardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the plan.'**
  String get workoutNewPlanWizardNameRequired;

  /// No description provided for @workoutNewPlanWizardNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan name'**
  String get workoutNewPlanWizardNameLabel;

  /// No description provided for @workoutNewPlanWizardStepNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should this plan be called?'**
  String get workoutNewPlanWizardStepNameTitle;

  /// No description provided for @workoutNewPlanWizardStepNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Summer hypertrophy, Pre-comp, Mesocycle 1…'**
  String get workoutNewPlanWizardStepNameHint;

  /// No description provided for @workoutNewPlanWizardStepWeeksTitle.
  ///
  /// In en, this message translates to:
  /// **'How many weeks?'**
  String get workoutNewPlanWizardStepWeeksTitle;

  /// No description provided for @workoutNewPlanWizardStepWeeksHint.
  ///
  /// In en, this message translates to:
  /// **'You can add or remove weeks later in the builder.'**
  String get workoutNewPlanWizardStepWeeksHint;

  /// No description provided for @workoutNewPlanWizardStepDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'How many days per week?'**
  String get workoutNewPlanWizardStepDaysTitle;

  /// No description provided for @workoutNewPlanWizardStepDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Choose how many training slots you want each week.'**
  String get workoutNewPlanWizardStepDaysHint;

  /// No description provided for @workoutNewPlanWizardStepPresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Which split template?'**
  String get workoutNewPlanWizardStepPresetTitle;

  /// No description provided for @workoutNewPlanWizardStepPresetHint.
  ///
  /// In en, this message translates to:
  /// **'We create empty named days you can rename anytime.'**
  String get workoutNewPlanWizardStepPresetHint;

  /// No description provided for @workoutNewPlanWizardPresetFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get workoutNewPlanWizardPresetFullBody;

  /// No description provided for @workoutNewPlanWizardPresetFullBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Day A/B/C… full-body sessions'**
  String get workoutNewPlanWizardPresetFullBodyHint;

  /// No description provided for @workoutNewPlanWizardPresetUpperLower.
  ///
  /// In en, this message translates to:
  /// **'Upper / Lower'**
  String get workoutNewPlanWizardPresetUpperLower;

  /// No description provided for @workoutNewPlanWizardPresetUpperLowerHint.
  ///
  /// In en, this message translates to:
  /// **'Alternate upper and lower days'**
  String get workoutNewPlanWizardPresetUpperLowerHint;

  /// No description provided for @workoutNewPlanWizardPresetPpl.
  ///
  /// In en, this message translates to:
  /// **'Push / Pull / Legs'**
  String get workoutNewPlanWizardPresetPpl;

  /// No description provided for @workoutNewPlanWizardPresetPplHint.
  ///
  /// In en, this message translates to:
  /// **'Push, pull, and legs rotation'**
  String get workoutNewPlanWizardPresetPplHint;

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

  /// No description provided for @workoutBuilderSandboxBanner.
  ///
  /// In en, this message translates to:
  /// **'Local draft — not assigned to a client'**
  String get workoutBuilderSandboxBanner;

  /// No description provided for @workoutBuilderSandboxBannerHint.
  ///
  /// In en, this message translates to:
  /// **'Assign to a client to use it in their program.'**
  String get workoutBuilderSandboxBannerHint;

  /// No description provided for @workoutBuilderAssignToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Assign to client'**
  String get workoutBuilderAssignToCustomer;

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

  /// No description provided for @workoutBuilderDayCoachingNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Coaching note'**
  String get workoutBuilderDayCoachingNoteTitle;

  /// No description provided for @workoutBuilderDayCoachingNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note for this day'**
  String get workoutBuilderDayCoachingNoteLabel;

  /// No description provided for @workoutBuilderDayCoachingNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. focus, cues, warmup instructions'**
  String get workoutBuilderDayCoachingNoteHint;

  /// No description provided for @workoutBuilderProgressionIncreaseLoad.
  ///
  /// In en, this message translates to:
  /// **'Suggestion: bump load to {value}'**
  String workoutBuilderProgressionIncreaseLoad(String value);

  /// No description provided for @workoutBuilderProgressionIncreaseLoadGeneric.
  ///
  /// In en, this message translates to:
  /// **'Suggestion: consider a small load bump'**
  String get workoutBuilderProgressionIncreaseLoadGeneric;

  /// No description provided for @workoutBuilderProgressionIncreaseReps.
  ///
  /// In en, this message translates to:
  /// **'Suggestion: aim for {value} reps'**
  String workoutBuilderProgressionIncreaseReps(String value);

  /// No description provided for @workoutBuilderProgressionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get workoutBuilderProgressionApply;

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

  /// No description provided for @workoutTemplateOpenPlanAction.
  ///
  /// In en, this message translates to:
  /// **'Open plan'**
  String get workoutTemplateOpenPlanAction;

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

  /// No description provided for @measurementSkinfolds.
  ///
  /// In en, this message translates to:
  /// **'Skinfolds (mm)'**
  String get measurementSkinfolds;

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

  /// No description provided for @measurementCircumferences.
  ///
  /// In en, this message translates to:
  /// **'Circumferences (cm)'**
  String get measurementCircumferences;

  /// No description provided for @measurementChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measurementChest;

  /// No description provided for @measurementWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measurementWaist;

  /// No description provided for @measurementArms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get measurementArms;

  /// No description provided for @measurementThighs.
  ///
  /// In en, this message translates to:
  /// **'Thighs'**
  String get measurementThighs;

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

  /// No description provided for @measurementHistoryCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Period comparison'**
  String get measurementHistoryCompareTitle;

  /// No description provided for @measurementHistoryCompareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days vs previous 30 days'**
  String get measurementHistoryCompareSubtitle;

  /// No description provided for @measurementHistoryCompareRecent.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get measurementHistoryCompareRecent;

  /// No description provided for @measurementHistoryComparePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous 30 days'**
  String get measurementHistoryComparePrevious;

  /// No description provided for @measurementHistoryCompareInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Add more measurements to compare periods.'**
  String get measurementHistoryCompareInsufficient;

  /// No description provided for @measurementHistoryCompareNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get measurementHistoryCompareNoData;

  /// No description provided for @measurementHistoryCompareDelta.
  ///
  /// In en, this message translates to:
  /// **'{metric} change: {delta}'**
  String measurementHistoryCompareDelta(String metric, String delta);

  /// No description provided for @measurementHistoryCompareSampleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} samples'**
  String measurementHistoryCompareSampleCount(int count);

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

  /// No description provided for @customerNotesAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get customerNotesAttachPhoto;

  /// No description provided for @customerNotesAttachSoon.
  ///
  /// In en, this message translates to:
  /// **'Photo attachments will arrive in a later update.'**
  String get customerNotesAttachSoon;

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
  /// **'Calendar'**
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

  /// No description provided for @dashboardReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get dashboardReminderTooltip;

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

  /// No description provided for @dashboardStatsAction.
  ///
  /// In en, this message translates to:
  /// **'Coach stats'**
  String get dashboardStatsAction;

  /// No description provided for @dashboardDiarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions (30d)'**
  String dashboardDiarySubtitle(int count);

  /// No description provided for @dashboardStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{percent}% adherence (7d)'**
  String dashboardStatsSubtitle(int percent);

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

  /// No description provided for @dashboardShortcutTemplates.
  ///
  /// In en, this message translates to:
  /// **'Plans & templates'**
  String get dashboardShortcutTemplates;

  /// No description provided for @dashboardShortcutTemplatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-made models'**
  String get dashboardShortcutTemplatesSubtitle;

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

  /// No description provided for @customerWorkoutsFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get customerWorkoutsFilterActive;

  /// No description provided for @customerWorkoutsFilterScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get customerWorkoutsFilterScheduled;

  /// No description provided for @customerWorkoutsFilterUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get customerWorkoutsFilterUnscheduled;

  /// No description provided for @customerWorkoutsFilterEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get customerWorkoutsFilterEnded;

  /// No description provided for @customerWorkoutsFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get customerWorkoutsFilterArchived;

  /// No description provided for @customerWorkoutsFilterStale.
  ///
  /// In en, this message translates to:
  /// **'Needs update'**
  String get customerWorkoutsFilterStale;

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

  /// No description provided for @workoutTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout templates'**
  String get workoutTemplatesTitle;

  /// No description provided for @workoutTemplatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates yet. Save a client plan as a template or create one here.'**
  String get workoutTemplatesEmpty;

  /// No description provided for @workoutTemplatesNew.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get workoutTemplatesNew;

  /// No description provided for @workoutTemplatesAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign to client'**
  String get workoutTemplatesAssign;

  /// No description provided for @workoutTemplatesDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate template'**
  String get workoutTemplatesDuplicate;

  /// No description provided for @workoutTemplatesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get workoutTemplatesEdit;

  /// No description provided for @workoutTemplatesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get workoutTemplatesDelete;

  /// No description provided for @workoutTemplatesAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a client'**
  String get workoutTemplatesAssignTitle;

  /// No description provided for @workoutTemplatesSaveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get workoutTemplatesSaveAsTemplate;

  /// No description provided for @workoutTemplatesSaveAsTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get workoutTemplatesSaveAsTemplateTitle;

  /// No description provided for @workoutTemplatesNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get workoutTemplatesNameHint;

  /// No description provided for @workoutTemplatesDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate template'**
  String get workoutTemplatesDuplicateTitle;

  /// No description provided for @workoutTemplatesDuplicateHint.
  ///
  /// In en, this message translates to:
  /// **'Name for the copy'**
  String get workoutTemplatesDuplicateHint;

  /// No description provided for @workoutTemplatesAssignedSnack.
  ///
  /// In en, this message translates to:
  /// **'Plan added to the client.'**
  String get workoutTemplatesAssignedSnack;

  /// No description provided for @workoutTemplatesDuplicateSnack.
  ///
  /// In en, this message translates to:
  /// **'Template created.'**
  String get workoutTemplatesDuplicateSnack;

  /// No description provided for @workoutTemplatesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get workoutTemplatesDeleteConfirmTitle;

  /// No description provided for @workoutTemplatesDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This template will be removed from this device.'**
  String get workoutTemplatesDeleteConfirmMessage;

  /// No description provided for @workoutTemplatesDrawerLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout templates'**
  String get workoutTemplatesDrawerLabel;

  /// No description provided for @workoutTemplatesCustomersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the client list. Try again.'**
  String get workoutTemplatesCustomersLoadError;

  /// No description provided for @workoutTemplatesSemanticList.
  ///
  /// In en, this message translates to:
  /// **'Workout templates list'**
  String get workoutTemplatesSemanticList;

  /// No description provided for @workoutTemplatesAssignSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get workoutTemplatesAssignSearchHint;

  /// No description provided for @workoutTemplatesAssignNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No customers match your search.'**
  String get workoutTemplatesAssignNoMatch;

  /// No description provided for @workoutTemplatesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phase, or tag'**
  String get workoutTemplatesSearchHint;

  /// No description provided for @workoutTemplatesSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort templates'**
  String get workoutTemplatesSortTitle;

  /// No description provided for @workoutTemplatesSortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get workoutTemplatesSortNameAsc;

  /// No description provided for @workoutTemplatesSortUpdatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get workoutTemplatesSortUpdatedDesc;

  /// No description provided for @workoutTemplatesSortWeekCountDesc.
  ///
  /// In en, this message translates to:
  /// **'Most weeks'**
  String get workoutTemplatesSortWeekCountDesc;

  /// No description provided for @workoutTemplatesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No templates match your search.'**
  String get workoutTemplatesNoMatch;

  /// No description provided for @workoutTemplatesPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Template preview'**
  String get workoutTemplatesPreviewTitle;

  /// No description provided for @workoutTemplatesPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No structure available for this template.'**
  String get workoutTemplatesPreviewEmpty;

  /// No description provided for @workoutTemplatesStructureSummary.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks · {days} days · {exercises} exercises'**
  String workoutTemplatesStructureSummary(int weeks, int days, int exercises);

  /// No description provided for @workoutTemplatesPreviewExercisesMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more exercises'**
  String workoutTemplatesPreviewExercisesMore(int count);

  /// No description provided for @workoutTemplatesAssignStartDate.
  ///
  /// In en, this message translates to:
  /// **'Optional start date'**
  String get workoutTemplatesAssignStartDate;

  /// No description provided for @workoutTemplatesAssignStartDateHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a start date'**
  String get workoutTemplatesAssignStartDateHint;

  /// No description provided for @workoutTemplatesAssignStartDateSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get workoutTemplatesAssignStartDateSkip;

  /// No description provided for @workoutDiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get workoutDiaryTitle;

  /// No description provided for @workoutStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get workoutStatsTitle;

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

  /// No description provided for @coachStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach stats'**
  String get coachStatsTitle;

  /// No description provided for @coachStatsAdherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get coachStatsAdherence;

  /// No description provided for @coachStatsCompletedSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions'**
  String get coachStatsCompletedSessions;

  /// No description provided for @coachStatsSkippedSessions.
  ///
  /// In en, this message translates to:
  /// **'Skipped sessions'**
  String get coachStatsSkippedSessions;

  /// No description provided for @coachStatsActiveClients.
  ///
  /// In en, this message translates to:
  /// **'Active clients'**
  String get coachStatsActiveClients;

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

  /// No description provided for @coachStatsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions by day'**
  String get coachStatsChartTitle;

  /// No description provided for @coachStatsChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed sessions in this period.'**
  String get coachStatsChartEmpty;

  /// No description provided for @coachStatsChartDaySummary.
  ///
  /// In en, this message translates to:
  /// **'{date}: {count} completed'**
  String coachStatsChartDaySummary(String date, int count);

  /// No description provided for @coachStatsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get coachStatsExportCsv;

  /// No description provided for @coachStatsExportCsvSubject.
  ///
  /// In en, this message translates to:
  /// **'PowerCoach coach stats'**
  String get coachStatsExportCsvSubject;

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

  /// No description provided for @sessionLogCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'How did it go? (optional)'**
  String get sessionLogCheckInTitle;

  /// No description provided for @sessionLogRpeLabel.
  ///
  /// In en, this message translates to:
  /// **'Session RPE (1-10)'**
  String get sessionLogRpeLabel;

  /// No description provided for @sessionLogPainLabel.
  ///
  /// In en, this message translates to:
  /// **'Pain level (0-10)'**
  String get sessionLogPainLabel;

  /// No description provided for @sessionLogPainLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Where? (optional)'**
  String get sessionLogPainLocationHint;

  /// No description provided for @sessionLogRpeChipLabel.
  ///
  /// In en, this message translates to:
  /// **'RPE {value}/10'**
  String sessionLogRpeChipLabel(int value);

  /// No description provided for @sessionLogPainChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Pain {value}/10'**
  String sessionLogPainChipLabel(int value);

  /// No description provided for @sessionLogPainChipLabelWithLocation.
  ///
  /// In en, this message translates to:
  /// **'Pain {value}/10 · {location}'**
  String sessionLogPainChipLabelWithLocation(int value, String location);

  /// No description provided for @gymModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym mode'**
  String get gymModeTitle;

  /// No description provided for @gymModeAction.
  ///
  /// In en, this message translates to:
  /// **'Open gym mode'**
  String get gymModeAction;

  /// No description provided for @gymModeEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'No sessions scheduled for today.'**
  String get gymModeEmptyToday;

  /// No description provided for @gymModeRunnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get gymModeRunnerTitle;

  /// No description provided for @gymModeCoachingNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Coaching note'**
  String get gymModeCoachingNoteLabel;

  /// No description provided for @gymModeSaveAndComplete.
  ///
  /// In en, this message translates to:
  /// **'Save & complete'**
  String get gymModeSaveAndComplete;

  /// No description provided for @gymModeSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get gymModeSaving;

  /// No description provided for @gymModeLogSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get gymModeLogSuccess;

  /// No description provided for @gymModeTimerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get gymModeTimerStart;

  /// No description provided for @gymModeTimerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get gymModeTimerReset;

  /// No description provided for @workoutPlanDiffTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan comparison'**
  String get workoutPlanDiffTitle;

  /// No description provided for @workoutPlanDiffPickPlanBTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan to compare'**
  String get workoutPlanDiffPickPlanBTitle;

  /// No description provided for @workoutPlanDiffPlanALabel.
  ///
  /// In en, this message translates to:
  /// **'Plan A (current)'**
  String get workoutPlanDiffPlanALabel;

  /// No description provided for @workoutPlanDiffPlanBLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan B'**
  String get workoutPlanDiffPlanBLabel;

  /// No description provided for @workoutPlanDiffChangePlanB.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get workoutPlanDiffChangePlanB;

  /// No description provided for @workoutPlanDiffNoOtherPlans.
  ///
  /// In en, this message translates to:
  /// **'No other plans for this customer yet.'**
  String get workoutPlanDiffNoOtherPlans;

  /// No description provided for @workoutPlanDiffEmpty.
  ///
  /// In en, this message translates to:
  /// **'No structural differences between these plans.'**
  String get workoutPlanDiffEmpty;

  /// No description provided for @workoutPlanDiffLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load these plans.'**
  String get workoutPlanDiffLoadError;

  /// No description provided for @workoutPlanDiffSummaryDaysAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} days added'**
  String workoutPlanDiffSummaryDaysAdded(int count);

  /// No description provided for @workoutPlanDiffSummaryDaysRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count} days removed'**
  String workoutPlanDiffSummaryDaysRemoved(int count);

  /// No description provided for @workoutPlanDiffSummaryDaysChanged.
  ///
  /// In en, this message translates to:
  /// **'{count} days changed'**
  String workoutPlanDiffSummaryDaysChanged(int count);

  /// No description provided for @workoutPlanDiffSummaryExercisesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises added'**
  String workoutPlanDiffSummaryExercisesAdded(int count);

  /// No description provided for @workoutPlanDiffSummaryExercisesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises removed'**
  String workoutPlanDiffSummaryExercisesRemoved(int count);

  /// No description provided for @workoutPlanDiffSummaryExercisesChanged.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises changed'**
  String workoutPlanDiffSummaryExercisesChanged(int count);

  /// No description provided for @workoutPlanDiffBadgeAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get workoutPlanDiffBadgeAdded;

  /// No description provided for @workoutPlanDiffBadgeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get workoutPlanDiffBadgeRemoved;

  /// No description provided for @workoutPlanDiffBadgeChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get workoutPlanDiffBadgeChanged;

  /// No description provided for @workoutPlanDiffCoachingNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Coaching note'**
  String get workoutPlanDiffCoachingNoteLabel;

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

  /// No description provided for @backupImportSelectGroups.
  ///
  /// In en, this message translates to:
  /// **'Choose what to import'**
  String get backupImportSelectGroups;

  /// No description provided for @backupImportPartialReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Deselected groups stay unchanged on this device.'**
  String get backupImportPartialReplaceHint;

  /// No description provided for @backupImportGroupCustomers.
  ///
  /// In en, this message translates to:
  /// **'Clients and related data ({count})'**
  String backupImportGroupCustomers(int count);

  /// No description provided for @backupImportGroupPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout plans ({count})'**
  String backupImportGroupPlans(int count);

  /// No description provided for @backupImportGroupExerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise library ({count})'**
  String backupImportGroupExerciseLibrary(int count);

  /// No description provided for @backupImportGroupReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders ({count})'**
  String backupImportGroupReminders(int count);

  /// No description provided for @backupImportGroupPreferences.
  ///
  /// In en, this message translates to:
  /// **'Profile and preferences'**
  String get backupImportGroupPreferences;

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

  /// No description provided for @releaseNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get releaseNotesTitle;

  /// No description provided for @releaseNotesInstalledVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed version: {version}'**
  String releaseNotesInstalledVersion(String version);

  /// No description provided for @releaseNotesSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String releaseNotesSettingsSubtitle(String version);

  /// No description provided for @releaseNotesHighlightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get releaseNotesHighlightsLabel;

  /// No description provided for @releaseNotesCurrentVersionBadge.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get releaseNotesCurrentVersionBadge;

  /// No description provided for @releaseNotesV1071.
  ///
  /// In en, this message translates to:
  /// **'Coach hub: Diary and Stats cards on the dashboard; overflow menu on the full schedule'**
  String get releaseNotesV1071;

  /// No description provided for @releaseNotesV1072.
  ///
  /// In en, this message translates to:
  /// **'From customer profile: open diary filtered by customer'**
  String get releaseNotesV1072;

  /// No description provided for @releaseNotesV1073.
  ///
  /// In en, this message translates to:
  /// **'CSV progress export (adherence, PRs, measurements) from customer overview'**
  String get releaseNotesV1073;

  /// No description provided for @releaseNotesV1074.
  ///
  /// In en, this message translates to:
  /// **'Dedicated superset panel in workout builder (compact preview + editor)'**
  String get releaseNotesV1074;

  /// No description provided for @releaseNotesV1075.
  ///
  /// In en, this message translates to:
  /// **'Richer session log: reps and load per set in the session sheet'**
  String get releaseNotesV1075;

  /// No description provided for @releaseNotesV1061.
  ///
  /// In en, this message translates to:
  /// **'Backup: selective restore by category + export metadata (export date, entity counts)'**
  String get releaseNotesV1061;

  /// No description provided for @releaseNotesV1062.
  ///
  /// In en, this message translates to:
  /// **'Workout diary v2: date/status filters, navigable session detail'**
  String get releaseNotesV1062;

  /// No description provided for @releaseNotesV1063.
  ///
  /// In en, this message translates to:
  /// **'Coach stats: daily adherence chart + KPI CSV export'**
  String get releaseNotesV1063;

  /// No description provided for @releaseNotesV1064.
  ///
  /// In en, this message translates to:
  /// **'Presentation-split builder improvements (exercise sheet, training tab)'**
  String get releaseNotesV1064;

  /// No description provided for @releaseNotesV1051.
  ///
  /// In en, this message translates to:
  /// **'Session execution model (completed / skipped / planned) persisted locally'**
  String get releaseNotesV1051;

  /// No description provided for @releaseNotesV1052.
  ///
  /// In en, this message translates to:
  /// **'Workout diary and coach stats (MVP)'**
  String get releaseNotesV1052;

  /// No description provided for @releaseNotesV1053.
  ///
  /// In en, this message translates to:
  /// **'Customer progress panel: 30-day adherence, recent PRs, 4-week strip'**
  String get releaseNotesV1053;

  /// No description provided for @releaseNotesV1054.
  ///
  /// In en, this message translates to:
  /// **'Session reminders linked to plan calendar'**
  String get releaseNotesV1054;

  /// No description provided for @releaseNotesV1055.
  ///
  /// In en, this message translates to:
  /// **'Customer follow-up based on real execution data'**
  String get releaseNotesV1055;

  /// No description provided for @releaseNotesV1041.
  ///
  /// In en, this message translates to:
  /// **'Customer overview with real measurement metrics (sparkline, 30-day trend)'**
  String get releaseNotesV1041;

  /// No description provided for @releaseNotesV1042.
  ///
  /// In en, this message translates to:
  /// **'Exercise picker: recents and favorites in library'**
  String get releaseNotesV1042;

  /// No description provided for @releaseNotesV1043.
  ///
  /// In en, this message translates to:
  /// **'Calendar session detail with real plan data'**
  String get releaseNotesV1043;

  /// No description provided for @releaseNotesV1044.
  ///
  /// In en, this message translates to:
  /// **'Single-occurrence session override (reschedule without changing the plan)'**
  String get releaseNotesV1044;

  /// No description provided for @releaseNotesV1045.
  ///
  /// In en, this message translates to:
  /// **'Plan lifecycle (draft, active, completed, archived)'**
  String get releaseNotesV1045;

  /// No description provided for @releaseNotesV1031.
  ///
  /// In en, this message translates to:
  /// **'Business data local-only (Drift); Supabase for authentication only'**
  String get releaseNotesV1031;

  /// No description provided for @releaseNotesV1032.
  ///
  /// In en, this message translates to:
  /// **'Removed obsolete cloud sync UX; tier 2/3 backfill tests'**
  String get releaseNotesV1032;

  /// No description provided for @releaseNotesV1033.
  ///
  /// In en, this message translates to:
  /// **'Local prefs and coach profile repositories'**
  String get releaseNotesV1033;

  /// No description provided for @releaseNotesV1034.
  ///
  /// In en, this message translates to:
  /// **'Modular offline store migration'**
  String get releaseNotesV1034;

  /// No description provided for @releaseNotesV1021.
  ///
  /// In en, this message translates to:
  /// **'Workout plan template library'**
  String get releaseNotesV1021;

  /// No description provided for @releaseNotesV1022.
  ///
  /// In en, this message translates to:
  /// **'Plan editor autosave + unsaved exit guard'**
  String get releaseNotesV1022;

  /// No description provided for @releaseNotesV1023.
  ///
  /// In en, this message translates to:
  /// **'Plan export PDF / JSON / Excel'**
  String get releaseNotesV1023;

  /// No description provided for @releaseNotesV1011.
  ///
  /// In en, this message translates to:
  /// **'Today dashboard and session schedule'**
  String get releaseNotesV1011;

  /// No description provided for @releaseNotesV1012.
  ///
  /// In en, this message translates to:
  /// **'Customer management, measurements, exercise records'**
  String get releaseNotesV1012;

  /// No description provided for @releaseNotesV1013.
  ///
  /// In en, this message translates to:
  /// **'Workout builder (weeks/days/exercises, basic supersets)'**
  String get releaseNotesV1013;

  /// No description provided for @releaseNotesV1014.
  ///
  /// In en, this message translates to:
  /// **'Coach calendar and plan assignment'**
  String get releaseNotesV1014;

  /// No description provided for @releaseNotesV1015.
  ///
  /// In en, this message translates to:
  /// **'Local notifications and reminders'**
  String get releaseNotesV1015;

  /// No description provided for @releaseNotesV1016.
  ///
  /// In en, this message translates to:
  /// **'End-to-end IT/EN localization'**
  String get releaseNotesV1016;

  /// No description provided for @releaseNotesV1017.
  ///
  /// In en, this message translates to:
  /// **'Account JSON backup export/import'**
  String get releaseNotesV1017;
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

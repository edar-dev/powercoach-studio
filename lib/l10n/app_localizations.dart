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
  /// **'The Future of Coaching is Here'**
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
  /// **'Create and manage workout plans for your clients.'**
  String get landingSubtitle;

  /// No description provided for @landingCtaPrimary.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get landingCtaPrimary;

  /// No description provided for @landingCtaSecondary.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get landingCtaSecondary;

  /// No description provided for @notImplementedMessage.
  ///
  /// In en, this message translates to:
  /// **'Feature not yet implemented.'**
  String get notImplementedMessage;

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
  /// **'Focus on what you do best—coaching. We\'ll handle the logistics and tracking with precision tools.'**
  String get landingFeaturesDesc;

  /// No description provided for @landingFeaturesCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customer management'**
  String get landingFeaturesCustomers;

  /// No description provided for @landingFeaturesEditor.
  ///
  /// In en, this message translates to:
  /// **'Visual editor for workout plans'**
  String get landingFeaturesEditor;

  /// No description provided for @landingFeaturesClientData.
  ///
  /// In en, this message translates to:
  /// **'Client data & library'**
  String get landingFeaturesClientData;

  /// No description provided for @landingFeaturesExport.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get landingFeaturesExport;

  /// No description provided for @landingHowItWorksLabel.
  ///
  /// In en, this message translates to:
  /// **'The Process'**
  String get landingHowItWorksLabel;

  /// No description provided for @landingHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How PowerCoach Studio Works'**
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

  /// No description provided for @landingCtaSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Transform Your Coaching?'**
  String get landingCtaSectionTitle;

  /// No description provided for @landingCtaSectionSubtext.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get started.'**
  String get landingCtaSectionSubtext;

  /// No description provided for @landingCtaSectionButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingCtaSectionButton;

  /// No description provided for @landingCtaSectionSubtextLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Go to your profile to get started.'**
  String get landingCtaSectionSubtextLoggedIn;

  /// No description provided for @landingCtaSectionButtonLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get landingCtaSectionButtonLoggedIn;

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
  /// **'Email'**
  String get registrationEmail;

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
  /// **'Sign up'**
  String get registrationSubmit;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account.'**
  String get registrationSuccessMessage;

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

  /// No description provided for @registrationAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registrationAlreadyHaveAccount;

  /// No description provided for @registrationLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get registrationLoginLink;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginRegisterLink;

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

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

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get settingsNotificationsDescription;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageDescription;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @customersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get customersEmptyTitle;

  /// No description provided for @customersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Let\'s grow your studio! Start by adding your first client to track their progress and manage their workouts.'**
  String get customersEmptyMessage;

  /// No description provided for @customersAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get customersAddCustomer;

  /// No description provided for @customersAddFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Client'**
  String get customersAddFirstClient;

  /// No description provided for @customersImportContacts.
  ///
  /// In en, this message translates to:
  /// **'Import from contacts'**
  String get customersImportContacts;

  /// No description provided for @customersNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get customersNewCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customerName;

  /// No description provided for @customerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get customerNameRequired;

  /// No description provided for @customerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get customerEmail;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customerPhone;

  /// No description provided for @customerDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get customerDateOfBirth;

  /// No description provided for @customerHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get customerHeight;

  /// No description provided for @customerWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get customerWeight;

  /// No description provided for @customerNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get customerNotes;

  /// No description provided for @customerGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get customerGoals;

  /// No description provided for @customerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get customerSave;

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

  /// No description provided for @customersApiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'API not configured. Set GYMBLOG_API_URL in .env.'**
  String get customersApiNotConfigured;

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

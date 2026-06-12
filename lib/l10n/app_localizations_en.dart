// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PowerCoach Studio';

  @override
  String get landingHeroBadge => 'The Future of Coaching is Here';

  @override
  String get landingTitlePrefix => 'Power';

  @override
  String get landingTitleSuffix => 'Coach Studio';

  @override
  String get landingSubtitle =>
      'Create and manage workout plans for your clients.';

  @override
  String get landingCtaPrimary => 'Get Started';

  @override
  String get landingCtaSecondary => 'Learn More';

  @override
  String get notImplementedMessage => 'Feature not yet implemented.';

  @override
  String get landingFeaturesTitle => 'Premium Features';

  @override
  String get landingFeaturesHeadline => 'Everything you need to scale.';

  @override
  String get landingFeaturesDesc =>
      'Focus on what you do best—coaching. We\'ll handle the logistics and tracking with precision tools.';

  @override
  String get landingFeaturesCustomers => 'Customer management';

  @override
  String get landingFeaturesEditor => 'Visual editor for workout plans';

  @override
  String get landingFeaturesClientData => 'Client data & library';

  @override
  String get landingFeaturesExport => 'Export to PDF';

  @override
  String get landingHowItWorksLabel => 'The Process';

  @override
  String get landingHowItWorksTitle => 'How PowerCoach Studio Works';

  @override
  String get landingHowItWorksStep1 => 'Create a customer profile';

  @override
  String get landingHowItWorksStep2 => 'Create workout plans';

  @override
  String get landingHowItWorksStep3 => 'Add exercises, sets, and reps';

  @override
  String get landingHowItWorksStep4 => 'Export to PDF';

  @override
  String get landingCtaSectionTitle => 'Ready to Transform Your Coaching?';

  @override
  String get landingCtaSectionSubtext => 'Sign in to get started.';

  @override
  String get landingCtaSectionButton => 'Sign in';

  @override
  String get landingCtaSectionSubtextLoggedIn =>
      'Go to your profile to get started.';

  @override
  String get landingCtaSectionButtonLoggedIn => 'Profile';

  @override
  String get headerLogin => 'Login';

  @override
  String get headerJoinNow => 'Join now';

  @override
  String get registrationTitle => 'Sign up';

  @override
  String get registrationEmail => 'Email';

  @override
  String get registrationPassword => 'Password';

  @override
  String get registrationConfirmPassword => 'Confirm password';

  @override
  String get registrationSubmit => 'Sign up';

  @override
  String get registrationSuccessMessage =>
      'Check your email to confirm your account.';

  @override
  String get registrationErrorInvalidEmail => 'Please enter a valid email.';

  @override
  String get registrationErrorPasswordMismatch => 'Passwords do not match.';

  @override
  String get registrationErrorPasswordEmpty => 'Please enter a password.';

  @override
  String get registrationErrorGeneric =>
      'Registration failed. Please try again.';

  @override
  String get registrationAlreadyHaveAccount => 'Already have an account?';

  @override
  String get registrationLoginLink => 'Log in';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginRegisterLink => 'Sign up';

  @override
  String get loginErrorInvalidEmail => 'Please enter a valid email.';

  @override
  String get loginErrorPasswordEmpty => 'Please enter your password.';

  @override
  String get loginErrorGeneric => 'Login failed. Please try again.';

  @override
  String get loginErrorInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Please confirm your email before signing in.';

  @override
  String get loginErrorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get loginSuccessMessage => 'Welcome back!';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordInstruction =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordEmailLabel => 'Email';

  @override
  String get forgotPasswordSubmit => 'Send reset link';

  @override
  String get forgotPasswordSuccessMessage =>
      'Check your email for the reset link.';

  @override
  String get forgotPasswordBackToLogin => 'Back to login';

  @override
  String get forgotPasswordError => 'Could not send reset email. Try again.';

  @override
  String get headerProfile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileComingSoon => 'Profile page coming soon.';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileBio => 'Bio';

  @override
  String get profileAvatarUrl => 'Avatar URL';

  @override
  String get profileWebsite => 'Website';

  @override
  String get profileSave => 'Save';

  @override
  String get profileSavedMessage => 'Profile saved.';

  @override
  String get profileLoadError => 'Could not load profile.';

  @override
  String get profileSaveError => 'Could not save profile.';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPersonalInfo => 'Personal info';

  @override
  String get settingsSubscription => 'Subscription';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsPersonalInfoTitle => 'Personal info';

  @override
  String get settingsSubscriptionTitle => 'Subscription';

  @override
  String get subscriptionCurrentPlan => 'Current plan';

  @override
  String get subscriptionPlanFree => 'Free';

  @override
  String get subscriptionPlanPro => 'Pro';

  @override
  String get subscriptionUpgrade => 'Upgrade';

  @override
  String get subscriptionManage => 'Manage subscription';

  @override
  String get settingsNotificationsDescription =>
      'Local reminders for sessions and clients';

  @override
  String get settingsNotificationPermissionDenied =>
      'Notifications are disabled. Enable them in system settings to turn this on.';

  @override
  String get reminderWebNotSupported =>
      'Reminders are not supported in the web version of the app.';

  @override
  String get reminderPlatformNotSupported =>
      'Reminders are not supported on this platform.';

  @override
  String get reminderEnableNotificationsFirst =>
      'Turn on notifications in Settings first.';

  @override
  String get reminderPastTimeError => 'Choose a time in the future.';

  @override
  String get reminderSaved => 'Reminder saved.';

  @override
  String get reminderScheduleError =>
      'Could not schedule the reminder. Try again.';

  @override
  String reminderNotificationTitle(String customerName) {
    return 'Reminder: $customerName';
  }

  @override
  String get reminderNotificationBody => 'Scheduled client reminder';

  @override
  String get reminderDashboardSessionTitle => 'Session reminder';

  @override
  String get customerReminderAction => 'Set reminder';

  @override
  String get settingsLanguageDescription => 'App language';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSaved => 'Language updated.';

  @override
  String get settingsBackupSectionTitle => 'Offline backup';

  @override
  String get settingsBackupSectionSubtitle =>
      'Export or replace all local cached data for this account as JSON. Does not replace server data until you sync.';

  @override
  String get settingsBackupExport => 'Export backup';

  @override
  String get settingsBackupImport => 'Import backup';

  @override
  String get settingsBackupImportConfirmTitle => 'Replace local data?';

  @override
  String get settingsBackupImportConfirmMessage =>
      'This deletes all offline data for your account on this device and replaces it with the backup file. Server data is unchanged until sync. The file must belong to this signed-in account.';

  @override
  String get settingsBackupImportConfirmReplace => 'Replace local data';

  @override
  String get settingsBackupExportSuccess => 'Backup ready to share.';

  @override
  String get settingsBackupImportSuccess => 'Local data restored from backup.';

  @override
  String get settingsBackupErrorGeneric => 'Something went wrong. Try again.';

  @override
  String get settingsBackupErrorNotSignedIn =>
      'Sign in to export or import a backup.';

  @override
  String get settingsBackupErrorWrongAccount =>
      'This backup belongs to another account.';

  @override
  String get settingsBackupErrorUnsupportedSchema =>
      'This backup format is not supported by this app version.';

  @override
  String get settingsBackupErrorInvalidFile => 'Invalid backup file.';

  @override
  String get customersTitle => 'Customers';

  @override
  String get exerciseLibraryTitle => 'Exercise library';

  @override
  String get exerciseLibraryBack => 'Back';

  @override
  String get exerciseLibraryImport => 'Import';

  @override
  String get exerciseLibraryExport => 'Export';

  @override
  String get exerciseLibraryImportSourceTitle => 'Import exercises';

  @override
  String get exerciseLibraryImportSourceDefault => 'Import default catalog';

  @override
  String get exerciseLibraryImportSourceDefaultSubtitle =>
      'Load 200 common exercises with variants and hierarchy.';

  @override
  String get exerciseLibraryImportSourceCustom => 'Import custom JSON';

  @override
  String get exerciseLibraryImportSourceCustomSubtitle =>
      'Load exercises from your own JSON file.';

  @override
  String get exerciseLibraryAddExercise => 'Add exercise';

  @override
  String get exerciseLibraryEditExercise => 'Edit exercise';

  @override
  String get exerciseLibraryEdit => 'Edit';

  @override
  String get exerciseLibraryDelete => 'Delete';

  @override
  String get exerciseLibraryCancel => 'Cancel';

  @override
  String get exerciseLibrarySave => 'Save';

  @override
  String get exerciseLibraryRetry => 'Retry';

  @override
  String get exerciseLibraryEmpty => 'No custom exercises yet.';

  @override
  String get exerciseLibraryEmptyHint =>
      'Add exercises and variants (e.g. Squat → Squat low bar) to use them in plans.';

  @override
  String get exerciseLibraryTabExercises => 'Exercises';

  @override
  String get exerciseLibraryTabMobilityExercises => 'Mobility exercises';

  @override
  String get exerciseLibraryEmptyMobility => 'No mobility exercises yet.';

  @override
  String get exerciseLibraryEmptyMobilityHint =>
      'Add mobility exercises to use them in mobility routines.';

  @override
  String get exerciseLibraryExportEmpty =>
      'Nothing to export. Add exercises first.';

  @override
  String get exerciseLibraryImportInvalidFormat =>
      'Invalid file. Use a JSON array of exercises.';

  @override
  String get exerciseLibraryImportSuccess => 'Import completed successfully.';

  @override
  String exerciseLibraryImportSuccessCount(int count) {
    return 'Import completed: $count items.';
  }

  @override
  String get exerciseLibraryDeleteTitle => 'Delete exercise';

  @override
  String exerciseLibraryDeleteConfirm(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get exerciseLibraryDeleteHasChildren =>
      'Remove child exercises (variants) first, then delete this one.';

  @override
  String get exerciseLibraryNameHint => 'Exercise name';

  @override
  String get exerciseLibraryDescriptionHint => 'Description (optional)';

  @override
  String get exerciseLibraryMobilityToggle => 'Mobility exercise';

  @override
  String get exerciseLibraryParentLabel => 'Parent exercise (variant of)';

  @override
  String get exerciseLibraryParentNone => 'None';

  @override
  String get exerciseLibraryAddVariant => 'Add variant';

  @override
  String get placeholderBackToDashboard => 'Back to Dashboard';

  @override
  String get customersEmptyTitle => 'No clients yet';

  @override
  String get customersEmptyMessage =>
      'Let\'s grow your studio! Start by adding your first client to track their progress and manage their workouts.';

  @override
  String get customersAddCustomer => 'Add customer';

  @override
  String get customersAddFirstClient => 'Add Your First Client';

  @override
  String get customersImportContacts => 'Import from contacts';

  @override
  String get customersImportContactsDenied =>
      'Contacts permission is required to import.';

  @override
  String get customersNewCustomer => 'New customer';

  @override
  String get customerName => 'Name';

  @override
  String get customerNameRequired => 'Name is required';

  @override
  String get customerEmail => 'Email';

  @override
  String get customerPhone => 'Phone';

  @override
  String get customerDateOfBirth => 'Date of birth';

  @override
  String get customerHeight => 'Height (cm)';

  @override
  String get customerWeight => 'Weight (kg)';

  @override
  String get customerNotes => 'Notes';

  @override
  String get customerGoals => 'Goals';

  @override
  String get customerSave => 'Save';

  @override
  String get customerCancel => 'Cancel';

  @override
  String get customerEdit => 'Edit';

  @override
  String get customerDelete => 'Delete';

  @override
  String get customerDeleteConfirmTitle => 'Delete customer?';

  @override
  String get customerDeleteConfirmMessage => 'This action cannot be undone.';

  @override
  String get customersLoadError => 'Could not load customers.';

  @override
  String get customerSaveError => 'Could not save customer.';

  @override
  String get customerDeleteError => 'Could not delete customer.';

  @override
  String get customersApiNotConfigured =>
      'API not configured. Set GYMBLOG_API_URL in .env.';

  @override
  String get customersSessionExpired => 'Session expired. Please log in again.';

  @override
  String get customersRetry => 'Retry';

  @override
  String get customerDeletedMessage => 'Customer deleted.';

  @override
  String get workoutExport => 'Export';

  @override
  String get workoutExportPdf => 'Export to PDF';

  @override
  String get workoutExportExcel => 'Export to Excel';

  @override
  String get workoutExportJson => 'Export JSON';

  @override
  String get workoutImportJson => 'Import JSON';

  @override
  String get workoutImportJsonSuccess => 'Workout imported from JSON file.';

  @override
  String get workoutImportJsonError => 'Invalid or unsupported JSON file.';

  @override
  String get workoutExportSuccess => 'Download started.';

  @override
  String get workoutExportError => 'Export failed. Try again.';

  @override
  String get workoutExportPdfSheetTitle => 'Export PDF';

  @override
  String get workoutPdfLayoutCanonical => 'Full (by week)';

  @override
  String get workoutPdfLayoutDense => 'Dense (recommended)';

  @override
  String get workoutPdfLayoutDenseDescription =>
      'Compact day layout with week columns, fewer pages, and single-line prescriptions.';

  @override
  String get workoutExportPdfGenerateAndDownload => 'Generate and download';

  @override
  String get workoutPdfIncludeMobility => 'Include mobility / warm-up';

  @override
  String get workoutPdfSheetSubtitle =>
      'Choose the document layout. The PDF uses your coach header and print-friendly tables.';

  @override
  String get pdfBrandName => 'PowerCoach Studio';

  @override
  String get pdfCoachPrefix => 'Coach:';

  @override
  String get pdfColExercise => 'Exercise';

  @override
  String get pdfColSets => 'Sets';

  @override
  String get pdfColReps => 'Reps';

  @override
  String get pdfColLoadRpe => 'Load/RPE';

  @override
  String get pdfColNotes => 'Notes';

  @override
  String get pdfMobilitySection => 'Mobility';

  @override
  String get pdfSuperset => 'Superset';

  @override
  String pdfDayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get pdfEmptyValue => '-';

  @override
  String get pdfFooterDisclaimer =>
      'This document is intended for the designated client only. Please consult a physician before beginning any new exercise program.';

  @override
  String pdfPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String pdfGeneratedOn(String date) {
    return 'Generated on $date';
  }

  @override
  String get pdfExportGenerating => 'Generating PDF…';

  @override
  String pdfMeasurementRecordCount(int count) {
    return '$count records';
  }

  @override
  String pdfDenseWeekShort(int n) {
    return 'W$n';
  }

  @override
  String get pdfDenseAllWeeks => 'all';

  @override
  String get pdfDenseDitto => '\"';

  @override
  String pdfDenseWeekLegendEntry(int n, String name) {
    return 'W$n = $name';
  }

  @override
  String pdfDenseWeeksSpan(int first, int last) {
    return 'W$first-W$last';
  }

  @override
  String get pdfDenseLegend => 'W1-W4 = all weeks | \" = same prescription';

  @override
  String pdfClientPlanFor(String name) {
    return 'Plan for: $name';
  }

  @override
  String pdfPlanPeriod(String start, String end) {
    return '$start - $end';
  }

  @override
  String pdfPlanPeriodOpen(String start) {
    return 'From $start';
  }

  @override
  String get workoutExerciseShortNameLabel => 'PDF name (optional)';

  @override
  String get workoutExerciseScopeAllWeeks => 'Same prescription every week';

  @override
  String get mobilityShortTitleLabel => 'Short PDF title (optional)';

  @override
  String get mobilitySectionScheduleHintLabel => 'Schedule / timing (optional)';

  @override
  String get workoutShare => 'Share';

  @override
  String get workoutStartingWeek => 'Starting week';

  @override
  String get workoutStartingWeekHint => 'Week 1, 2, 3...';

  @override
  String get workoutRoutineStartDate => 'Start date';

  @override
  String get workoutRoutineStartDatePlaceholder => 'Tap to choose';

  @override
  String get workoutCreateNewFromThis => 'Create new workout from this';

  @override
  String workoutDuplicateOf(Object name) {
    return 'Copy of $name';
  }

  @override
  String get workoutDuplicatedMessage => 'Workout created.';

  @override
  String get workoutNewPlanName => 'New workout';

  @override
  String get workoutDelete => 'Delete workout';

  @override
  String get workoutDeleteConfirmTitle => 'Delete workout?';

  @override
  String get workoutDeleteConfirmMessage => 'This action cannot be undone.';

  @override
  String get workoutDeletedMessage => 'Workout deleted.';

  @override
  String get workoutDeleteError => 'Could not delete workout.';

  @override
  String get mobilityAddExercise => 'Add mobility exercise';

  @override
  String get mobilityCreateNew => 'Create new';

  @override
  String get mobilityFromMobilityLibrary => 'From mobility library';

  @override
  String get mobilityFromExerciseLibrary => 'From exercise library';

  @override
  String get mobilitySaveToLibrary => 'Save to mobility library';

  @override
  String get mobilityTitle => 'Title';

  @override
  String get mobilitySubtitle => 'Subtitle';

  @override
  String get customerDetailOverview => 'Overview';

  @override
  String get customerDetailMeasurements => 'Measurements';

  @override
  String get customerDetailRecords => 'Records';

  @override
  String get recordsEmpty => 'No exercise records yet.';

  @override
  String get recordsEmptyHint =>
      'Log a value for a custom exercise (e.g. 1RM, reps) and add updates over time.';

  @override
  String get recordAdd => 'Add record';

  @override
  String get recordAddUpdate => 'Add update';

  @override
  String get recordValue => 'Value';

  @override
  String get recordUnit => 'Unit';

  @override
  String get recordDate => 'Date';

  @override
  String get recordNote => 'Note (optional)';

  @override
  String get recordUnitKg => 'kg';

  @override
  String get recordUnitReps => 'reps';

  @override
  String get recordUnitSec => 'sec';

  @override
  String get recordUnitMin => 'min';

  @override
  String get recordUnitOther => 'Other';

  @override
  String get recordDeleteConfirm => 'Delete this record?';

  @override
  String get recordSaved => 'Record saved.';

  @override
  String get recordSaveError => 'Could not save record.';

  @override
  String get recordDeleted => 'Record deleted.';

  @override
  String get recordDeleteError => 'Could not delete record.';

  @override
  String get recordSelectExercise => 'Select exercise';

  @override
  String get recordSearchExerciseHint => 'Search by name...';

  @override
  String get recordDeleteButton => 'Delete record';

  @override
  String get workoutBuilderClientRecord => 'Client record';

  @override
  String get workoutBuilderNoExerciseRecord => 'No record for this exercise.';

  @override
  String get workoutBuilderLoadPercentGuideTitle =>
      'Typical powerlifting intensities';

  @override
  String get workoutBuilderLoadPercentGuideIntroMass =>
      'Load for each percentage of the latest record.';

  @override
  String get workoutBuilderLoadPercentGuideIntroReps =>
      'Approximate reps per set at each % of your logged max (guideline).';

  @override
  String workoutBuilderLoadPercentGuideRow(
    String percent,
    String weight,
    String unit,
  ) {
    return '$percent% — $weight $unit';
  }

  @override
  String get workoutBuilderLoadPercentGuideBody =>
      '100% — max / ~1 rep\n95% — ~2 reps\n90% — ~4 reps\n85% — ~6 reps\n80% — ~8 reps\n75% — ~10 reps\n70% — ~12 reps\n65% — ~15 reps\n60% — ~18+ reps\n55% — accessory work\n50% — recovery / technique';

  @override
  String get workoutBuilderLoadPercentCalculator => 'Load from percentage';

  @override
  String get workoutBuilderLoadPercentFieldLabel => 'Percentage';

  @override
  String get workoutBuilderLoadPercentFieldHint => 'e.g. 77.5';

  @override
  String get workoutBuilderLoadPercentInvalid =>
      'Enter a number between 1 and 100.';

  @override
  String get workoutBuilderLoadPercentMassOnly =>
      'Log a weight record (kg or lb) to use the percentage calculator.';

  @override
  String workoutBuilderLoadPercentResult(
    String weight,
    String unit,
    String percent,
  ) {
    return '$weight $unit ($percent% of record)';
  }

  @override
  String get workoutBuilderTitle => 'Workout Builder';

  @override
  String get workoutBuilderPlanSaved => 'Plan saved';

  @override
  String get workoutBuilderRoutineSaved => 'Routine saved';

  @override
  String get workoutBuilderEditSectionTitle => 'Edit section';

  @override
  String get workoutBuilderSectionNameLabel => 'Section name';

  @override
  String get workoutBuilderDeleteWeekTitle => 'Delete week?';

  @override
  String get workoutBuilderDeleteWeekMessage =>
      'Remove this week and all its days and exercises. This cannot be undone.';

  @override
  String get workoutBuilderRenameDayTitle => 'Rename day';

  @override
  String get workoutBuilderDayNameLabel => 'Day name';

  @override
  String get workoutBuilderRenameWeekTitle => 'Rename week';

  @override
  String get workoutBuilderWeekNameLabel => 'Week name';

  @override
  String get workoutBuilderDuplicateWeekTitle => 'Duplicate week';

  @override
  String get workoutBuilderDuplicateWeekHint => 'Name for the new week';

  @override
  String get workoutBuilderEditMobilityExerciseTitle =>
      'Edit mobility exercise';

  @override
  String get workoutBuilderAddMobilityExerciseTitle => 'Add mobility exercise';

  @override
  String workoutBuilderWeekNumbered(int n) {
    return 'WEEK $n';
  }

  @override
  String workoutBuilderDayNumbered(int n) {
    return 'DAY $n';
  }

  @override
  String workoutBuilderSectionNumbered(int n) {
    return 'Section $n';
  }

  @override
  String get workoutBuilderNewExerciseDefault => 'New exercise';

  @override
  String get workoutBuilderNameCopySuffix => ' (copy)';

  @override
  String get workoutBuilderRoutineNameLabel => 'ROUTINE NAME';

  @override
  String get workoutBuilderRoutineNameHint => 'Add routine title';

  @override
  String get workoutBuilderMobilityRoutineTitle => 'Mobility routine';

  @override
  String get workoutBuilderAddShort => 'Add';

  @override
  String get workoutBuilderSectionHeading => 'Section';

  @override
  String get workoutBuilderAddExercise => 'Add exercise';

  @override
  String get workoutBuilderAddSet => 'Add set';

  @override
  String get workoutBuilderAddExerciseTitle => 'Add exercise';

  @override
  String get workoutBuilderEditExerciseTitle => 'Edit exercise';

  @override
  String get workoutBuilderExerciseLabel => 'Exercise';

  @override
  String get workoutBuilderFromLibrary => 'From library';

  @override
  String get workoutBuilderCreateNew => 'Create new';

  @override
  String get workoutBuilderCouldNotCreateExercise =>
      'Could not create exercise. Try again or add without saving to library.';

  @override
  String get workoutBuilderEnterNameOrSelect =>
      'Enter a name or select an exercise.';

  @override
  String get workoutBuilderMultiSetBlockHeader => 'Sets (Set × Reps + Load)';

  @override
  String get workoutBuilderSetLabel => 'Set';

  @override
  String get workoutBuilderSetsLabel => 'Sets';

  @override
  String get workoutBuilderRepsLabel => 'Reps';

  @override
  String get workoutBuilderLoadLabel => 'Load';

  @override
  String get workoutBuilderRpeOrLoadLabel => 'RPE / Load';

  @override
  String get workoutBuilderNoteOptionalLabel => 'Note (optional)';

  @override
  String get workoutBuilderNameLabel => 'Name';

  @override
  String get workoutBuilderNoteLabel => 'Note';

  @override
  String get workoutBuilderEditSetTitle => 'Edit set';

  @override
  String get workoutBuilderTrainingProgram => 'Training program';

  @override
  String get workoutBuilderNewWeek => 'New week';

  @override
  String get workoutBuilderDuplicateWeek => 'Duplicate week';

  @override
  String get workoutBuilderRenameWeekMenu => 'Rename week';

  @override
  String get workoutBuilderDeleteWeekMenu => 'Delete week';

  @override
  String get workoutBuilderClone => 'Clone';

  @override
  String workoutBuilderAddDayToWeek(int n) {
    return 'Add day to week $n';
  }

  @override
  String get workoutBuilderNoWeeksYet => 'No weeks yet. Add a week above.';

  @override
  String get workoutBuilderSuperSetHeading => 'SUPER SET';

  @override
  String get workoutBuilderDeleteDayMenu => 'Delete day';

  @override
  String get workoutBuilderNewSuperset => 'New superset';

  @override
  String get workoutBuilderRemoveFromSuperset => 'Remove from superset';

  @override
  String get workoutBuilderTabTraining => 'Training';

  @override
  String get workoutBuilderTabMobility => 'Mobility';

  @override
  String get workoutBuilderTabDetails => 'Details';

  @override
  String get workoutBuilderNotePlaceholder => 'Add note…';

  @override
  String get workoutBuilderMoreActions => 'More actions';

  @override
  String get workoutBuilderMoveUp => 'Move up';

  @override
  String get workoutBuilderMoveDown => 'Move down';

  @override
  String get workoutBuilderEditExercise => 'Edit exercise';

  @override
  String get workoutBuilderDeleteExercise => 'Delete exercise';

  @override
  String get workoutBuilderNavLibrary => 'Library';

  @override
  String get workoutBuilderNavBuilder => 'Builder';

  @override
  String get workoutBuilderNavDiary => 'Diary';

  @override
  String get workoutBuilderNavStats => 'Stats';

  @override
  String get workoutBuilderWeeksLabel => 'Weeks';

  @override
  String get workoutBuilderDaysLabel => 'Days';

  @override
  String get workoutBuilderAddDayChip => 'Day';

  @override
  String get workoutBuilderNoDaysInWeek => 'No days in this week yet.';

  @override
  String get workoutBuilderDeleteDayTitle => 'Delete day?';

  @override
  String get workoutBuilderDeleteDayMessage =>
      'All exercises on this day will be removed.';

  @override
  String get workoutBuilderSwipeDayHint => 'Swipe a day up to delete it';

  @override
  String workoutBuilderExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
    );
    return '$_temp0';
  }

  @override
  String get measurementsEmpty => 'No measurements yet';

  @override
  String get measurementsEmptyHint =>
      'Add a measurement to track 1RM, body composition, and circumferences.';

  @override
  String get measurementAdd => 'Add measurement';

  @override
  String get measurementEdit => 'Edit measurement';

  @override
  String get measurementDate => 'Date';

  @override
  String get measurement1RM => '1RM (kg)';

  @override
  String get measurementSquat => 'Squat';

  @override
  String get measurementBench => 'Bench press';

  @override
  String get measurementDeadlift => 'Deadlift';

  @override
  String get measurementSkinfolds => 'Skinfolds (mm)';

  @override
  String get measurementBodyFat => 'Body fat %';

  @override
  String get measurementMuscleMass => 'Muscle mass (kg)';

  @override
  String get measurementCircumferences => 'Circumferences (cm)';

  @override
  String get measurementChest => 'Chest';

  @override
  String get measurementWaist => 'Waist';

  @override
  String get measurementArms => 'Arms';

  @override
  String get measurementThighs => 'Thighs';

  @override
  String get measurementNotes => 'Notes';

  @override
  String get measurementSaved => 'Measurement saved.';

  @override
  String get measurementSaveError => 'Could not save measurement.';

  @override
  String get measurementDeleted => 'Measurement deleted.';

  @override
  String get measurementDeleteError => 'Could not delete measurement.';

  @override
  String get measurementDeleteConfirm => 'Delete this measurement?';

  @override
  String get measurementHistoryTitle => 'Measurement history';

  @override
  String get measurementHistoryMetricLabel => 'Metric';

  @override
  String get measurementHistoryNoMetricData =>
      'No values recorded for this metric yet.';

  @override
  String get measurementHistoryLoadError =>
      'Could not load measurement history.';

  @override
  String get measurementHistoryCompareTitle => 'Period comparison';

  @override
  String get measurementHistoryCompareSubtitle =>
      'Last 30 days vs previous 30 days';

  @override
  String get measurementHistoryCompareRecent => 'Last 30 days';

  @override
  String get measurementHistoryComparePrevious => 'Previous 30 days';

  @override
  String get measurementHistoryCompareInsufficient =>
      'Add more measurements to compare periods.';

  @override
  String get measurementHistoryCompareNoData => 'No data';

  @override
  String measurementHistoryCompareDelta(String metric, String delta) {
    return '$metric change: $delta';
  }

  @override
  String measurementHistoryCompareSampleCount(int count) {
    return '$count samples';
  }

  @override
  String get measurementHistoryOpen => 'View history';

  @override
  String get customerNotesTitle => 'Client notes';

  @override
  String customerNotesTitleFor(String customerName) {
    return 'Notes — $customerName';
  }

  @override
  String get customerNotesHint => 'Write a note for this client…';

  @override
  String get customerNotesEmpty =>
      'No notes yet. Add a follow-up, injury note, or preference.';

  @override
  String get customerNotesSend => 'Send';

  @override
  String get customerNotesOpen => 'Open notes';

  @override
  String get customerNotesEmptyBody => 'Message cannot be empty.';

  @override
  String get customerNotesSendError => 'Could not save the note.';

  @override
  String get customerNotesLoadError => 'Could not load notes.';

  @override
  String get customerNotesAttachPhoto => 'Attach photo';

  @override
  String get customerNotesAttachSoon =>
      'Photo attachments will arrive in a later update.';

  @override
  String get measurementExportCsv => 'Export CSV';

  @override
  String get measurementExportPdf => 'Export PDF';

  @override
  String get measurementExportSuccess => 'Download started.';

  @override
  String get measurementExportError => 'Could not export measurements.';

  @override
  String measurementHistoryExportPdfTitle(String customerName) {
    return 'Measurements — $customerName';
  }

  @override
  String get syncConflictTitle => 'Sync conflict detected';

  @override
  String get syncConflictMessage =>
      'There are conflicting local and remote changes. Choose whether to keep local changes or accept the remote version.';

  @override
  String syncConflictMessageWithEntity(String entityType) {
    return 'Conflicting changes for $entityType. Keep your edits or use the server copy.';
  }

  @override
  String get syncConflictUseRemote => 'Use remote';

  @override
  String get syncConflictUseLocal => 'Use local';

  @override
  String get syncInProgress => 'Synchronizing changes...';

  @override
  String get syncNow => 'Sync now';

  @override
  String syncPending(int count) {
    return 'Pending sync: $count';
  }

  @override
  String syncFailed(int count) {
    return 'Sync failed: $count pending';
  }

  @override
  String get settingsSyncSectionTitle => 'Sync';

  @override
  String settingsSyncSectionSubtitle(int pending, int failed) {
    return '$pending queued, $failed need attention';
  }

  @override
  String get settingsSyncRetryFailed => 'Retry failed operations';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardWeeklyProgress => 'Weekly Progress';

  @override
  String get dashboardPlansUpdatedThisWeek => 'Plans Updated This Week';

  @override
  String get dashboardTotalClients => 'Total Clients';

  @override
  String get dashboardActivePrograms => 'Active Programs';

  @override
  String get dashboardCreateProgram => 'Create Program';

  @override
  String get dashboardTodaySchedule => 'Today\'s Schedule';

  @override
  String get dashboardSeeAll => 'See All';

  @override
  String get dashboardNoScheduleToday => 'No schedule items for today.';

  @override
  String get dashboardNoScheduledWorkoutsYet => 'No scheduled workouts yet.';

  @override
  String get dashboardUnknownClient => 'Unknown client';

  @override
  String get dashboardUntitledWorkout => 'Untitled workout';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarEmptyMonth => 'No sessions on this day.';

  @override
  String get calendarLoadError => 'Could not load the calendar.';

  @override
  String get calendarUpdateError => 'Could not update session status.';

  @override
  String get calendarUpcomingSessions => 'Upcoming sessions';

  @override
  String get sessionCompleted => 'Completed';

  @override
  String get sessionSkipped => 'Skipped';

  @override
  String get dashboardWorkoutBuilder => 'Workout Builder';

  @override
  String get dashboardSessionTitle => 'Session';

  @override
  String get dashboardDetailHint =>
      'Details are based on the selected workout plan start date.';

  @override
  String get dashboardReminderTooltip => 'Set reminder';

  @override
  String get dashboardSectionToday => 'Today';

  @override
  String get dashboardSectionAttention => 'Needs attention';

  @override
  String get dashboardSectionStalePlans => 'Plans to refresh';

  @override
  String get dashboardSectionCustomersNoPlan => 'Clients without a program';

  @override
  String get dashboardNoPending =>
      'Nothing in the sync queue needs action right now.';

  @override
  String dashboardQueuedOperationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operations waiting to sync',
      one: '$count operation waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get dashboardBackupHint =>
      'Data stays on this device until it syncs. Export a backup from Settings before reinstalling.';

  @override
  String get dashboardOpenSyncSettings => 'Open Settings';

  @override
  String get dashboardLoadError =>
      'Could not load the dashboard. Pull down to try again.';

  @override
  String dashboardNoStalePlans(int days) {
    return 'All programs were updated within the last $days days.';
  }

  @override
  String get dashboardNoCustomersWithoutPlan =>
      'Every client has at least one program.';

  @override
  String get dashboardPendingDetailTitle => 'Sync operation';

  @override
  String dashboardPendingStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String dashboardPendingEntityLabel(String entity) {
    return 'Entity: $entity';
  }

  @override
  String dashboardPendingPathLabel(String path) {
    return 'Path: $path';
  }

  @override
  String get dashboardSyncStatusPending => 'Pending';

  @override
  String get dashboardSyncStatusSyncing => 'Syncing';

  @override
  String get dashboardSyncStatusFailed => 'Failed';

  @override
  String get dashboardSyncStatusConflict => 'Conflict';

  @override
  String get dashboardSyncStatusCompleted => 'Completed';

  @override
  String get dashboardSyncStatusDeadLetter => 'Could not sync';

  @override
  String get dashboardSyncStatusBlockedAuth => 'Waiting for sign-in';

  @override
  String get dashboardSemanticTodayList => 'Programs starting today';

  @override
  String get dashboardSemanticAttentionList => 'Sync queue and errors';

  @override
  String get dashboardSemanticNoPlanList => 'Clients without a program';

  @override
  String get dashboardSemanticStaleList => 'Programs that may need an update';

  @override
  String get customerEditProfile => 'Edit Profile';

  @override
  String get customerAssignWorkout => 'Assign Workout';

  @override
  String get customerGoalLabel => 'Goal';

  @override
  String get customerCurrentWeight => 'Current Weight';

  @override
  String get customerMuscleMass => 'Muscle Mass';

  @override
  String get customerWorkoutPlans => 'Workout plans';

  @override
  String get customerViewAll => 'View all';

  @override
  String get customerNoWorkoutPlansYet => 'No workout plans yet';

  @override
  String get customerUnnamedPlan => 'Unnamed plan';

  @override
  String get workoutsTitle => 'Workouts';

  @override
  String get workoutsNoWorkoutsYet => 'No workouts yet';

  @override
  String get workoutsAssignHint =>
      'Assign a workout to this customer from the customer detail screen.';

  @override
  String get customerWorkoutsSearchHint => 'Search by name, phase, or tag';

  @override
  String get customerWorkoutsFilterAll => 'All';

  @override
  String get customerWorkoutsFilterActive => 'Active';

  @override
  String get customerWorkoutsFilterScheduled => 'Scheduled';

  @override
  String get customerWorkoutsFilterUnscheduled => 'Unscheduled';

  @override
  String get customerWorkoutsFilterEnded => 'Ended';

  @override
  String get customerWorkoutsFilterStale => 'Needs update';

  @override
  String get customerWorkoutsSortTitle => 'Sort by';

  @override
  String get customerWorkoutsSortStartDateDesc => 'Start date (newest)';

  @override
  String get customerWorkoutsSortStartDateAsc => 'Start date (oldest)';

  @override
  String get customerWorkoutsSortUpdatedDesc => 'Last updated (newest)';

  @override
  String get customerWorkoutsSortUpdatedAsc => 'Last updated (oldest)';

  @override
  String get customerWorkoutsSortNameAsc => 'Name (A-Z)';

  @override
  String get customerWorkoutsSortNameDesc => 'Name (Z-A)';

  @override
  String get customerWorkoutsNoMatch => 'No plans match the selected filters.';

  @override
  String get workoutLibraryTitle => 'Library';

  @override
  String get workoutTemplatesTitle => 'Workout templates';

  @override
  String get workoutTemplatesEmpty =>
      'No templates yet. Save a client plan as a template or create one here.';

  @override
  String get workoutTemplatesNew => 'New template';

  @override
  String get workoutTemplatesAssign => 'Assign to client';

  @override
  String get workoutTemplatesDuplicate => 'Duplicate template';

  @override
  String get workoutTemplatesEdit => 'Edit';

  @override
  String get workoutTemplatesDelete => 'Delete';

  @override
  String get workoutTemplatesAssignTitle => 'Choose a client';

  @override
  String get workoutTemplatesSaveAsTemplate => 'Save as template';

  @override
  String get workoutTemplatesSaveAsTemplateTitle => 'Template name';

  @override
  String get workoutTemplatesNameHint => 'Name';

  @override
  String get workoutTemplatesDuplicateTitle => 'Duplicate template';

  @override
  String get workoutTemplatesDuplicateHint => 'Name for the copy';

  @override
  String get workoutTemplatesAssignedSnack => 'Plan added to the client.';

  @override
  String get workoutTemplatesDuplicateSnack => 'Template created.';

  @override
  String get workoutTemplatesDeleteConfirmTitle => 'Delete template?';

  @override
  String get workoutTemplatesDeleteConfirmMessage =>
      'This template will be removed from this device.';

  @override
  String get workoutTemplatesDrawerLabel => 'Workout templates';

  @override
  String get workoutTemplatesCustomersLoadError =>
      'Could not load the client list. Try again.';

  @override
  String get workoutTemplatesSemanticList => 'Workout templates list';

  @override
  String get workoutTemplatesAssignSearchHint => 'Search by name…';

  @override
  String get workoutTemplatesAssignNoMatch => 'No customers match your search.';

  @override
  String get workoutDiaryTitle => 'Diary';

  @override
  String get workoutStatsTitle => 'Stats';

  @override
  String get placeholderComingSoon => 'Coming soon';

  @override
  String get placeholderSectionNotImplemented =>
      'This section is not yet implemented.';

  @override
  String get placeholderBackToBuilder => 'Back to Builder';

  @override
  String get customerDetailTitle => 'Customer Detail';

  @override
  String get actionsTitle => 'Actions';

  @override
  String updatedDaysAgo(int count) {
    return 'Updated ${count}d ago';
  }

  @override
  String updatedHoursAgo(int count) {
    return 'Updated ${count}h ago';
  }

  @override
  String updatedMinutesAgo(int count) {
    return 'Updated ${count}m ago';
  }

  @override
  String get updatedJustNow => 'Just now';

  @override
  String get exerciseLibraryTabHevy => 'Hevy';

  @override
  String get exerciseLibraryImportSourceHevy => 'Sync full Hevy catalog';

  @override
  String get exerciseLibraryImportSourceHevySubtitle =>
      'Import all exercises from your Hevy Pro account with pre-mapped IDs.';

  @override
  String get hevySettingsSectionTitle => 'Hevy integration';

  @override
  String get hevySettingsSectionSubtitle =>
      'Requires Hevy Pro. API key from hevy.com/settings (Developer).';

  @override
  String get hevySettingsApiKeyLabel => 'Hevy API key';

  @override
  String get hevySettingsApiKeyHint => 'Paste your API key';

  @override
  String get hevySettingsSaveKey => 'Save key';

  @override
  String get hevySettingsTestConnection => 'Test connection';

  @override
  String get hevySettingsSyncCatalog => 'Sync all exercises';

  @override
  String get hevySettingsKeySaved => 'Hevy API key saved.';

  @override
  String get hevySettingsTestSuccess => 'Connected to Hevy.';

  @override
  String hevySettingsTestFailed(String message) {
    return 'Hevy connection failed: $message';
  }

  @override
  String get hevyImportInProgress => 'Syncing Hevy catalog…';

  @override
  String hevyImportSuccessCount(int count) {
    return 'Hevy sync complete: $count new items.';
  }

  @override
  String hevyImportFailed(String message) {
    return 'Hevy sync failed: $message';
  }

  @override
  String get workoutExportHevy => 'Export day to Hevy';

  @override
  String get hevyExportSheetTitle => 'Export to Hevy';

  @override
  String get hevyExportConfirm => 'Create routine on Hevy';

  @override
  String get hevyExportConfirmRoutine => 'Create routine on Hevy';

  @override
  String get hevyExportConfirmWorkout => 'Create workout on Hevy';

  @override
  String get hevyExportWorkoutHint =>
      'The workout is logged in your Hevy diary starting now, with an estimated end in 90 minutes.';

  @override
  String get hevyExportSuccessRoutine => 'Routine created on Hevy.';

  @override
  String get hevyExportSuccessWorkout => 'Workout created on Hevy.';

  @override
  String get hevyExportAllMapped =>
      'All exercises are mapped. Ready to export.';

  @override
  String hevyExportUnmappedIntro(int count) {
    return '$count exercises need a Hevy mapping before export.';
  }

  @override
  String get hevyExportMapExercise => 'Map';

  @override
  String get hevyExportUnmappedBlock => 'Map all exercises before exporting.';

  @override
  String get hevyExportSuccess => 'Routine created on Hevy.';

  @override
  String get hevyExportError => 'Hevy export failed. Try again.';

  @override
  String get hevyExportNoCatalogHint =>
      'Sync the Hevy catalog from Settings or Exercise Library first.';

  @override
  String get calendarExportHevy => 'Export to Hevy';
}

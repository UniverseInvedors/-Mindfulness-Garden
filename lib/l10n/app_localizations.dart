import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('bn'),
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness Garden'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @breathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get breathing;

  /// No description provided for @meditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get meditation;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @zenoBreathing.
  ///
  /// In en, this message translates to:
  /// **'Zeno Breathing'**
  String get zenoBreathing;

  /// No description provided for @boxBreathing.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get boxBreathing;

  /// No description provided for @diaphragmaticBreathing.
  ///
  /// In en, this message translates to:
  /// **'Diaphragmatic Breathing'**
  String get diaphragmaticBreathing;

  /// No description provided for @fourSevenEightBreathing.
  ///
  /// In en, this message translates to:
  /// **'4-7-8 Breathing'**
  String get fourSevenEightBreathing;

  /// No description provided for @immersiveBreathing.
  ///
  /// In en, this message translates to:
  /// **'Immersive Breathing'**
  String get immersiveBreathing;

  /// No description provided for @tapStartToBegin.
  ///
  /// In en, this message translates to:
  /// **'Tap Start to begin'**
  String get tapStartToBegin;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @benefitsBreathing.
  ///
  /// In en, this message translates to:
  /// **'Benefits of Breathing'**
  String get benefitsBreathing;

  /// No description provided for @breathingBenefits.
  ///
  /// In en, this message translates to:
  /// **'Calms mind, Reduces anxiety, Improves focus'**
  String get breathingBenefits;

  /// No description provided for @releaseStressTension.
  ///
  /// In en, this message translates to:
  /// **'Release stress & tension'**
  String get releaseStressTension;

  /// No description provided for @gentleGuidedBreathing.
  ///
  /// In en, this message translates to:
  /// **'Gentle guided breathing for stress relief'**
  String get gentleGuidedBreathing;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get inhale;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get exhale;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get cycles;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @chooseYourWorld.
  ///
  /// In en, this message translates to:
  /// **'Choose your world'**
  String get chooseYourWorld;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @timeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Time of Day'**
  String get timeOfDay;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forest;

  /// No description provided for @ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get ocean;

  /// No description provided for @mountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get mountain;

  /// No description provided for @cosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic'**
  String get cosmic;

  /// No description provided for @desert.
  ///
  /// In en, this message translates to:
  /// **'Desert'**
  String get desert;

  /// No description provided for @zenTemple.
  ///
  /// In en, this message translates to:
  /// **'Zen Temple'**
  String get zenTemple;

  /// No description provided for @garden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get garden;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get goodNight;

  /// No description provided for @gardenSerenity.
  ///
  /// In en, this message translates to:
  /// **'Garden Serenity'**
  String get gardenSerenity;

  /// No description provided for @skyCalm.
  ///
  /// In en, this message translates to:
  /// **'Sky Calm'**
  String get skyCalm;

  /// No description provided for @sunriseGlow.
  ///
  /// In en, this message translates to:
  /// **'Sunrise Glow'**
  String get sunriseGlow;

  /// No description provided for @roseHarmony.
  ///
  /// In en, this message translates to:
  /// **'Rose Harmony'**
  String get roseHarmony;

  /// No description provided for @lavenderDream.
  ///
  /// In en, this message translates to:
  /// **'Lavender Dream'**
  String get lavenderDream;

  /// No description provided for @midnightZen.
  ///
  /// In en, this message translates to:
  /// **'Midnight Zen'**
  String get midnightZen;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @uiTheme.
  ///
  /// In en, this message translates to:
  /// **'UI Theme'**
  String get uiTheme;

  /// No description provided for @aiTutorVoice.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor Voice'**
  String get aiTutorVoice;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @appAppearance.
  ///
  /// In en, this message translates to:
  /// **'App appearance'**
  String get appAppearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enableDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get enableDarkTheme;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time for daily meditation reminder'**
  String get dailyReminderSubtitle;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @autoPlaySounds.
  ///
  /// In en, this message translates to:
  /// **'Auto-play Sounds'**
  String get autoPlaySounds;

  /// No description provided for @autoPlaySoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play ambient sounds automatically'**
  String get autoPlaySoundsSubtitle;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback during sessions'**
  String get vibrationSubtitle;

  /// No description provided for @volumeLevel.
  ///
  /// In en, this message translates to:
  /// **'Volume Level'**
  String get volumeLevel;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your meditation data'**
  String get exportDataSubtitle;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @clearDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all app data'**
  String get clearDataSubtitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms and conditions'**
  String get termsOfServiceSubtitle;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback'**
  String get rateAppSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @accessPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Access your premium features'**
  String get accessPremiumFeatures;

  /// No description provided for @joinMindfulnessGarden.
  ///
  /// In en, this message translates to:
  /// **'Join Mindfulness Garden'**
  String get joinMindfulnessGarden;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio — tell us about yourself (optional)'**
  String get bio;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @gardenLevel.
  ///
  /// In en, this message translates to:
  /// **'Garden Level'**
  String get gardenLevel;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @moodLogs.
  ///
  /// In en, this message translates to:
  /// **'Mood Logs'**
  String get moodLogs;

  /// No description provided for @plants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get plants;

  /// No description provided for @zenoIntro.
  ///
  /// In en, this message translates to:
  /// **'Hi, it\'s Zeno. We are going to do breathing exercises now. You can do these anytime you are having a difficult time. Remember, Just breathe.'**
  String get zenoIntro;

  /// No description provided for @cycleCount.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycleCount;

  /// No description provided for @backToExercises.
  ///
  /// In en, this message translates to:
  /// **'BACK TO EXERCISES'**
  String get backToExercises;

  /// No description provided for @restNow.
  ///
  /// In en, this message translates to:
  /// **'REST NOW'**
  String get restNow;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @personality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get personality;

  /// No description provided for @buddhaGuide.
  ///
  /// In en, this message translates to:
  /// **'Buddha speaks guidance throughout the app'**
  String get buddhaGuide;

  /// No description provided for @iAmBuddha.
  ///
  /// In en, this message translates to:
  /// **'I am the Buddha guide. Wisdom flows through silence.'**
  String get iAmBuddha;

  /// No description provided for @iAmZeno.
  ///
  /// In en, this message translates to:
  /// **'Hey! I\'m Zeno, your coach. Let\'s go!'**
  String get iAmZeno;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin.'**
  String get begin;

  /// No description provided for @themeSelected.
  ///
  /// In en, this message translates to:
  /// **'theme selected.'**
  String get themeSelected;

  /// No description provided for @exportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Export feature coming soon!'**
  String get exportComingSoon;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearAllData;

  /// No description provided for @clearDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your meditation sessions, mood entries, and settings. This action cannot be undone.'**
  String get clearDataWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'Data cleared successfully'**
  String get dataCleared;

  /// No description provided for @privacyPolicySoon.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy will open soon'**
  String get privacyPolicySoon;

  /// No description provided for @termsSoon.
  ///
  /// In en, this message translates to:
  /// **'Terms of service will open soon'**
  String get termsSoon;

  /// No description provided for @ratingSoon.
  ///
  /// In en, this message translates to:
  /// **'Rating feature coming soon'**
  String get ratingSoon;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get signOutQuestion;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOut;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @pleaseEnterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get pleaseEnterEmailPassword;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error:'**
  String get loginError;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome!'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error:'**
  String get registrationError;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved!'**
  String get profileSaved;

  /// No description provided for @logoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logoutSuccessful;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Logout error:'**
  String get logoutError;

  /// No description provided for @guidedMeditation.
  ///
  /// In en, this message translates to:
  /// **'Guided Meditation'**
  String get guidedMeditation;

  /// No description provided for @expertLedSessions.
  ///
  /// In en, this message translates to:
  /// **'Expert-led sessions'**
  String get expertLedSessions;

  /// No description provided for @tapPlayToBegin.
  ///
  /// In en, this message translates to:
  /// **'Tap play to begin'**
  String get tapPlayToBegin;

  /// No description provided for @audioMeditation.
  ///
  /// In en, this message translates to:
  /// **'Audio Meditation'**
  String get audioMeditation;

  /// No description provided for @immerseInSound.
  ///
  /// In en, this message translates to:
  /// **'Immerse in sound'**
  String get immerseInSound;

  /// No description provided for @breathingPattern.
  ///
  /// In en, this message translates to:
  /// **'BREATHING PATTERN'**
  String get breathingPattern;

  /// No description provided for @breatheIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe In'**
  String get breatheIn;

  /// No description provided for @breatheOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe Out'**
  String get breatheOut;

  /// No description provided for @meditationLibrary.
  ///
  /// In en, this message translates to:
  /// **'Meditation Library'**
  String get meditationLibrary;

  /// No description provided for @ambientSounds.
  ///
  /// In en, this message translates to:
  /// **'AMBIENT SOUNDS'**
  String get ambientSounds;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @selectSession.
  ///
  /// In en, this message translates to:
  /// **'Select a session to begin'**
  String get selectSession;

  /// No description provided for @voiceGuide.
  ///
  /// In en, this message translates to:
  /// **'Voice guide speaking'**
  String get voiceGuide;

  /// No description provided for @preparingGuide.
  ///
  /// In en, this message translates to:
  /// **'Preparing guide'**
  String get preparingGuide;

  /// No description provided for @loadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Loading local video...'**
  String get loadingVideo;

  /// No description provided for @voiceGuidanceBegin.
  ///
  /// In en, this message translates to:
  /// **'Your voice guidance will begin automatically.'**
  String get voiceGuidanceBegin;

  /// No description provided for @videoNotStart.
  ///
  /// In en, this message translates to:
  /// **'Video could not start. Voice guidance is playing instead.'**
  String get videoNotStart;

  /// No description provided for @sessionStartedAudio.
  ///
  /// In en, this message translates to:
  /// **'The session has already started with audio.'**
  String get sessionStartedAudio;

  /// No description provided for @retryVideo.
  ///
  /// In en, this message translates to:
  /// **'Retry Video'**
  String get retryVideo;

  /// No description provided for @breathAwareness.
  ///
  /// In en, this message translates to:
  /// **'Breath Awareness'**
  String get breathAwareness;

  /// No description provided for @followBreathRhythm.
  ///
  /// In en, this message translates to:
  /// **'Follow the rhythm of your breath'**
  String get followBreathRhythm;
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
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

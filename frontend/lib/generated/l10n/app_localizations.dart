import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'AgroSense'**
  String get appName;

  /// Hero welcome headline on the language screen
  ///
  /// In en, this message translates to:
  /// **'Grow smarter, worry less'**
  String get welcomeTitle;

  /// Short supporting line below the welcome title
  ///
  /// In en, this message translates to:
  /// **'Know what your crops need, before problems start.'**
  String get welcomeSubtitle;

  /// Prompt to select a language
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// Language option: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option: Hindi, shown in Hindi script
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// Language option: Marathi, shown in Marathi script
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get languageMarathi;

  /// Continue button on language screen
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Alternative label for the primary CTA button
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Bottom nav: Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom nav: My Fields tab label
  ///
  /// In en, this message translates to:
  /// **'My Fields'**
  String get myFields;

  /// Bottom nav: Alerts tab label
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// Placeholder text for screens under construction
  ///
  /// In en, this message translates to:
  /// **'More here soon'**
  String get comingSoon;

  /// Accessibility listen button label (TTS, future phase)
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// Crop health status: healthy
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// Crop health status: caution
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get warning;

  /// Crop health status: critical
  ///
  /// In en, this message translates to:
  /// **'Act now'**
  String get danger;

  /// Hint shown before a language is selected
  ///
  /// In en, this message translates to:
  /// **'Tap a language to begin'**
  String get tapToStart;

  /// Generic greeting on the home screen — no real name
  ///
  /// In en, this message translates to:
  /// **'Welcome, farmer'**
  String get helloFarmer;

  /// Onboarding screen 1 title
  ///
  /// In en, this message translates to:
  /// **'Your field, in one look'**
  String get onboarding1Title;

  /// Onboarding screen 1 body
  ///
  /// In en, this message translates to:
  /// **'The app shows which part of the crop is healthy and which part needs care.'**
  String get onboarding1Body;

  /// Onboarding screen 2 title
  ///
  /// In en, this message translates to:
  /// **'Know before the crop looks sick'**
  String get onboarding2Title;

  /// Onboarding screen 2 body
  ///
  /// In en, this message translates to:
  /// **'If water, pests, or weakness start, you get a simple alert.'**
  String get onboarding2Body;

  /// Onboarding screen 3 title
  ///
  /// In en, this message translates to:
  /// **'Clear next step'**
  String get onboarding3Title;

  /// Onboarding screen 3 body
  ///
  /// In en, this message translates to:
  /// **'Each alert tells you what to do today, in your language.'**
  String get onboarding3Body;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Start button label
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Spoken prompt when a language is selected
  ///
  /// In en, this message translates to:
  /// **'Tap continue when ready'**
  String get tapContinueWhenReady;

  /// Phone entry screen title
  ///
  /// In en, this message translates to:
  /// **'Your mobile number'**
  String get phoneTitle;

  /// Phone entry screen help line
  ///
  /// In en, this message translates to:
  /// **'We will send a 4-digit code'**
  String get phoneSubtitle;

  /// Phone input placeholder
  ///
  /// In en, this message translates to:
  /// **'10-digit number'**
  String get phoneHint;

  /// OTP screen title
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code'**
  String get otpTitle;

  /// OTP screen subtitle with masked phone number
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}'**
  String otpSubtitle(String phone);

  /// Incorrect OTP error message
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Try 1234 for now.'**
  String get otpWrongCode;

  /// Resend OTP button label
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Cooldown indicator for OTP resend
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// Muted caption showing demo OTP code
  ///
  /// In en, this message translates to:
  /// **'Demo code 1234'**
  String get demoCodeNotice;

  /// Farmer profile screen title
  ///
  /// In en, this message translates to:
  /// **'Tell us about your farm'**
  String get profileTitle;

  /// Profile: Farmer name question
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameQuestion;

  /// Profile: Name field hint
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get nameHint;

  /// Profile: Village question
  ///
  /// In en, this message translates to:
  /// **'Your village or town?'**
  String get villageQuestion;

  /// Profile: Village field hint
  ///
  /// In en, this message translates to:
  /// **'Village or town name'**
  String get villageHint;

  /// Profile: Main crop selection question
  ///
  /// In en, this message translates to:
  /// **'Main crop?'**
  String get cropQuestion;

  /// Crop option: Rice
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get cropRice;

  /// Crop option: Wheat
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get cropWheat;

  /// Crop option: Cotton
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cropCotton;

  /// Crop option: Sugarcane
  ///
  /// In en, this message translates to:
  /// **'Sugarcane'**
  String get cropSugarcane;

  /// Crop option: Soybean
  ///
  /// In en, this message translates to:
  /// **'Soybean'**
  String get cropSoybean;

  /// Crop option: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cropOther;

  /// Profile submit button label
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// Personalized farmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(String name);

  /// Temperature label
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get weatherTemp;

  /// Rain label
  ///
  /// In en, this message translates to:
  /// **'Rain today'**
  String get weatherRain;

  /// Wind label
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get weatherWind;

  /// Title of the main field health card
  ///
  /// In en, this message translates to:
  /// **'My field today'**
  String get myFieldToday;

  /// Healthy field status tag
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthyStatus;

  /// Watch caution field status tag
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchStatus;

  /// Act now warning field status tag
  ///
  /// In en, this message translates to:
  /// **'Act now'**
  String get actNowStatus;

  /// Healthy field summary sentence
  ///
  /// In en, this message translates to:
  /// **'Most of the crop looks fine. Check the dry corner tomorrow.'**
  String get healthSummaryHealthy;

  /// Watch field summary sentence
  ///
  /// In en, this message translates to:
  /// **'Soil moisture is dipping. Plan watering for tomorrow.'**
  String get healthSummaryWatch;

  /// Act now field summary sentence
  ///
  /// In en, this message translates to:
  /// **'Crop stress detected. Inspect the field today.'**
  String get healthSummaryActNow;

  /// Empty state label when there are zero alerts
  ///
  /// In en, this message translates to:
  /// **'No alert today'**
  String get noAlertsToday;

  /// Alert card text when alerts exist
  ///
  /// In en, this message translates to:
  /// **'{count} alert. Tap to see what to do.'**
  String alertsTapToSee(int count);

  /// Full home screen text-to-speech summary
  ///
  /// In en, this message translates to:
  /// **'{greeting}. Temperature {temp} degrees. Rain {rain} millimeter. Your field is {health}. {alerts}.'**
  String homeSpeech(
      String greeting, int temp, int rain, String health, String alerts);
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

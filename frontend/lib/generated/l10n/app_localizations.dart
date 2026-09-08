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

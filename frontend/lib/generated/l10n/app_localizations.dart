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

  /// Empty state title when farmer has no fields
  ///
  /// In en, this message translates to:
  /// **'No field yet'**
  String get noFieldsYet;

  /// Empty state prompt to add first field
  ///
  /// In en, this message translates to:
  /// **'Add your first field'**
  String get addFirstField;

  /// Action button to add a field
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addField;

  /// Listen summary for fields list
  ///
  /// In en, this message translates to:
  /// **'You have {count} fields'**
  String fieldsCount(int count);

  /// Speech text when field list is empty
  ///
  /// In en, this message translates to:
  /// **'No field yet. Add your first field.'**
  String get fieldsEmptySpeech;

  /// Field name input label
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get fieldNameLabel;

  /// Default placeholder for field name
  ///
  /// In en, this message translates to:
  /// **'Main field'**
  String get fieldNameHint;

  /// Crop selection prompt in add field screen
  ///
  /// In en, this message translates to:
  /// **'Which crop is grown here?'**
  String get selectCropQuestion;

  /// Title on pin map screen
  ///
  /// In en, this message translates to:
  /// **'Tap your field'**
  String get tapYourField;

  /// Instruction on pin map screen
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a pin. You can move it.'**
  String get tapMapInstruction;

  /// Button to center map on device GPS location
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// Calm message when location permission is not granted
  ///
  /// In en, this message translates to:
  /// **'Location not shared. You can still tap the map to place your pin.'**
  String get locationDeniedNotice;

  /// Button to confirm and save field
  ///
  /// In en, this message translates to:
  /// **'Save field'**
  String get saveField;

  /// Voice narration for add field step 1
  ///
  /// In en, this message translates to:
  /// **'Add field. Enter a name or leave it as Main field, choose your crop, and tap next.'**
  String get addFieldStep1Speech;

  /// Voice narration for add field step 2 map
  ///
  /// In en, this message translates to:
  /// **'Tap your field. Tap the map to drop a pin. You can move it. Tap save field when done.'**
  String get addFieldStep2Speech;

  /// Health meter label
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get meterHealth;

  /// Water meter label
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get meterWater;

  /// Pest meter label
  ///
  /// In en, this message translates to:
  /// **'Pest'**
  String get meterPest;

  /// Meter status: Low
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// Meter status: Okay
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get statusOkay;

  /// Meter status hint: Dry
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get statusDry;

  /// Meter status hint: Risk
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get statusRisk;

  /// Overlay legend: Healthy zone
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get legendHealthy;

  /// Overlay legend: Watch zone
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get legendWatch;

  /// Overlay legend: Needs care zone
  ///
  /// In en, this message translates to:
  /// **'Needs care'**
  String get legendNeedsCare;

  /// Advice sentence when all meters are good
  ///
  /// In en, this message translates to:
  /// **'This field looks fine today.'**
  String get detailSummaryAllGood;

  /// Advice sentence when water is low
  ///
  /// In en, this message translates to:
  /// **'Water is low. Give water if the soil is dry.'**
  String get detailSummaryWaterLow;

  /// Advice sentence when pest risk is detected
  ///
  /// In en, this message translates to:
  /// **'Pest risk is up. Walk the field today.'**
  String get detailSummaryPestWatch;

  /// Advice sentence when immediate action is needed
  ///
  /// In en, this message translates to:
  /// **'Crop needs care today. Check the stressed area.'**
  String get detailSummaryActNow;

  /// Voice narration for field detail screen
  ///
  /// In en, this message translates to:
  /// **'{name}. Health {health}. Water {water}. Pest {pest}. {summary}'**
  String fieldDetailSpeech(
      String name, String health, String water, String pest, String summary);

  /// Empty state subtitle when all fields are healthy
  ///
  /// In en, this message translates to:
  /// **'Your fields look fine.'**
  String get fieldsLookFine;

  /// Timestamp label for recent alert
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get alertTimeToday;

  /// Problem title: water low
  ///
  /// In en, this message translates to:
  /// **'Water is low.'**
  String get alertProblemWaterLow;

  /// Problem title: critical water stress
  ///
  /// In en, this message translates to:
  /// **'Soil is critically dry.'**
  String get alertProblemWaterCritical;

  /// Problem title: pest caution
  ///
  /// In en, this message translates to:
  /// **'Pest risk is up.'**
  String get alertProblemPestWatch;

  /// Problem title: pest danger
  ///
  /// In en, this message translates to:
  /// **'High pest activity detected.'**
  String get alertProblemPestCritical;

  /// Problem title: health caution
  ///
  /// In en, this message translates to:
  /// **'Crop weakness detected.'**
  String get alertProblemHealthWatch;

  /// Problem title: health danger
  ///
  /// In en, this message translates to:
  /// **'Severe crop stress detected.'**
  String get alertProblemHealthCritical;

  /// One-line action for water alert
  ///
  /// In en, this message translates to:
  /// **'Give water if the soil is dry.'**
  String get alertActionWater;

  /// One-line action for pest alert
  ///
  /// In en, this message translates to:
  /// **'Walk the field and look under leaves.'**
  String get alertActionPest;

  /// One-line action for health alert
  ///
  /// In en, this message translates to:
  /// **'Inspect the weak corner shown on the field.'**
  String get alertActionHealth;

  /// Step 1 for water alert
  ///
  /// In en, this message translates to:
  /// **'Check soil moisture with your fingers near crop roots.'**
  String get alertStepWater1;

  /// Step 2 for water alert
  ///
  /// In en, this message translates to:
  /// **'Water in early morning or evening to reduce loss.'**
  String get alertStepWater2;

  /// Step 3 for water alert
  ///
  /// In en, this message translates to:
  /// **'Do not flood the field if unsure of drainage.'**
  String get alertStepWater3;

  /// Step 1 for pest alert
  ///
  /// In en, this message translates to:
  /// **'Walk the field and inspect under leaves carefully.'**
  String get alertStepPest1;

  /// Step 2 for pest alert
  ///
  /// In en, this message translates to:
  /// **'Pick and remove any visible pests or damaged leaves.'**
  String get alertStepPest2;

  /// Step 3 for pest alert
  ///
  /// In en, this message translates to:
  /// **'Ask your local agriculture officer before spraying chemicals.'**
  String get alertStepPest3;

  /// Step 1 for health alert
  ///
  /// In en, this message translates to:
  /// **'Check water moisture and pests in the field first.'**
  String get alertStepHealth1;

  /// Step 2 for health alert
  ///
  /// In en, this message translates to:
  /// **'Look at the weak corner shown on your field photo.'**
  String get alertStepHealth2;

  /// Step 3 for health alert
  ///
  /// In en, this message translates to:
  /// **'Ensure proper sunlight and soil aeration around roots.'**
  String get alertStepHealth3;

  /// Guidance on when to seek professional help
  ///
  /// In en, this message translates to:
  /// **'If it gets worse in 2 days, ask your local shop or officer.'**
  String get alertHelpNotice;

  /// Section header on alert detail screen
  ///
  /// In en, this message translates to:
  /// **'What to do today'**
  String get whatToDoToday;

  /// Action pill button marking alert as seen
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get markDone;

  /// Link on field detail to view action steps
  ///
  /// In en, this message translates to:
  /// **'See what to do'**
  String get seeWhatToDo;

  /// Spoken text when alerts list is empty
  ///
  /// In en, this message translates to:
  /// **'No alert today. Your fields look fine.'**
  String get alertsSpeechEmpty;

  /// Spoken text when alerts exist
  ///
  /// In en, this message translates to:
  /// **'You have {count} alerts. First: {firstProblem} in {fieldName}.'**
  String alertsSpeechCount(int count, String firstProblem, String fieldName);

  /// Spoken text for alert detail
  ///
  /// In en, this message translates to:
  /// **'{problem}. Steps for today: {steps}. {help}'**
  String alertDetailSpeech(String problem, String steps, String help);

  /// Status text while microphone is active
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceListening;

  /// Button to stop voice recording
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceStop;

  /// Calm message when mic permission is denied
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to hear your voice.'**
  String get voicePermissionDenied;

  /// Guidance when spoken input is unparsed
  ///
  /// In en, this message translates to:
  /// **'Did not catch that. Try saying Home, Fields, Alerts, or What to do.'**
  String get voiceNotUnderstood;

  /// Spoken help options
  ///
  /// In en, this message translates to:
  /// **'You can say Home, My Fields, Alerts, or What to do.'**
  String get voiceHelpPrompt;

  /// Spoken response when there are no alerts
  ///
  /// In en, this message translates to:
  /// **'No alert today. Your fields look fine.'**
  String get voiceNoAlerts;

  /// Spoken response when farmer asks about field status without fields
  ///
  /// In en, this message translates to:
  /// **'Please add a field first.'**
  String get voiceNoFields;

  /// Feedback banner and speech for home command
  ///
  /// In en, this message translates to:
  /// **'Opening Home'**
  String get voiceOpeningHome;

  /// Feedback banner and speech for fields command
  ///
  /// In en, this message translates to:
  /// **'Opening My Fields'**
  String get voiceOpeningFields;

  /// Feedback banner and speech for alerts command
  ///
  /// In en, this message translates to:
  /// **'Opening Alerts'**
  String get voiceOpeningAlerts;

  /// Feedback banner and speech when navigating to an alert
  ///
  /// In en, this message translates to:
  /// **'Opening alert for {fieldName}'**
  String voiceOpeningAlertDetail(String fieldName);

  /// Banner when listen command is triggered
  ///
  /// In en, this message translates to:
  /// **'Reading screen'**
  String get voiceReadingScreen;

  /// Overall field telemetry voice response
  ///
  /// In en, this message translates to:
  /// **'{field}: Health is {health}, water is {water}, pest risk is {pest}.'**
  String voiceStatusReport(
      String field, String health, String water, String pest);

  /// Water status voice response
  ///
  /// In en, this message translates to:
  /// **'{field}: Water is {water}.'**
  String voiceStatusWaterReport(String field, String water);

  /// Pest status voice response
  ///
  /// In en, this message translates to:
  /// **'{field}: Pest risk is {pest}.'**
  String voiceStatusPestReport(String field, String pest);

  /// Health status voice response
  ///
  /// In en, this message translates to:
  /// **'{field}: Crop health is {health}.'**
  String voiceStatusHealthReport(String field, String health);

  /// Accessibility tooltip for mic button
  ///
  /// In en, this message translates to:
  /// **'Voice command'**
  String get voiceMicTooltip;

  /// Error message when saving a field or profile fails
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get saveFailed;

  /// Debug-only banner indicating local demo mode
  ///
  /// In en, this message translates to:
  /// **'Offline demo data'**
  String get debugOfflineDemo;

  /// Debug-only banner indicating live server connection
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get debugConnected;

  /// Calm chip shown on home when offline cache is displayed
  ///
  /// In en, this message translates to:
  /// **'Showing last saved field info'**
  String get offlineSavedInfoChip;

  /// Text button in alerts empty state opening SMS info
  ///
  /// In en, this message translates to:
  /// **'How will I get alerts?'**
  String get howWillIGetAlerts;

  /// Secondary button under Done in alert detail opening SMS info
  ///
  /// In en, this message translates to:
  /// **'Also sent as SMS'**
  String get alsoSentAsSms;

  /// Title of SMS explanation screen
  ///
  /// In en, this message translates to:
  /// **'Alerts on your phone'**
  String get smsScreenTitle;

  /// First explanation sentence about SMS alerts
  ///
  /// In en, this message translates to:
  /// **'If a field needs care, AgroSense can send a short SMS.'**
  String get smsSentence1;

  /// Second sentence showing masked sign in phone number
  ///
  /// In en, this message translates to:
  /// **'SMS will come to the number you used to sign in: {phone}'**
  String smsSentence2(String phone);

  /// Sample SMS text in current language
  ///
  /// In en, this message translates to:
  /// **'AgroSense: Water is low in Main field. Give water if the soil is dry.'**
  String get smsExampleMessage;

  /// SMS opt-in choice: On
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get smsOptInOn;

  /// Description for SMS On option
  ///
  /// In en, this message translates to:
  /// **'I want SMS'**
  String get smsOptInOnDesc;

  /// SMS opt-in choice: Off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get smsOptInOff;

  /// Description for SMS Off option
  ///
  /// In en, this message translates to:
  /// **'Only in the app'**
  String get smsOptInOffDesc;

  /// Speech text when SMS is enabled
  ///
  /// In en, this message translates to:
  /// **'SMS alerts are on.'**
  String get smsStatusOn;

  /// Speech text when SMS is disabled
  ///
  /// In en, this message translates to:
  /// **'SMS alerts are off.'**
  String get smsStatusOff;

  /// Notice when SMS preference is saved
  ///
  /// In en, this message translates to:
  /// **'Preference saved.'**
  String get smsSaveSuccess;

  /// Voice feedback when opening SMS info screen
  ///
  /// In en, this message translates to:
  /// **'Opening SMS alert info'**
  String get voiceOpeningSmsInfo;

  /// Label and tooltip for changing language
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// Farmer account screen title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Sign out button label
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Title for sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// Body message for sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'You will need your mobile number to sign in again.'**
  String get signOutConfirmBody;

  /// Button label to cancel sign out
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Notification when user signs out
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// Spoken prompt for language sheet
  ///
  /// In en, this message translates to:
  /// **'English. Hindi. Marathi.'**
  String get languagePrompt;

  /// Label for current language in account
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// Label for SMS alerts in account screen
  ///
  /// In en, this message translates to:
  /// **'SMS alerts'**
  String get smsAlerts;

  /// Voice announcement when opening account screen
  ///
  /// In en, this message translates to:
  /// **'Opening account'**
  String get voiceOpeningAccount;

  /// Label for text size option and tooltip
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// Small text size choice
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// Description for small text size
  ///
  /// In en, this message translates to:
  /// **'Compact view'**
  String get textSizeSmallDesc;

  /// Default text size choice
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textSizeDefault;

  /// Description for default text size
  ///
  /// In en, this message translates to:
  /// **'Standard readable size'**
  String get textSizeDefaultDesc;

  /// Large text size choice
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// Description for large text size
  ///
  /// In en, this message translates to:
  /// **'Bigger text for bright sunlight'**
  String get textSizeLargeDesc;

  /// Voice speech for text size sheet
  ///
  /// In en, this message translates to:
  /// **'Text size. Small. Default. Large.'**
  String get textSizePrompt;

  /// Accessibility label for field photo
  ///
  /// In en, this message translates to:
  /// **'Field photo'**
  String get semanticsFieldPhoto;

  /// Accessibility label for wheat header photo
  ///
  /// In en, this message translates to:
  /// **'Wheat field photo'**
  String get semanticsWheatField;

  /// Accessibility label for back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get semanticsBack;

  /// Accessibility label for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get semanticsClose;
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

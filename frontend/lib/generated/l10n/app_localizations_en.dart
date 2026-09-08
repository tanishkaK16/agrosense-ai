// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AgroSense';

  @override
  String get welcomeTitle => 'Grow smarter, worry less';

  @override
  String get welcomeSubtitle =>
      'Know what your crops need, before problems start.';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageMarathi => 'Marathi';

  @override
  String get continueLabel => 'Continue';

  @override
  String get getStarted => 'Get started';

  @override
  String get home => 'Home';

  @override
  String get myFields => 'My Fields';

  @override
  String get alerts => 'Alerts';

  @override
  String get comingSoon => 'More here soon';

  @override
  String get listen => 'Listen';

  @override
  String get good => 'Good';

  @override
  String get warning => 'Watch';

  @override
  String get danger => 'Act now';

  @override
  String get tapToStart => 'Tap a language to begin';

  @override
  String get helloFarmer => 'Welcome, farmer';

  @override
  String get onboarding1Title => 'Your field, in one look';

  @override
  String get onboarding1Body =>
      'The app shows which part of the crop is healthy and which part needs care.';

  @override
  String get onboarding2Title => 'Know before the crop looks sick';

  @override
  String get onboarding2Body =>
      'If water, pests, or weakness start, you get a simple alert.';

  @override
  String get onboarding3Title => 'Clear next step';

  @override
  String get onboarding3Body =>
      'Each alert tells you what to do today, in your language.';

  @override
  String get next => 'Next';

  @override
  String get start => 'Start';

  @override
  String get skip => 'Skip';

  @override
  String get tapContinueWhenReady => 'Tap continue when ready';

  @override
  String get phoneTitle => 'Your mobile number';

  @override
  String get phoneSubtitle => 'We will send a 4-digit code';

  @override
  String get phoneHint => '10-digit number';

  @override
  String get otpTitle => 'Enter the 4-digit code';

  @override
  String otpSubtitle(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get otpWrongCode => 'That code is not right. Try 1234 for now.';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get demoCodeNotice => 'Demo code 1234';

  @override
  String get profileTitle => 'Tell us about your farm';

  @override
  String get nameQuestion => 'What should we call you?';

  @override
  String get nameHint => 'Your name (optional)';

  @override
  String get villageQuestion => 'Your village or town?';

  @override
  String get villageHint => 'Village or town name';

  @override
  String get cropQuestion => 'Main crop?';

  @override
  String get cropRice => 'Rice';

  @override
  String get cropWheat => 'Wheat';

  @override
  String get cropCotton => 'Cotton';

  @override
  String get cropSugarcane => 'Sugarcane';

  @override
  String get cropSoybean => 'Soybean';

  @override
  String get cropOther => 'Other';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String helloName(String name) {
    return 'Hello, $name';
  }

  @override
  String get weatherTemp => 'Temp';

  @override
  String get weatherRain => 'Rain today';

  @override
  String get weatherWind => 'Wind';

  @override
  String get myFieldToday => 'My field today';

  @override
  String get healthyStatus => 'Healthy';

  @override
  String get watchStatus => 'Watch';

  @override
  String get actNowStatus => 'Act now';

  @override
  String get healthSummaryHealthy =>
      'Most of the crop looks fine. Check the dry corner tomorrow.';

  @override
  String get healthSummaryWatch =>
      'Soil moisture is dipping. Plan watering for tomorrow.';

  @override
  String get healthSummaryActNow =>
      'Crop stress detected. Inspect the field today.';

  @override
  String get noAlertsToday => 'No alert today';

  @override
  String alertsTapToSee(int count) {
    return '$count alert. Tap to see what to do.';
  }

  @override
  String homeSpeech(
      String greeting, int temp, int rain, String health, String alerts) {
    return '$greeting. Temperature $temp degrees. Rain $rain millimeter. Your field is $health. $alerts.';
  }

  @override
  String get noFieldsYet => 'No field yet';

  @override
  String get addFirstField => 'Add your first field';

  @override
  String get addField => 'Add field';

  @override
  String fieldsCount(int count) {
    return 'You have $count fields';
  }

  @override
  String get fieldsEmptySpeech => 'No field yet. Add your first field.';

  @override
  String get fieldNameLabel => 'Field name';

  @override
  String get fieldNameHint => 'Main field';

  @override
  String get selectCropQuestion => 'Which crop is grown here?';

  @override
  String get tapYourField => 'Tap your field';

  @override
  String get tapMapInstruction => 'Tap the map to drop a pin. You can move it.';

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get locationDeniedNotice =>
      'Location not shared. You can still tap the map to place your pin.';

  @override
  String get saveField => 'Save field';

  @override
  String get addFieldStep1Speech =>
      'Add field. Enter a name or leave it as Main field, choose your crop, and tap next.';

  @override
  String get addFieldStep2Speech =>
      'Tap your field. Tap the map to drop a pin. You can move it. Tap save field when done.';

  @override
  String get meterHealth => 'Health';

  @override
  String get meterWater => 'Water';

  @override
  String get meterPest => 'Pest';

  @override
  String get statusLow => 'Low';

  @override
  String get statusOkay => 'Okay';

  @override
  String get statusDry => 'Dry';

  @override
  String get statusRisk => 'Risk';

  @override
  String get legendHealthy => 'Healthy';

  @override
  String get legendWatch => 'Watch';

  @override
  String get legendNeedsCare => 'Needs care';

  @override
  String get detailSummaryAllGood => 'This field looks fine today.';

  @override
  String get detailSummaryWaterLow =>
      'Water is low. Give water if the soil is dry.';

  @override
  String get detailSummaryPestWatch => 'Pest risk is up. Walk the field today.';

  @override
  String get detailSummaryActNow =>
      'Crop needs care today. Check the stressed area.';

  @override
  String fieldDetailSpeech(
      String name, String health, String water, String pest, String summary) {
    return '$name. Health $health. Water $water. Pest $pest. $summary';
  }

  @override
  String get fieldsLookFine => 'Your fields look fine.';

  @override
  String get alertTimeToday => 'Today';

  @override
  String get alertProblemWaterLow => 'Water is low.';

  @override
  String get alertProblemWaterCritical => 'Soil is critically dry.';

  @override
  String get alertProblemPestWatch => 'Pest risk is up.';

  @override
  String get alertProblemPestCritical => 'High pest activity detected.';

  @override
  String get alertProblemHealthWatch => 'Crop weakness detected.';

  @override
  String get alertProblemHealthCritical => 'Severe crop stress detected.';

  @override
  String get alertActionWater => 'Give water if the soil is dry.';

  @override
  String get alertActionPest => 'Walk the field and look under leaves.';

  @override
  String get alertActionHealth => 'Inspect the weak corner shown on the field.';

  @override
  String get alertStepWater1 =>
      'Check soil moisture with your fingers near crop roots.';

  @override
  String get alertStepWater2 =>
      'Water in early morning or evening to reduce loss.';

  @override
  String get alertStepWater3 => 'Do not flood the field if unsure of drainage.';

  @override
  String get alertStepPest1 =>
      'Walk the field and inspect under leaves carefully.';

  @override
  String get alertStepPest2 =>
      'Pick and remove any visible pests or damaged leaves.';

  @override
  String get alertStepPest3 =>
      'Ask your local agriculture officer before spraying chemicals.';

  @override
  String get alertStepHealth1 =>
      'Check water moisture and pests in the field first.';

  @override
  String get alertStepHealth2 =>
      'Look at the weak corner shown on your field photo.';

  @override
  String get alertStepHealth3 =>
      'Ensure proper sunlight and soil aeration around roots.';

  @override
  String get alertHelpNotice =>
      'If it gets worse in 2 days, ask your local shop or officer.';

  @override
  String get whatToDoToday => 'What to do today';

  @override
  String get markDone => 'Done';

  @override
  String get seeWhatToDo => 'See what to do';

  @override
  String get alertsSpeechEmpty => 'No alert today. Your fields look fine.';

  @override
  String alertsSpeechCount(int count, String firstProblem, String fieldName) {
    return 'You have $count alerts. First: $firstProblem in $fieldName.';
  }

  @override
  String alertDetailSpeech(String problem, String steps, String help) {
    return '$problem. Steps for today: $steps. $help';
  }
}

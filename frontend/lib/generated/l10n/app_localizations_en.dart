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
}

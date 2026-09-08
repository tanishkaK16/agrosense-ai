// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'अॅग्रोसेन्स';

  @override
  String get welcomeTitle => 'हुशारीने पिकवा, काळजी कमी करा';

  @override
  String get welcomeSubtitle =>
      'समस्या येण्यापूर्वी जाणून घ्या पिकाला काय हवे आहे.';

  @override
  String get chooseLanguage => 'आपली भाषा निवडा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get continueLabel => 'पुढे जा';

  @override
  String get getStarted => 'सुरू करा';

  @override
  String get home => 'मुख्यपृष्ठ';

  @override
  String get myFields => 'माझे शेत';

  @override
  String get alerts => 'सूचना';

  @override
  String get comingSoon => 'लवकरच येत आहे';

  @override
  String get listen => 'ऐका';

  @override
  String get good => 'चांगले';

  @override
  String get warning => 'सावधान';

  @override
  String get danger => 'आत्ता कारवाई करा';

  @override
  String get tapToStart => 'सुरू करण्यासाठी भाषा निवडा';

  @override
  String get helloFarmer => 'नमस्कार, शेतकरी';

  @override
  String get onboarding1Title => 'एका दृष्टीक्षेपात तुमचे शेत';

  @override
  String get onboarding1Body =>
      'पिकाचा कोणता भाग चांगला आहे आणि कशाला काळजीची गरज आहे हे अॅप दाखवते.';

  @override
  String get onboarding2Title => 'पीक आजारी दिसण्यापूर्वी ओळखा';

  @override
  String get onboarding2Body =>
      'पाणी, कीड किंवा अशक्तपणा सुरू झाल्यास तुम्हाला सोपी सूचना मिळेल.';

  @override
  String get onboarding3Title => 'पुढचे पाऊल अगदी स्पष्ट';

  @override
  String get onboarding3Body =>
      'प्रत्येक सूचना आज काय करायचे ते तुमच्या भाषेत सांगते.';

  @override
  String get next => 'पुढे';

  @override
  String get start => 'सुरू करा';

  @override
  String get skip => 'वगळा';

  @override
  String get tapContinueWhenReady => 'तयार झाल्यावर पुढे जा दाबा';

  @override
  String get phoneTitle => 'तुमचा मोबाईल नंबर';

  @override
  String get phoneSubtitle => 'आम्ही ४-अंकी कोड पाठवू';

  @override
  String get phoneHint => '१० अंकी नंबर';

  @override
  String get otpTitle => '४-अंकी कोड टाका';

  @override
  String otpSubtitle(String phone) {
    return '$phone वर पाठवले';
  }

  @override
  String get otpWrongCode => 'हा कोड बरोबर नाही. सध्या 1234 वापरून पहा.';

  @override
  String get resendCode => 'कोड पुन्हा पाठवा';

  @override
  String resendCodeIn(int seconds) {
    return '$seconds सेकंदात पुन्हा पाठवा';
  }

  @override
  String get demoCodeNotice => 'डेमो कोड 1234';

  @override
  String get profileTitle => 'आपल्या शेतीबद्दल सांगा';

  @override
  String get nameQuestion => 'आम्ही तुम्हाला काय म्हणावे?';

  @override
  String get nameHint => 'तुमचे नाव (पर्यायी)';

  @override
  String get villageQuestion => 'तुमचे गाव किंवा शहर?';

  @override
  String get villageHint => 'गाव किंवा शहराचे नाव';

  @override
  String get cropQuestion => 'मुख्य पीक?';

  @override
  String get cropRice => 'भात (तांदूळ)';

  @override
  String get cropWheat => 'गहू';

  @override
  String get cropCotton => 'कापूस';

  @override
  String get cropSugarcane => 'ऊस';

  @override
  String get cropSoybean => 'सोयाबीन';

  @override
  String get cropOther => 'इतर';

  @override
  String get saveAndContinue => 'जतन करा आणि पुढे जा';
}

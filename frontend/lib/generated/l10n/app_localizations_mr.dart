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

  @override
  String helloName(String name) {
    return 'नमस्कार, $name';
  }

  @override
  String get weatherTemp => 'तापमान';

  @override
  String get weatherRain => 'आज पाऊस';

  @override
  String get weatherWind => 'वारा';

  @override
  String get myFieldToday => 'आज माझे शेत';

  @override
  String get healthyStatus => 'उत्तम';

  @override
  String get watchStatus => 'लक्ष ठेवा';

  @override
  String get actNowStatus => 'तातडीने कृती करा';

  @override
  String get healthSummaryHealthy =>
      'बहुतांश पीक चांगले दिसत आहे. उद्या कोरड्या भागाची पाहणी करा.';

  @override
  String get healthSummaryWatch =>
      'मातीतील ओलावा कमी होत आहे. उद्या पाणी देण्याचे नियोजन करा.';

  @override
  String get healthSummaryActNow =>
      'पिकावर ताण दिसून येत आहे. आजच शेताची पाहणी करा.';

  @override
  String get noAlertsToday => 'आज कोणतीही सूचना नाही';

  @override
  String alertsTapToSee(int count) {
    return '$count सूचना. काय करायचे ते पाहण्यासाठी दाबा.';
  }

  @override
  String homeSpeech(
      String greeting, int temp, int rain, String health, String alerts) {
    return '$greeting. तापमान $temp अंश. पाऊस $rain मिमी. तुमचे शेत $health आहे. $alerts.';
  }

  @override
  String get noFieldsYet => 'अजून कोणतेही शेत नाही';

  @override
  String get addFirstField => 'तुमचे पहिले शेत जोडा';

  @override
  String get addField => 'शेत जोडा';

  @override
  String fieldsCount(int count) {
    return 'तुमच्याकडे $count शेत आहेत';
  }

  @override
  String get fieldsEmptySpeech =>
      'अजून कोणतेही शेत नाही. पहिले शेत जोडण्यासाठी शेत जोडा दाबा.';

  @override
  String get fieldNameLabel => 'शेताचे नाव';

  @override
  String get fieldNameHint => 'मुख्य शेत';

  @override
  String get selectCropQuestion => 'येथे कोणते पीक घेतले जाते?';

  @override
  String get tapYourField => 'तुमच्या शेतावर टॅप करा';

  @override
  String get tapMapInstruction =>
      'पिन ठेवण्यासाठी नकाशावर टॅप करा. तुम्ही ती हलवू शकता.';

  @override
  String get useMyLocation => 'माझे स्थान वापरा';

  @override
  String get locationDeniedNotice =>
      'स्थान मिळाले नाही. तुम्ही नकाशावर टॅप करून पिन ठेवू शकता.';

  @override
  String get saveField => 'शेत जतन करा';

  @override
  String get addFieldStep1Speech =>
      'शेत जोडा. नाव प्रविष्ट करा किंवा मुख्य शेत राहू द्या, आपले पीक निवडा, आणि पुढे दाबा.';

  @override
  String get addFieldStep2Speech =>
      'तुमच्या शेतावर टॅप करा. नकाशावर पिन ठेवा. तुम्ही ती हलवू शकता. पूर्ण झाल्यावर शेत जतन करा दाबा.';

  @override
  String get meterHealth => 'आरोग्य';

  @override
  String get meterWater => 'पाणी';

  @override
  String get meterPest => 'कीड';

  @override
  String get statusLow => 'कमी';

  @override
  String get statusOkay => 'ठीक';

  @override
  String get statusDry => 'कोरडी';

  @override
  String get statusRisk => 'धोका';

  @override
  String get legendHealthy => 'उत्तम';

  @override
  String get legendWatch => 'लक्ष ठेवा';

  @override
  String get legendNeedsCare => 'काळजीची गरज';

  @override
  String get detailSummaryAllGood => 'हे शेत आज उत्तम दिसत आहे.';

  @override
  String get detailSummaryWaterLow =>
      'पाणी कमी आहे. माती कोरडी असल्यास पाणी द्या.';

  @override
  String get detailSummaryPestWatch =>
      'कीडीचा धोका वाढला आहे. आजच शेतात फेरफटका मारा.';

  @override
  String get detailSummaryActNow =>
      'पिकाला आज काळजीची गरज आहे. बाधित भागाची पाहणी करा.';

  @override
  String fieldDetailSpeech(
      String name, String health, String water, String pest, String summary) {
    return '$name. आरोग्य $health. पाणी $water. कीड $pest. $summary';
  }
}

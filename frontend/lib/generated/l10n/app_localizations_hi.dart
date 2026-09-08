// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'एग्रोसेंस';

  @override
  String get welcomeTitle => 'समझदारी से उगाएं, चिंता कम करें';

  @override
  String get welcomeSubtitle =>
      'समस्या आने से पहले जानें कि आपकी फसल को क्या चाहिए।';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get home => 'होम';

  @override
  String get myFields => 'मेरे खेत';

  @override
  String get alerts => 'चेतावनी';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get listen => 'सुनें';

  @override
  String get good => 'अच्छा';

  @override
  String get warning => 'सावधान';

  @override
  String get danger => 'तुरंत कार्रवाई करें';

  @override
  String get tapToStart => 'शुरू करने के लिए भाषा चुनें';

  @override
  String get helloFarmer => 'नमस्ते, किसान';

  @override
  String get onboarding1Title => 'एक नज़र में आपका खेत';

  @override
  String get onboarding1Body =>
      'ऐप बताता है कि फसल का कौन सा हिस्सा स्वस्थ है और किसे देखभाल की ज़रूरत है।';

  @override
  String get onboarding2Title => 'बीमारी दिखने से पहले जानें';

  @override
  String get onboarding2Body =>
      'पानी की कमी, कीड़े या कमज़ोरी शुरू होते ही आपको आसान चेतावनी मिलेगी।';

  @override
  String get onboarding3Title => 'सीधा और आसान अगला कदम';

  @override
  String get onboarding3Body =>
      'हर सूचना आपको बताती है कि आज क्या करना है, आपकी अपनी भाषा में।';

  @override
  String get next => 'आगे';

  @override
  String get start => 'शुरू करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get tapContinueWhenReady => 'तैयार होने पर आगे बढ़ें दबाएं';

  @override
  String get phoneTitle => 'आपका मोबाइल नंबर';

  @override
  String get phoneSubtitle => 'हम 4 अंकों का कोड भेजेंगे';

  @override
  String get phoneHint => '10 अंकों का नंबर';

  @override
  String get otpTitle => '4 अंकों का कोड दर्ज करें';

  @override
  String otpSubtitle(String phone) {
    return '$phone पर भेजा गया';
  }

  @override
  String get otpWrongCode => 'यह कोड सही नहीं है। अभी 1234 आज़माएं।';

  @override
  String get resendCode => 'कोड फिर से भेजें';

  @override
  String resendCodeIn(int seconds) {
    return '$seconds सेकंड में फिर भेजें';
  }

  @override
  String get demoCodeNotice => 'डेमो कोड 1234';

  @override
  String get profileTitle => 'अपने खेत के बारे में बताएं';

  @override
  String get nameQuestion => 'हम आपको क्या बुलाएं?';

  @override
  String get nameHint => 'आपका नाम (वैकल्पिक)';

  @override
  String get villageQuestion => 'आपका गांव या शहर?';

  @override
  String get villageHint => 'गांव या शहर का नाम';

  @override
  String get cropQuestion => 'मुख्य फसल?';

  @override
  String get cropRice => 'चावल';

  @override
  String get cropWheat => 'गेहूं';

  @override
  String get cropCotton => 'कपास';

  @override
  String get cropSugarcane => 'गन्ना';

  @override
  String get cropSoybean => 'सोयाबीन';

  @override
  String get cropOther => 'अन्य';

  @override
  String get saveAndContinue => 'सहेजें और आगे बढ़ें';

  @override
  String helloName(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get weatherTemp => 'तापमान';

  @override
  String get weatherRain => 'आज बारिश';

  @override
  String get weatherWind => 'हवा';

  @override
  String get myFieldToday => 'आज मेरा खेत';

  @override
  String get healthyStatus => 'स्वस्थ';

  @override
  String get watchStatus => 'सावधान';

  @override
  String get actNowStatus => 'तुरंत कदम उठाएं';

  @override
  String get healthSummaryHealthy =>
      'ज़्यादातर फसल ठीक दिख रही है। कल सूखे कोने को देखें।';

  @override
  String get healthSummaryWatch =>
      'मिट्टी की नमी कम हो रही है। कल पानी देने की योजना बनाएं।';

  @override
  String get healthSummaryActNow =>
      'फसल में तनाव के लक्षण हैं। आज ही खेत का मुआयना करें।';

  @override
  String get noAlertsToday => 'आज कोई चेतावनी नहीं';

  @override
  String alertsTapToSee(int count) {
    return '$count चेतावनी। क्या करना है देखने के लिए दबाएं।';
  }

  @override
  String homeSpeech(
      String greeting, int temp, int rain, String health, String alerts) {
    return '$greeting। तापमान $temp अंश। बारिश $rain मिलीमीटर। आपका खेत $health है। $alerts।';
  }

  @override
  String get noFieldsYet => 'अभी कोई खेत नहीं है';

  @override
  String get addFirstField => 'अपना पहला खेत जोड़ें';

  @override
  String get addField => 'खेत जोड़ें';

  @override
  String fieldsCount(int count) {
    return 'आपके पास $count खेत हैं';
  }

  @override
  String get fieldsEmptySpeech =>
      'अभी कोई खेत नहीं है। अपना पहला खेत जोड़ने के लिए खेत जोड़ें दबाएं।';

  @override
  String get fieldNameLabel => 'खेत का नाम';

  @override
  String get fieldNameHint => 'मुख्य खेत';

  @override
  String get selectCropQuestion => 'यहाँ कौन सी फसल उगाई जाती है?';

  @override
  String get tapYourField => 'अपने खेत पर टैप करें';

  @override
  String get tapMapInstruction =>
      'पिन लगाने के लिए नक्शे पर टैप करें। आप इसे हिला सकते हैं।';

  @override
  String get useMyLocation => 'मेरी लोकेशन का उपयोग करें';

  @override
  String get locationDeniedNotice =>
      'लोकेशन नहीं मिली। आप नक्शे पर टैप करके पिन लगा सकते हैं।';

  @override
  String get saveField => 'खेत सहेजें';

  @override
  String get addFieldStep1Speech =>
      'खेत जोड़ें। नाम दर्ज करें या मुख्य खेत रहने दें, अपनी फसल चुनें, और आगे दबाएं।';

  @override
  String get addFieldStep2Speech =>
      'अपने खेत पर टैप करें। नक्शे पर पिन लगाएं। आप इसे हिला सकते हैं। पूरा होने पर खेत सहेजें दबाएं।';

  @override
  String get meterHealth => 'स्वास्थ्य';

  @override
  String get meterWater => 'पानी';

  @override
  String get meterPest => 'कीट';

  @override
  String get statusLow => 'कम';

  @override
  String get statusOkay => 'ठीक';

  @override
  String get statusDry => 'सूखा';

  @override
  String get statusRisk => 'जोखिम';

  @override
  String get legendHealthy => 'स्वस्थ';

  @override
  String get legendWatch => 'सावधान';

  @override
  String get legendNeedsCare => 'देखभाल चाहिए';

  @override
  String get detailSummaryAllGood => 'यह खेत आज बिल्कुल ठीक दिख रहा है।';

  @override
  String get detailSummaryWaterLow => 'पानी कम है। मिट्टी सूखी हो तो पानी दें।';

  @override
  String get detailSummaryPestWatch =>
      'कीट का खतरा बढ़ गया है। आज ही खेत का मुआयना करें।';

  @override
  String get detailSummaryActNow =>
      'फसल को आज देखभाल की ज़रूरत है। प्रभावित हिस्से की जाँच करें।';

  @override
  String fieldDetailSpeech(
      String name, String health, String water, String pest, String summary) {
    return '$name। स्वास्थ्य $health। पानी $water। कीट $pest। $summary';
  }

  @override
  String get fieldsLookFine => 'आपके सभी खेत ठीक दिख रहे हैं।';

  @override
  String get alertTimeToday => 'आज';

  @override
  String get alertProblemWaterLow => 'पानी कम है।';

  @override
  String get alertProblemWaterCritical => 'मिट्टी बहुत सूखी है।';

  @override
  String get alertProblemPestWatch => 'कीट का खतरा बढ़ गया है।';

  @override
  String get alertProblemPestCritical => 'कीटों का भारी प्रकोप है।';

  @override
  String get alertProblemHealthWatch => 'फसल में कमज़ोरी दिख रही है।';

  @override
  String get alertProblemHealthCritical => 'फसल पर गहरा तनाव है।';

  @override
  String get alertActionWater => 'मिट्टी सूखी हो तो पानी दें।';

  @override
  String get alertActionPest => 'खेत में जाकर पत्तियों के नीचे देखें।';

  @override
  String get alertActionHealth => 'खेत के कमज़ोर हिस्से की जाँच करें।';

  @override
  String get alertStepWater1 => 'जड़ों के पास उंगली से मिट्टी की नमी जांचें।';

  @override
  String get alertStepWater2 => 'सुबह या शाम के समय ही पानी दें।';

  @override
  String get alertStepWater3 =>
      'अगर जल निकासी का भरोसा न हो तो ज़्यादा पानी न भरें।';

  @override
  String get alertStepPest1 =>
      'खेत में घूमें और पत्तियों के नीचे ध्यान से देखें।';

  @override
  String get alertStepPest2 => 'दिखने वाले कीड़ों या खराब पत्तियों को हटा दें।';

  @override
  String get alertStepPest3 =>
      'दवा छिड़कने से पहले स्थानीय कृषि अधिकारी से सलाह लें।';

  @override
  String get alertStepHealth1 => 'पहले खेत में पानी और कीटों की स्थिति जांचें।';

  @override
  String get alertStepHealth2 =>
      'फोटो में दिखाए गए कमज़ोर हिस्से का मुआयना करें।';

  @override
  String get alertStepHealth3 =>
      'जड़ों के पास पर्याप्त हवा और धूप सुनिश्चित करें।';

  @override
  String get alertHelpNotice =>
      'अगर 2 दिनों में समस्या बढ़े, तो स्थानीय दुकान या अधिकारी से पूछें।';

  @override
  String get whatToDoToday => 'आज क्या करें';

  @override
  String get markDone => 'पूरा हुआ';

  @override
  String get seeWhatToDo => 'क्या करना है देखें';

  @override
  String get alertsSpeechEmpty => 'आज कोई चेतावनी नहीं। आपके खेत ठीक हैं।';

  @override
  String alertsSpeechCount(int count, String firstProblem, String fieldName) {
    return 'आपके पास $count सूचनाएँ हैं। पहली: $fieldName में $firstProblem';
  }

  @override
  String alertDetailSpeech(String problem, String steps, String help) {
    return '$problem। आज के कदम: $steps। $help';
  }

  @override
  String get voiceListening => 'सुन रहे हैं...';

  @override
  String get voiceStop => 'रोकें';

  @override
  String get voicePermissionDenied =>
      'आपकी आवाज़ सुनने के लिए माइक्रोफ़ोन की अनुमति चाहिए।';

  @override
  String get voiceNotUnderstood =>
      'समझ नहीं आया। घर, खेत, चेतावनी, या क्या करें कहें।';

  @override
  String get voiceHelpPrompt =>
      'आप घर, मेरे खेत, चेतावनी, या क्या करें कह सकते हैं।';

  @override
  String get voiceNoAlerts => 'आज कोई चेतावनी नहीं। आपके खेत ठीक हैं।';

  @override
  String get voiceNoFields => 'कृपया पहले एक खेत जोड़ें।';

  @override
  String get voiceOpeningHome => 'मुख्य पृष्ठ खोल रहे हैं';

  @override
  String get voiceOpeningFields => 'मेरे खेत खोल रहे हैं';

  @override
  String get voiceOpeningAlerts => 'चेतावनी पृष्ठ खोल रहे हैं';

  @override
  String voiceOpeningAlertDetail(String fieldName) {
    return '$fieldName के लिए चेतावनी खोल रहे हैं';
  }

  @override
  String get voiceReadingScreen => 'पृष्ठ पढ़कर सुना रहे हैं';

  @override
  String voiceStatusReport(
      String field, String health, String water, String pest) {
    return '$field: स्वास्थ्य $health है, पानी $water है, और कीट $pest है।';
  }

  @override
  String voiceStatusWaterReport(String field, String water) {
    return '$field: पानी $water है।';
  }

  @override
  String voiceStatusPestReport(String field, String pest) {
    return '$field: कीट $pest है।';
  }

  @override
  String voiceStatusHealthReport(String field, String health) {
    return '$field: फसल का स्वास्थ्य $health है।';
  }

  @override
  String get voiceMicTooltip => 'बोलकर आदेश दें';

  @override
  String get saveFailed => 'सहेजा नहीं जा सका। फिर से प्रयास करें।';

  @override
  String get debugOfflineDemo => 'ऑफ़लाइन डेमो डेटा';

  @override
  String get debugConnected => 'सर्वर से जुड़ा हुआ है';
}

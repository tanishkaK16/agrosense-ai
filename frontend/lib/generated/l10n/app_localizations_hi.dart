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
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/app.dart';
import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/onboarding/onboarding_page.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'setSpeechRate':
        case 'setVolume':
        case 'setPitch':
        case 'stop':
        case 'speak':
        case 'setLanguage':
          return 1;
        case 'isLanguageAvailable':
          return 1;
        default:
          return null;
      }
    });

    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    await LocaleController.instance.init();
  });

  tearDown(() async {
    await AppPrefs.instance.clear();
    await LocaleController.instance.clear();
    await VoiceService.instance.stop();
  });

  group('AppPrefs & LocaleController Tests', () {
    test('AppPrefs stores and retrieves onboarding state and locale', () async {
      expect(AppPrefs.instance.isOnboardingDone, isFalse);
      expect(AppPrefs.instance.localeCode, isNull);

      await AppPrefs.instance.setLocaleCode('hi');
      expect(AppPrefs.instance.localeCode, equals('hi'));

      await AppPrefs.instance.setOnboardingDone(true);
      expect(AppPrefs.instance.isOnboardingDone, isTrue);

      await AppPrefs.instance.clear();
      expect(AppPrefs.instance.isOnboardingDone, isFalse);
      expect(AppPrefs.instance.localeCode, isNull);
    });

    test('LocaleController integrates with AppPrefs', () async {
      expect(LocaleController.instance.hasLocale, isFalse);

      await LocaleController.instance.setLocale(const Locale('mr'));
      expect(LocaleController.instance.hasLocale, isTrue);
      expect(LocaleController.instance.locale?.languageCode, equals('mr'));
      expect(AppPrefs.instance.localeCode, equals('mr'));
    });
  });

  group('Onboarding Content Tests', () {
    test('Exactly 3 onboarding pages defined with valid asset paths', () {
      expect(kOnboardingPages.length, equals(3));

      // Screen 1: no skip
      expect(kOnboardingPages[0].canSkip, isFalse);
      expect(kOnboardingPages[0].imagePath, contains('hero_field_wide'));

      // Screen 2: allows skip
      expect(kOnboardingPages[1].canSkip, isTrue);
      expect(kOnboardingPages[1].imagePath, contains('hero_canopy_green'));

      // Screen 3: allows skip
      expect(kOnboardingPages[2].canSkip, isTrue);
      expect(kOnboardingPages[2].imagePath, contains('hero_soil_hands'));
    });
  });

  group('VoiceService Tests', () {
    test('VoiceService singleton exists and manages speech state', () async {
      final voice = VoiceService.instance;
      expect(voice.isSpeaking, isFalse);

      await voice.stop();
      expect(voice.isSpeaking, isFalse);
    });
  });

  group('Flow Tests', () {
    testWidgets(
        'Full flow: /language -> select -> Continue -> /onboarding -> Start -> Home',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // On initial load without locale: Language screen is visible
      expect(find.text('Choose your language'), findsOneWidget);

      // Select Hindi
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();

      // The UI immediately preview-updates to Hindi!
      expect(find.text('अपनी भाषा चुनें'), findsOneWidget);

      // Scroll and tap Continue
      final continueBtn = find.text('आगे बढ़ें');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Should now be on Onboarding Screen 1
      expect(find.text('एक नज़र में आपका खेत'), findsOneWidget);

      // Tap Next to advance to Screen 2
      await tester.tap(find.text('आगे'));
      await tester.pumpAndSettle();

      // Screen 2
      expect(find.text('बीमारी दिखने से पहले जानें'), findsOneWidget);
      expect(find.text('छोड़ें'), findsOneWidget);

      // Tap Next to advance to Screen 3
      await tester.tap(find.text('आगे'));
      await tester.pumpAndSettle();

      // Screen 3
      expect(find.text('सीधा और आसान अगला कदम'), findsOneWidget);
      expect(find.text('शुरू करें'), findsOneWidget);

      // Tap Start
      await tester.tap(find.text('शुरू करें'));
      await tester.pumpAndSettle();

      // Onboarding is marked done and user is redirected to phone screen
      expect(AppPrefs.instance.isOnboardingDone, isTrue);
      expect(find.text('आपका मोबाइल नंबर'), findsOneWidget);
    });

    testWidgets('Skip button on screen 2 completes onboarding and lands on /phone',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // Select English
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();

      final continueBtn = find.text('Continue');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Screen 1: Skip should not be present
      expect(find.text('Skip'), findsNothing);

      // Advance to Screen 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Screen 2: Skip is present
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Onboarding marked done and user on Phone screen
      expect(AppPrefs.instance.isOnboardingDone, isTrue);
      expect(find.text('Your mobile number'), findsOneWidget);
    });
  });
}

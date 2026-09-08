import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/app.dart';
import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/auth/data/mock_auth_repository.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/home/home_screen.dart';

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

  group('MockAuthRepository Tests', () {
    test('requestOtp, verifyOtp with 1234, saveProfile, and session retrieval',
        () async {
      final repo = MockAuthRepository.instance;

      expect(repo.isLoggedIn, isFalse);
      expect(repo.currentSession(), isNull);
      expect(repo.currentProfile(), isNull);

      final requested = await repo.requestOtp('9876543210');
      expect(requested, isTrue);

      // Wrong code returns null
      final wrongSession = await repo.verifyOtp('9876543210', '0000');
      expect(wrongSession, isNull);
      expect(repo.isLoggedIn, isFalse);

      // Correct code returns session
      final session = await repo.verifyOtp('9876543210', '1234');
      expect(session, isNotNull);
      expect(session?.phoneNumber, equals('9876543210'));
      expect(repo.isLoggedIn, isTrue);

      // Save profile
      const profile = FarmerProfile(
        name: 'Ramesh',
        village: 'Pune',
        mainCrop: 'wheat',
      );
      await repo.saveProfile(profile);

      final retrievedProfile = repo.currentProfile();
      expect(retrievedProfile, isNotNull);
      expect(retrievedProfile?.name, equals('Ramesh'));
      expect(retrievedProfile?.village, equals('Pune'));
      expect(retrievedProfile?.mainCrop, equals('wheat'));
      expect(retrievedProfile?.isComplete, isTrue);
    });
  });

  group('Phase 2 Full Flow Tests', () {
    testWidgets(
        'Full flow: /language -> /onboarding -> /phone -> /otp -> /profile -> / (Home)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // 1. Language Screen
      expect(find.text('Choose your language'), findsOneWidget);
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();

      final continueBtn = find.text('Continue');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // 2. Onboarding Screen 1
      expect(find.text('Your field, in one look'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Skip on screen 2
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // 3. Phone Screen
      expect(find.text('Your mobile number'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);

      // Enter 10 digits
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pumpAndSettle();

      // Tap continue
      final phoneContinue = find.text('Continue');
      await tester.ensureVisible(phoneContinue);
      await tester.tap(phoneContinue);
      await tester.pumpAndSettle();

      // 4. OTP Screen
      expect(find.text('Enter the 4-digit code'), findsOneWidget);
      expect(find.textContaining('+91 98*** **10'), findsOneWidget);

      // Enter invalid OTP
      await tester.enterText(find.byType(TextField), '9999');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(
        find.text('That code is not right. Try 1234 for now.'),
        findsOneWidget,
      );

      // Enter valid OTP (1234)
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // 5. Profile Screen
      expect(find.text('Tell us about your farm'), findsOneWidget);
      expect(find.text('What should we call you?'), findsOneWidget);
      expect(find.text('Main crop?'), findsOneWidget);

      // Fill name
      final nameField = find.widgetWithText(TextField, 'Your name (optional)');
      await tester.enterText(nameField, 'Anand');
      await tester.pumpAndSettle();

      // Select Wheat crop
      await tester.tap(find.text('Wheat'));
      await tester.pumpAndSettle();

      // Save and continue
      final saveBtn = find.text('Save and continue');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // 6. Home Screen reached with personalized greeting
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Hello, Anand'), findsOneWidget);
    });

    testWidgets('Back button from OTP preserves phone number', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Preset locale and onboarding complete so it opens on PhoneScreen
      await AppPrefs.instance.setLocaleCode('en');
      await LocaleController.instance.init();
      await AppPrefs.instance.setOnboardingDone(true);

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      expect(find.text('Your mobile number'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '9123456789');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Enter the 4-digit code'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Back on phone screen with digits preserved
      expect(find.text('Your mobile number'), findsOneWidget);
      expect(find.text('9123456789'), findsOneWidget);
    });
  });
}

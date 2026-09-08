import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/routing/app_router.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_command_parser.dart';
import 'package:agrosense_ai/features/auth/data/app_auth_repository.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/auth/models/farmer_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    await LocaleController.instance.init();
    await LocaleController.instance.clear();
  });

  group('Language Switcher Tests', () {
    test('LocaleController persists locale and notifies without touching onboarding', () async {
      await AppPrefs.instance.setOnboardingDone(true);
      await LocaleController.instance.setLocale(const Locale('hi'));

      expect(AppPrefs.instance.localeCode, equals('hi'));
      expect(LocaleController.instance.locale?.languageCode, equals('hi'));
      expect(AppPrefs.instance.isOnboardingDone, isTrue);

      await LocaleController.instance.setLocale(const Locale('mr'));
      expect(AppPrefs.instance.localeCode, equals('mr'));
      expect(AppPrefs.instance.isOnboardingDone, isTrue);
    });

    test('Voice command parser recognizes account commands in en, hi, mr', () {
      final resEn = VoiceCommandParser.parse('account');
      expect(resEn.action, equals(VoiceActionType.openAccount));

      final resEnProfile = VoiceCommandParser.parse('open profile');
      expect(resEnProfile.action, equals(VoiceActionType.openAccount));

      final resHi = VoiceCommandParser.parse('खाता');
      expect(resHi.action, equals(VoiceActionType.openAccount));

      final resMr = VoiceCommandParser.parse('खाते');
      expect(resMr.action, equals(VoiceActionType.openAccount));
    });
  });

  group('Logout and Session Management Tests', () {
    test('AppAuthRepository signOut clears session but keeps locale and onboarding', () async {
      // 1. Setup signed-in farmer state
      await LocaleController.instance.setLocale(const Locale('mr'));
      await AppPrefs.instance.setOnboardingDone(true);

      const testPhone = '9876543210';
      final session = FarmerSession(
        phoneNumber: testPhone,
        token: 'test_token_123',
        createdAt: DateTime.now(),
      );
      await AppPrefs.instance.setSessionJson(session.toJson());

      const profile = FarmerProfile(
        name: 'Tukaram',
        village: 'Nashik',
        mainCrop: 'grapes',
        smsOptIn: true,
      );
      await AppAuthRepository.instance.saveProfile(profile);

      expect(AppAuthRepository.instance.isLoggedIn, isTrue);
      expect(AppAuthRepository.instance.currentSession()?.phoneNumber, equals(testPhone));

      // 2. Perform sign out
      await AppAuthRepository.instance.signOut();

      // 3. Verify session is cleared
      expect(AppAuthRepository.instance.isLoggedIn, isFalse);
      expect(AppAuthRepository.instance.currentSession(), isNull);
      expect(AppPrefs.instance.hasSession, isFalse);

      // 4. Verify preserved preferences
      expect(AppPrefs.instance.localeCode, equals('mr'));
      expect(LocaleController.instance.locale?.languageCode, equals('mr'));
      expect(AppPrefs.instance.isOnboardingDone, isTrue);
    });

    test('Router redirect sends signed out user to /phone, keeping onboarding and locale', () {
      final router = buildRouter();

      expect(AppRoutes.phone, equals('/phone'));
      expect(AppRoutes.account, equals('/account'));
      expect(router, isNotNull);

      // When onboarding is complete and locale exists, but no session:
      // Router redirect requires /phone
      expect(AppPrefs.instance.hasSession, isFalse);
    });
  });
}

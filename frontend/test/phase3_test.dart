import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/app.dart';
import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/alerts/alerts_screen.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/auth/models/farmer_session.dart';
import 'package:agrosense_ai/features/fields/fields_screen.dart';
import 'package:agrosense_ai/features/home/data/mock_home_repository.dart';
import 'package:agrosense_ai/features/home/home_screen.dart';
import 'package:agrosense_ai/features/home/models/home_snapshot.dart';

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

  group('MockHomeRepository Tests', () {
    test('MockHomeRepository returns calm, healthy snapshot by default',
        () async {
      final repo = MockHomeRepository.instance;
      final snapshot = await repo.getHomeSnapshot(defaultCrop: 'cotton');

      expect(snapshot.temperatureC, equals(32));
      expect(snapshot.rainMm, equals(0));
      expect(snapshot.windKmh, equals(12));
      expect(snapshot.crop, equals('cotton'));
      expect(snapshot.health, equals(FieldHealth.healthy));
      expect(snapshot.alertCount, equals(0));
    });
  });

  group('HomeScreen UI & Interactions Tests', () {
    testWidgets('Displays greeting, village, weather strip, field card, and alerts card',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Preset session & profile so app opens directly on HomeScreen
      await AppPrefs.instance.setLocaleCode('en');
      await LocaleController.instance.init();
      await AppPrefs.instance.setOnboardingDone(true);
      await AppPrefs.instance.setSessionJson(
        FarmerSession(
          phoneNumber: '9876543210',
          token: 'token_123',
          createdAt: DateTime.now(),
        ).toJson(),
      );
      await AppPrefs.instance.setProfileJson(
        const FarmerProfile(
          name: 'Sunil',
          village: 'Baramati',
          mainCrop: 'sugarcane',
        ).toJson(),
      );

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      // 1. Top Section: Greeting & Village
      expect(find.text('Hello, Sunil'), findsOneWidget);
      expect(find.text('Baramati'), findsOneWidget);

      // 2. Weather Strip
      expect(find.text('32°'), findsOneWidget);
      expect(find.text('Temp'), findsOneWidget);
      expect(find.text('0 mm'), findsOneWidget);
      expect(find.text('Rain today'), findsOneWidget);
      expect(find.text('12 km/h'), findsOneWidget);
      expect(find.text('Wind'), findsOneWidget);

      // 3. Main Field Card
      expect(find.text('My field today'), findsOneWidget);
      expect(find.text('Sugarcane'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(
        find.text(
          'Most of the crop looks fine. Check the dry corner tomorrow.',
        ),
        findsOneWidget,
      );

      // 4. Alerts Card
      expect(find.text('No alert today'), findsOneWidget);

      // 5. Tap on Main Card navigates to Fields Tab
      await tester.tap(find.text('My field today'));
      await tester.pumpAndSettle();
      expect(find.byType(FieldsScreen), findsOneWidget);

      // Return to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // 6. Tap on Alerts Card navigates to Alerts Tab
      await tester.tap(find.text('No alert today'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertsScreen), findsOneWidget);
    });
  });
}

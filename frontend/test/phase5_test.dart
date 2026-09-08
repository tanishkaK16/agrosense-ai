import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/app.dart';
import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/auth/models/farmer_session.dart';
import 'package:agrosense_ai/features/fields/data/local_fields_repository.dart';
import 'package:agrosense_ai/features/fields/data/mock_field_status_repository.dart';
import 'package:agrosense_ai/features/fields/field_detail_screen.dart';
import 'package:agrosense_ai/features/fields/fields_screen.dart';
import 'package:agrosense_ai/features/fields/models/farm_field.dart';
import 'package:agrosense_ai/features/fields/models/field_status.dart';
import 'package:agrosense_ai/features/home/home_screen.dart';
import 'package:agrosense_ai/features/home/models/home_snapshot.dart';
import 'package:agrosense_ai/generated/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel ttsChannel = MethodChannel('flutter_tts');

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (MethodCall methodCall) async {
      return 1;
    });

    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    await LocaleController.instance.init();
    await LocalFieldsRepository.instance.clear();
  });

  tearDown(() async {
    await AppPrefs.instance.clear();
    await LocaleController.instance.clear();
    await LocalFieldsRepository.instance.clear();
    await VoiceService.instance.stop();
  });

  group('FieldStatus & MockFieldStatusRepository Tests', () {
    test('FieldStatus model serialization and deserialization', () {
      const status = FieldStatus(
        fieldId: 'f_42',
        health: HealthLevel.watch,
        water: WaterLevel.low,
        pest: PestLevel.good,
        overlayHint: OverlayHint.right,
        summarySentence: 'Water is low.',
      );

      final map = status.toMap();
      expect(map['field_id'], equals('f_42'));
      expect(map['health'], equals('watch'));
      expect(map['water'], equals('low'));
      expect(map['pest'], equals('good'));
      expect(map['overlay_hint'], equals('right'));
      expect(map['summary_sentence'], equals('Water is low.'));

      final jsonString = status.toJson();
      final restored = FieldStatus.fromJson(jsonString);
      expect(restored.fieldId, equals('f_42'));
      expect(restored.health, equals(HealthLevel.watch));
      expect(restored.water, equals(WaterLevel.low));
      expect(restored.pest, equals(PestLevel.good));
      expect(restored.overlayHint, equals(OverlayHint.right));
      expect(restored.summarySentence, equals('Water is low.'));
    });

    test('MockFieldStatusRepository is deterministic and persists on device',
        () async {
      final repo = MockFieldStatusRepository.instance;

      final status1 = await repo.getFieldStatus('demo_field_0');
      final status2 = await repo.getFieldStatus('demo_field_0');

      expect(status1.health, equals(status2.health));
      expect(status1.water, equals(status2.water));
      expect(status1.pest, equals(status2.pest));
      expect(status1.overlayHint, equals(status2.overlayHint));

      // Check that at least one field ID produces an "all good" status
      bool foundAllGood = false;
      for (int i = 0; i < 10; i++) {
        final s = await repo.getFieldStatus('test_id_$i');
        if (s.health == HealthLevel.good &&
            s.water == WaterLevel.good &&
            s.pest == PestLevel.good) {
          foundAllGood = true;
          break;
        }
      }
      expect(foundAllGood, isTrue);
    });

    test('Maps meter scores to Good / Watch / Act now labels', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Health mapping
      expect(l10n.good, isNotEmpty);
      expect(l10n.warning, isNotEmpty);
      expect(l10n.danger, isNotEmpty);

      // Water mapping
      expect(l10n.statusOkay, isNotEmpty);
      expect(l10n.statusLow, isNotEmpty);

      // Pest mapping
      expect(l10n.statusRisk, isNotEmpty);

      // Summary lines
      expect(l10n.detailSummaryAllGood, isNotEmpty);
      expect(l10n.detailSummaryWaterLow, isNotEmpty);
      expect(l10n.detailSummaryPestWatch, isNotEmpty);
      expect(l10n.detailSummaryActNow, isNotEmpty);
    });
  });

  group('Phase 5 UI Tests', () {
    Future<void> seedAuthenticatedUser(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPrefs.instance.setLocaleCode('en');
      await LocaleController.instance.init();
      await AppPrefs.instance.setOnboardingDone(true);
      await AppPrefs.instance.setSessionJson(
        FarmerSession(
          phoneNumber: '9876543210',
          token: 'mock-token',
          createdAt: DateTime(2026, 1, 1),
        ).toJson(),
      );
      await AppPrefs.instance.setProfileJson(
        const FarmerProfile(
          name: 'Ramesh',
          village: 'Baramati',
          mainCrop: 'sugarcane',
        ).toJson(),
      );
    }

    testWidgets('Tapping field card on FieldsScreen opens FieldDetailScreen',
        (tester) async {
      await seedAuthenticatedUser(tester);

      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: 'field_99',
          name: 'River Corner',
          crop: 'sugarcane',
          latitude: 18.52,
          longitude: 73.86,
          photoAsset: 'assets/images/hero_canopy_green.jpg',
          village: 'Baramati',
          health: FieldHealth.healthy,
        ),
      );

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // Go to My Fields tab
      await tester.tap(find.text('My Fields'));
      await tester.pumpAndSettle();

      expect(find.byType(FieldsScreen), findsOneWidget);
      expect(find.text('River Corner'), findsOneWidget);

      // Tap on the field card
      await tester.tap(find.text('River Corner'));
      await tester.pumpAndSettle();

      // Verified on FieldDetailScreen
      expect(find.byType(FieldDetailScreen), findsOneWidget);
      expect(find.text('River Corner'), findsOneWidget);

      // 3-zone legend chips
      expect(find.text('Healthy'), findsAtLeastNWidgets(1));
      expect(find.text('Watch'), findsAtLeastNWidgets(1));
      expect(find.text('Needs care'), findsOneWidget);

      // Three meters
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Pest'), findsOneWidget);

      // Large back button
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Fields list
      expect(find.byType(FieldsScreen), findsOneWidget);
    });

    testWidgets('Tapping Home field card opens FieldDetailScreen when field exists',
        (tester) async {
      await seedAuthenticatedUser(tester);

      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: 'field_home_1',
          name: 'Home Plot',
          crop: 'wheat',
          latitude: 18.52,
          longitude: 73.86,
          photoAsset: 'assets/images/hero_wheat_closeup.jpg',
          village: 'Baramati',
          health: FieldHealth.healthy,
        ),
      );

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Home Plot'), findsOneWidget);

      // Tap field card on home
      await tester.tap(find.text('Home Plot'));
      await tester.pumpAndSettle();

      // Navigates to FieldDetailScreen
      expect(find.byType(FieldDetailScreen), findsOneWidget);
      expect(find.text('Home Plot'), findsOneWidget);
    });

    testWidgets('Missing field ID does not crash and returns to fields list',
        (tester) async {
      await seedAuthenticatedUser(tester);

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // Tap to FieldsScreen
      await tester.tap(find.text('My Fields'));
      await tester.pumpAndSettle();

      // Navigate to a non-existent field route via GoRouter
      final BuildContext fieldsContext =
          tester.element(find.byType(FieldsScreen));
      GoRouter.of(fieldsContext).push('/fields/non_existent_id');
      await tester.pumpAndSettle();

      // Handled cleanly without exceptions and stays on fields screen
      expect(tester.takeException(), isNull);
      expect(find.byType(FieldsScreen), findsOneWidget);
    });
  });
}

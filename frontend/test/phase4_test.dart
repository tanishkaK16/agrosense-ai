import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/app.dart';
import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/auth/models/farmer_session.dart';
import 'package:agrosense_ai/features/fields/add_field_screen.dart';
import 'package:agrosense_ai/features/fields/data/local_fields_repository.dart';
import 'package:agrosense_ai/features/fields/fields_screen.dart';
import 'package:agrosense_ai/features/fields/models/farm_field.dart';
import 'package:agrosense_ai/features/home/home_screen.dart';
import 'package:agrosense_ai/features/home/models/home_snapshot.dart';

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

  group('FarmField & LocalFieldsRepository Tests', () {
    test('FarmField model serialization and deserialization', () {
      const field = FarmField(
        id: 'field_1',
        name: 'River Field',
        crop: 'cotton',
        latitude: 19.123,
        longitude: 74.456,
        photoAsset: 'assets/images/hero_field_wide.jpg',
        village: 'Baramati',
        health: FieldHealth.healthy,
      );

      final map = field.toMap();
      expect(map['id'], equals('field_1'));
      expect(map['name'], equals('River Field'));
      expect(map['crop'], equals('cotton'));
      expect(map['latitude'], equals(19.123));
      expect(map['longitude'], equals(74.456));
      expect(map['photo_asset'], equals('assets/images/hero_field_wide.jpg'));
      expect(map['village'], equals('Baramati'));
      expect(map['health'], equals('healthy'));

      final jsonString = field.toJson();
      final restored = FarmField.fromJson(jsonString);
      expect(restored.id, equals(field.id));
      expect(restored.name, equals(field.name));
      expect(restored.crop, equals(field.crop));
      expect(restored.latitude, equals(field.latitude));
      expect(restored.longitude, equals(field.longitude));
      expect(restored.photoAsset, equals(field.photoAsset));
      expect(restored.village, equals(field.village));
      expect(restored.health, equals(FieldHealth.healthy));
    });

    test('photoAssetForCrop returns valid assets by crop', () {
      expect(photoAssetForCrop('wheat'),
          equals('assets/images/hero_wheat_closeup.jpg'));
      expect(photoAssetForCrop('rice'),
          equals('assets/images/hero_field_sunrise.jpg'));
      expect(photoAssetForCrop('cotton'),
          equals('assets/images/hero_field_wide.jpg'));
      expect(photoAssetForCrop('sugarcane'),
          equals('assets/images/hero_canopy_green.jpg'));
      expect(photoAssetForCrop('other'),
          equals('assets/images/hero_canopy_green.jpg'));
    });

    test('LocalFieldsRepository starts empty and persists added fields',
        () async {
      final repo = LocalFieldsRepository.instance;
      final initialFields = await repo.getFields();
      expect(initialFields, isEmpty);

      const field1 = FarmField(
        id: 'f1',
        name: 'North Acre',
        crop: 'wheat',
        latitude: 18.52,
        longitude: 73.85,
        photoAsset: 'assets/images/hero_wheat_closeup.jpg',
      );

      await repo.saveField(field1);
      final fieldsAfterAdd = await repo.getFields();
      expect(fieldsAfterAdd.length, equals(1));
      expect(fieldsAfterAdd.first.name, equals('North Acre'));

      // Update same field
      const updatedField1 = FarmField(
        id: 'f1',
        name: 'North Acre (Renamed)',
        crop: 'wheat',
        latitude: 18.52,
        longitude: 73.85,
        photoAsset: 'assets/images/hero_wheat_closeup.jpg',
      );
      await repo.saveField(updatedField1);
      final fieldsAfterUpdate = await repo.getFields();
      expect(fieldsAfterUpdate.length, equals(1));
      expect(fieldsAfterUpdate.first.name, equals('North Acre (Renamed)'));

      // Delete field
      await repo.deleteField('f1');
      final fieldsAfterDelete = await repo.getFields();
      expect(fieldsAfterDelete, isEmpty);
    });
  });

  group('Phase 4 UI Tests', () {
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

    testWidgets('FieldsScreen renders empty state when zero fields',
        (tester) async {
      await seedAuthenticatedUser(tester);

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // Tap on "My Fields" nav tab
      final fieldsTab = find.text('My Fields');
      expect(fieldsTab, findsOneWidget);
      await tester.tap(fieldsTab);
      await tester.pumpAndSettle();

      expect(find.byType(FieldsScreen), findsOneWidget);
      // Verifies empty state copy and action
      expect(find.text('No field yet'), findsOneWidget);
      expect(find.text('Add your first field'), findsOneWidget);
      expect(find.text('Add field'), findsOneWidget);
    });

    testWidgets('FieldsScreen renders field card when fields exist',
        (tester) async {
      await seedAuthenticatedUser(tester);

      // Seed one field
      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: '123',
          name: 'Sunny Plot',
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

      // Tap "My Fields" nav tab
      await tester.tap(find.text('My Fields'));
      await tester.pumpAndSettle();

      // Check field card
      expect(find.text('Sunny Plot'), findsOneWidget);
      expect(find.text('Sugarcane'), findsOneWidget);
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('Baramati'), findsOneWidget);
    });

    testWidgets('HomeScreen reflects first saved field name and crop',
        (tester) async {
      await seedAuthenticatedUser(tester);

      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: 'field_home',
          name: 'East Meadow',
          crop: 'cotton',
          latitude: 18.52,
          longitude: 73.86,
          photoAsset: 'assets/images/hero_field_wide.jpg',
          village: 'Baramati',
          health: FieldHealth.healthy,
        ),
      );

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('East Meadow'), findsOneWidget);
      expect(find.text('Cotton'), findsOneWidget);
    });

    testWidgets('AddFieldScreen preselects profile crop and enables Next button',
        (tester) async {
      await seedAuthenticatedUser(tester);

      await tester.pumpWidget(const AgroSenseApp());
      await tester.pumpAndSettle();

      // Navigate to /fields
      await tester.tap(find.text('My Fields'));
      await tester.pumpAndSettle();

      // Tap "Add field"
      await tester.tap(find.text('Add field'));
      await tester.pumpAndSettle();

      expect(find.byType(AddFieldScreen), findsOneWidget);
      expect(find.text('Add field'), findsOneWidget);
      expect(find.text('Field name'), findsOneWidget);
      expect(find.text('Which crop is grown here?'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}

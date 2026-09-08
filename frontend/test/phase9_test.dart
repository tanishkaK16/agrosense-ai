import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/core/cache/cache_box.dart';
import 'package:agrosense_ai/core/cache/snapshot_cache.dart';
import 'package:agrosense_ai/core/config/app_config.dart';
import 'package:agrosense_ai/core/network/api_client.dart';
import 'package:agrosense_ai/core/network/connectivity.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_command_parser.dart';

import 'package:agrosense_ai/features/alerts/models/farm_alert.dart';
import 'package:agrosense_ai/features/auth/data/app_auth_repository.dart';
import 'package:agrosense_ai/features/auth/data/auth_mapper.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/fields/data/app_fields_repository.dart';
import 'package:agrosense_ai/features/fields/models/farm_field.dart';
import 'package:agrosense_ai/features/fields/models/field_status.dart';
import 'package:agrosense_ai/features/home/data/app_home_repository.dart';
import 'package:agrosense_ai/features/home/data/live_home_repository.dart';
import 'package:agrosense_ai/features/home/data/mock_home_repository.dart';
import 'package:agrosense_ai/features/home/models/home_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    await SnapshotCache.instance.clear();
    ConnectivityStatus.instance.reset();
    AppConfig.instance.setBaseUrl('http://127.0.0.1:8000');
    AppConfig.instance.setUseLive(false);
  });

  group('CacheBox Unit Tests', () {
    test('Writes and reads JSON objects correctly', () async {
      final box = CacheBox(prefix: 'test_box_');
      await box.write('sample', {'key': 'value', 'number': 42});

      final result = await box.read('sample');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['key'], 'value');
      expect(result['number'], 42);
    });

    test('Corrupt cache does not crash and purges invalid entry', () async {
      final box = CacheBox(prefix: 'test_corrupt_');
      final prefs = await SharedPreferences.getInstance();

      // Write broken JSON directly to simulate corruption
      await prefs.setString('test_corrupt_broken', '{invalid_json');

      final result = await box.read('broken');
      expect(result, isNull);

      // Verify the broken key was purged
      expect(prefs.containsKey('test_corrupt_broken'), isFalse);
    });

    test('Delete and clear operations purge stored cache items', () async {
      final box = CacheBox(prefix: 'test_cleanup_');
      await box.write('item1', 'alpha');
      await box.write('item2', 'beta');

      await box.delete('item1');
      expect(await box.read('item1'), isNull);
      expect(await box.read('item2'), 'beta');

      await box.clear();
      expect(await box.read('item2'), isNull);
    });
  });

  group('SnapshotCache Unit Tests', () {
    test('Saves and restores HomeSnapshot with timestamp', () async {
      const snapshot = HomeSnapshot(
        temperatureC: 31,
        rainMm: 5,
        windKmh: 14,
        fieldName: 'North Plot',
        crop: 'cotton',
        health: FieldHealth.healthy,
        summarySentence: 'Looking healthy today.',
        alertCount: 0,
      );

      await SnapshotCache.instance.saveHome(snapshot);

      final restored = await SnapshotCache.instance.getHome();
      expect(restored, isNotNull);
      expect(restored!.temperatureC, 31);
      expect(restored.fieldName, 'North Plot');
      expect(restored.crop, 'cotton');
      expect(restored.health, FieldHealth.healthy);

      final timestamp = await SnapshotCache.instance.getLastSyncedAt();
      expect(timestamp, isNotNull);
    });

    test('Saves and restores Fields list', () async {
      const field = FarmField(
        id: 'f_test_9',
        name: 'Hill Field',
        crop: 'soybean',
        latitude: 18.5,
        longitude: 73.9,
        photoAsset: 'assets/images/hero_field_wide.jpg',
      );

      await SnapshotCache.instance.saveFields([field]);

      final restored = await SnapshotCache.instance.getFields();
      expect(restored, isNotNull);
      expect(restored!.length, 1);
      expect(restored.first.id, 'f_test_9');
      expect(restored.first.name, 'Hill Field');
    });

    test('Saves, restores, and marks alerts as seen in cache', () async {
      const alert = FarmAlert(
        id: 'alt_101',
        fieldId: 'f_1',
        kind: AlertKind.water,
        severity: AlertSeverity.actNow,
        createdLabel: 'Today',
        seen: false,
      );

      await SnapshotCache.instance.saveAlerts([alert]);
      var restored = await SnapshotCache.instance.getAlerts();
      expect(restored!.first.seen, isFalse);

      await SnapshotCache.instance.markAlertSeen('alt_101');
      restored = await SnapshotCache.instance.getAlerts();
      expect(restored!.first.seen, isTrue);
    });

    test('Saves and restores FieldStatus', () async {
      const status = FieldStatus(
        fieldId: 'f_99',
        health: HealthLevel.watch,
        water: WaterLevel.low,
        pest: PestLevel.good,
        overlayHint: OverlayHint.right,
      );

      await SnapshotCache.instance.saveFieldStatus('f_99', status);
      final restored = await SnapshotCache.instance.getFieldStatus('f_99');
      expect(restored, isNotNull);
      expect(restored!.health, HealthLevel.watch);
      expect(restored.water, WaterLevel.low);
    });
  });

  group('FarmerProfile & SMS Opt-In Tests', () {
    test('FarmerProfile defaults smsOptIn to true and copyWith works', () {
      const profile = FarmerProfile(
        name: 'Sunita',
        village: 'Khed',
        mainCrop: 'sugarcane',
      );
      expect(profile.smsOptIn, isTrue);

      final updated = profile.copyWith(smsOptIn: false);
      expect(updated.smsOptIn, isFalse);
      expect(updated.name, 'Sunita');
      expect(updated.village, 'Khed');
      expect(updated.mainCrop, 'sugarcane');
    });

    test('AuthMapper serializes and deserializes sms_opt_in correctly', () {
      final json = {
        'name': 'Ganesh',
        'village': 'Saswad',
        'crop': 'rice',
        'sms_opt_in': false,
      };

      final profile = AuthMapper.profileFromJson(json);
      expect(profile.name, 'Ganesh');
      expect(profile.smsOptIn, isFalse);

      final serialized = AuthMapper.profileToJson(profile);
      expect(serialized['sms_opt_in'], isFalse);
    });

    test('SnapshotCache and AppAuthRepository persist smsOptIn', () async {
      const profile = FarmerProfile(
        name: 'Kisan',
        village: 'Shirur',
        mainCrop: 'wheat',
        smsOptIn: false,
      );

      await AppAuthRepository.instance.saveProfile(profile);

      final cached = await SnapshotCache.instance.getProfile();
      expect(cached, isNotNull);
      expect(cached!.smsOptIn, isFalse);

      final active = AppAuthRepository.instance.currentProfile();
      expect(active?.smsOptIn, isFalse);
    });
  });

  group('Offline Continuity & Airplane Mode Simulation', () {
    test('When network fails, AppHomeRepository serves cached snapshot and sets isUsingCachedData', () async {
      // 1. Initial successful load populates snapshot cache
      const initialSnapshot = HomeSnapshot(
        temperatureC: 34,
        rainMm: 0,
        windKmh: 10,
        fieldName: 'Pond Plot',
        crop: 'wheat',
        health: FieldHealth.healthy,
        summarySentence: 'Everything looks good today.',
        alertCount: 0,
      );
      await SnapshotCache.instance.saveHome(initialSnapshot);

      // 2. Switch to live mode, but mock an unreachable server (airplane mode)
      AppConfig.instance.setUseLive(true);
      final offlineHttp = MockClient((request) async {
        throw http.ClientException('No network connection');
      });
      final offlineClient = ApiClient(httpClient: offlineHttp);
      final liveRepo = LiveHomeRepository(apiClient: offlineClient);

      final homeRepo = AppHomeRepository(
        liveRepo: liveRepo,
        mockRepo: MockHomeRepository.instance,
      );

      // 3. Requesting home snapshot should transparently return cached data
      final result = await homeRepo.getHomeSnapshot();
      expect(result.fieldName, 'Pond Plot');
      expect(result.temperatureC, 34);
      expect(ConnectivityStatus.instance.isUsingCachedData, isTrue);
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);
    });

    test('AppFieldsRepository protects local fields and updates cache on save', () async {
      const field = FarmField(
        id: 'f_local_offline',
        name: 'Local Offline Plot',
        crop: 'cotton',
        latitude: 18.9,
        longitude: 73.8,
        photoAsset: 'assets/images/hero_field_wide.jpg',
      );

      await AppFieldsRepository.instance.saveField(field);

      final cached = await SnapshotCache.instance.getFields();
      expect(cached, isNotNull);
      expect(cached!.any((f) => f.id == 'f_local_offline'), isTrue);
    });
  });

  group('Voice Command Parser SMS Tests', () {
    test('Parses English, Hindi, and Marathi SMS keywords', () {
      expect(VoiceCommandParser.parse('sms').action, VoiceActionType.openSmsInfo);
      expect(VoiceCommandParser.parse('message').action, VoiceActionType.openSmsInfo);
      expect(VoiceCommandParser.parse('संदेश').action, VoiceActionType.openSmsInfo);
      expect(VoiceCommandParser.parse('मेसेज').action, VoiceActionType.openSmsInfo);
      expect(VoiceCommandParser.parse('मैसेज').action, VoiceActionType.openSmsInfo);
      expect(VoiceCommandParser.parse('एसएमएस').action, VoiceActionType.openSmsInfo);
      expect(VoiceCommandParser.parse('sandesh').action, VoiceActionType.openSmsInfo);
    });
  });
}

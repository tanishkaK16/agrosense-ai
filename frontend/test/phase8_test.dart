import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/core/config/app_config.dart';
import 'package:agrosense_ai/core/network/api_client.dart';
import 'package:agrosense_ai/core/network/api_exception.dart';
import 'package:agrosense_ai/core/network/connectivity.dart';
import 'package:agrosense_ai/core/network/pending_sync_queue.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';

import 'package:agrosense_ai/features/alerts/data/alerts_mapper.dart';
import 'package:agrosense_ai/features/alerts/data/app_alerts_repository.dart';
import 'package:agrosense_ai/features/alerts/data/live_alerts_repository.dart';
import 'package:agrosense_ai/features/alerts/data/mock_alerts_repository.dart';
import 'package:agrosense_ai/features/alerts/models/farm_alert.dart';

import 'package:agrosense_ai/features/auth/data/app_auth_repository.dart';
import 'package:agrosense_ai/features/auth/data/auth_mapper.dart';
import 'package:agrosense_ai/features/auth/data/live_auth_repository.dart';
import 'package:agrosense_ai/features/auth/data/mock_auth_repository.dart';
import 'package:agrosense_ai/features/auth/models/farmer_profile.dart';
import 'package:agrosense_ai/features/auth/models/farmer_session.dart';

import 'package:agrosense_ai/features/fields/data/app_field_status_repository.dart';
import 'package:agrosense_ai/features/fields/data/app_fields_repository.dart';
import 'package:agrosense_ai/features/fields/data/field_status_mapper.dart';
import 'package:agrosense_ai/features/fields/data/fields_mapper.dart';
import 'package:agrosense_ai/features/fields/data/live_field_status_repository.dart';
import 'package:agrosense_ai/features/fields/data/live_fields_repository.dart';
import 'package:agrosense_ai/features/fields/data/local_fields_repository.dart';
import 'package:agrosense_ai/features/fields/data/mock_field_status_repository.dart';
import 'package:agrosense_ai/features/fields/models/farm_field.dart';
import 'package:agrosense_ai/features/fields/models/field_status.dart';

import 'package:agrosense_ai/features/home/data/app_home_repository.dart';
import 'package:agrosense_ai/features/home/data/home_mapper.dart';
import 'package:agrosense_ai/features/home/data/live_home_repository.dart';
import 'package:agrosense_ai/features/home/data/mock_home_repository.dart';
import 'package:agrosense_ai/features/home/models/home_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPrefs.instance.init();
    AppConfig.instance.setBaseUrl('http://127.0.0.1:8000');
    AppConfig.instance.setUseLive(false);
    ConnectivityStatus.instance.reportLiveSuccess();
    await PendingSyncQueue.instance.clear();
  });

  group('Mappers Unit Tests', () {
    test('AuthMapper maps session JSON and payloads correctly', () {
      final sessionJson = {
        'token': 'jwt_sample_123',
        'profile_complete': false,
      };
      final session = AuthMapper.sessionFromVerifyJson(
        sessionJson,
        phoneNumber: '+919876543210',
      );
      expect(session.phoneNumber, '+919876543210');
      expect(session.token, 'jwt_sample_123');

      const profile = FarmerProfile(
        name: 'Ramesh',
        village: 'Baramati',
        mainCrop: 'wheat',
      );
      final profilePayload = AuthMapper.profileToJson(profile);
      expect(profilePayload['name'], 'Ramesh');
      expect(profilePayload['village'], 'Baramati');
      expect(profilePayload['crop'], 'wheat');
    });

    test('FieldsMapper maps fields and preserves valid crops and health', () {
      final json = {
        'id': 'f_101',
        'name': 'East Plot',
        'crop': 'cotton',
        'lat': 18.5204,
        'lng': 73.8567,
        'village': 'Pune',
        'health': 'watch',
      };

      final field = FieldsMapper.fromJson(json);
      expect(field.id, 'f_101');
      expect(field.name, 'East Plot');
      expect(field.crop, 'cotton');
      expect(field.latitude, 18.5204);
      expect(field.longitude, 73.8567);
      expect(field.health, FieldHealth.watch);

      final payload = FieldsMapper.toCreatePayload(field);
      expect(payload['name'], 'East Plot');
      expect(payload['crop'], 'cotton');
      expect(payload['lat'], 18.5204);
      expect(payload['lng'], 73.8567);
    });

    test('FieldStatusMapper maps good, watch, actNow, and low enums', () {
      final json = {
        'health': 'actNow',
        'water': 'low',
        'pest': 'watch',
        'summary_key': 'water_stress',
      };

      final status = FieldStatusMapper.fromJson(json, fieldId: 'f_101');
      expect(status.fieldId, 'f_101');
      expect(status.health, HealthLevel.actNow);
      expect(status.water, WaterLevel.low);
      expect(status.pest, PestLevel.watch);
      expect(status.summarySentence?.isNotEmpty, isTrue);
    });

    test('HomeMapper maps weather, health and alert count', () {
      final json = {
        'temperature_c': 32.5,
        'rain_mm': 12.0,
        'wind_kmh': 15.0,
        'field_id': 'f_1',
        'health': 'watch',
        'alert_count': 2,
        'summary_key': 'general_watch',
      };

      final snapshot = HomeMapper.fromJson(json);
      expect(snapshot.temperatureC, 33);
      expect(snapshot.rainMm, 12);
      expect(snapshot.windKmh, 15);
      expect(snapshot.health, FieldHealth.watch);
      expect(snapshot.alertCount, 2);
    });

    test('AlertsMapper maps alert JSON', () {
      final alertJson = {
        'id': 'a1',
        'field_id': 'f1',
        'kind': 'pest',
        'severity': 'watch',
        'created_label': 'Today',
        'seen': false,
      };

      final alert = AlertsMapper.fromJson(alertJson);
      expect(alert.id, 'a1');
      expect(alert.fieldId, 'f1');
      expect(alert.kind, AlertKind.pest);
      expect(alert.severity, AlertSeverity.watch);
      expect(alert.seen, isFalse);
    });
  });

  group('ApiClient Unit Tests', () {
    test('Injects Bearer token in headers when session exists', () async {
      final session = FarmerSession(
        phoneNumber: '+919999999999',
        token: 'active_test_jwt',
        createdAt: DateTime.now(),
      );
      await AppPrefs.instance.setSessionJson(session.toJson());

      String? capturedAuthHeader;
      final mockHttp = MockClient((request) async {
        capturedAuthHeader = request.headers['Authorization'];
        return http.Response(jsonEncode({'detail': 'ok'}), 200);
      });

      final client = ApiClient(httpClient: mockHttp);
      await client.get('/test');

      expect(capturedAuthHeader, 'Bearer active_test_jwt');
    });

    test('Throws ApiException.unauthorized and clears session on 401', () async {
      final session = FarmerSession(
        phoneNumber: '+919999999999',
        token: 'expired_jwt',
        createdAt: DateTime.now(),
      );
      await AppPrefs.instance.setSessionJson(session.toJson());
      expect(AppPrefs.instance.hasSession, isTrue);

      bool unauthorizedCallbackFired = false;
      final mockHttp = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Invalid token'}), 401);
      });

      final client = ApiClient(
        httpClient: mockHttp,
        onUnauthorized: () {
          unauthorizedCallbackFired = true;
        },
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiException>().having(
          (ApiException e) => e.type,
          'type',
          ApiErrorType.unauthorized,
        )),
      );

      await pumpEventQueue();
      expect(AppPrefs.instance.hasSession, isFalse);
      expect(unauthorizedCallbackFired, isTrue);
    });

    test('Throws ApiException.notFound on 404', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Not found'}), 404);
      });

      final client = ApiClient(httpClient: mockHttp);
      expect(
        () => client.get('/missing'),
        throwsA(isA<ApiException>().having(
          (ApiException e) => e.type,
          'type',
          ApiErrorType.notFound,
        )),
      );
    });

    test('Throws ApiException.server on 500', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Internal error'}), 500);
      });

      final client = ApiClient(httpClient: mockHttp);
      expect(
        () => client.get('/fail'),
        throwsA(isA<ApiException>().having(
          (ApiException e) => e.type,
          'type',
          ApiErrorType.server,
        )),
      );
    });
  });

  group('Live Fails -> Fallback Graceful Tests', () {
    test('When useLive is false, AppHomeRepository uses mock data', () async {
      AppConfig.instance.setUseLive(false);

      final homeRepo = AppHomeRepository(
        mockRepo: MockHomeRepository.instance,
      );

      final snapshot = await homeRepo.getHomeSnapshot();
      expect(snapshot.temperatureC, greaterThan(0));
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);
    });

    test('When useLive is true but server returns 500, AppHomeRepository falls back cleanly', () async {
      AppConfig.instance.setUseLive(true);

      final failingHttp = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Django server down'}), 500);
      });
      final failingApiClient = ApiClient(httpClient: failingHttp);
      final liveRepo = LiveHomeRepository(apiClient: failingApiClient);

      final homeRepo = AppHomeRepository(
        liveRepo: liveRepo,
        mockRepo: MockHomeRepository.instance,
      );

      final snapshot = await homeRepo.getHomeSnapshot();
      expect(snapshot, isNotNull);
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);
    });

    test('When useLive is true but server fails, AppFieldsRepository saves locally and enqueues sync', () async {
      AppConfig.instance.setUseLive(true);

      final failingHttp = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Connection refused'}), 503);
      });
      final failingApiClient = ApiClient(httpClient: failingHttp);
      final liveRepo = LiveFieldsRepository(apiClient: failingApiClient);
      final localRepo = LocalFieldsRepository.instance;

      final fieldsRepo = AppFieldsRepository(
        liveRepo: liveRepo,
        localRepo: localRepo,
      );

      const field = FarmField(
        id: 'f_test_fallback',
        name: 'Fallback Field',
        crop: 'rice',
        latitude: 19.1,
        longitude: 74.2,
        photoAsset: 'assets/images/hero_field_sunrise.jpg',
      );

      await fieldsRepo.saveField(field);

      final savedFields = await localRepo.getFields();
      expect(savedFields.any((f) => f.id == 'f_test_fallback'), isTrue);

      final pending = await PendingSyncQueue.instance.getPending();
      expect(pending.any((action) => action['action'] == 'save_field'), isTrue);
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);
    });

    test('When useLive is true and server succeeds, AppFieldsRepository returns live data', () async {
      AppConfig.instance.setUseLive(true);

      final successfulHttp = MockClient((request) async {
        if (request.url.path.endsWith('/fields')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'f_remote_1',
                'name': 'Remote Sugar Field',
                'crop': 'sugarcane',
                'lat': 18.2,
                'lng': 74.5,
                'health': 'good',
              }
            ]),
            200,
          );
        }
        return http.Response('{"detail": "Not found"}', 404);
      });

      final apiClient = ApiClient(httpClient: successfulHttp);
      final liveRepo = LiveFieldsRepository(apiClient: apiClient);
      final localRepo = LocalFieldsRepository.instance;

      final fieldsRepo = AppFieldsRepository(
        liveRepo: liveRepo,
        localRepo: localRepo,
      );

      final fields = await fieldsRepo.getFields();
      expect(fields.length, 1);
      expect(fields.first.id, 'f_remote_1');
      expect(fields.first.name, 'Remote Sugar Field');
      expect(ConnectivityStatus.instance.isUsingFallback, isFalse);
    });

    test('When useLive is true and server fails, AppFieldStatusRepository falls back cleanly', () async {
      AppConfig.instance.setUseLive(true);

      final failingHttp = MockClient((request) async {
        return http.Response('{"detail": "Internal error"}', 500);
      });
      final failingApiClient = ApiClient(httpClient: failingHttp);
      final liveRepo = LiveFieldStatusRepository(apiClient: failingApiClient);
      final mockRepo = MockFieldStatusRepository.instance;

      final statusRepo = AppFieldStatusRepository(
        liveRepo: liveRepo,
        mockRepo: mockRepo,
      );

      final status = await statusRepo.getFieldStatus('any_field_id');
      expect(status, isNotNull);
      expect(status.health, isNotNull);
      expect(status.water, isNotNull);
      expect(status.pest, isNotNull);
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);
    });

    test('When useLive is true and server fails, AppAlertsRepository falls back cleanly and enqueues mark seen', () async {
      AppConfig.instance.setUseLive(true);

      final failingHttp = MockClient((request) async {
        return http.Response('{"detail": "Gateway timeout"}', 504);
      });
      final failingApiClient = ApiClient(httpClient: failingHttp);
      final liveRepo = LiveAlertsRepository(apiClient: failingApiClient);
      final mockRepo = MockAlertsRepository.instance;

      final alertsRepo = AppAlertsRepository(
        liveRepo: liveRepo,
        mockRepo: mockRepo,
      );

      final alerts = await alertsRepo.getAlerts();
      expect(alerts, isNotNull);
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);

      if (alerts.isNotEmpty) {
        await alertsRepo.markAlertSeen(alerts.first.id);
        final pending = await PendingSyncQueue.instance.getPending();
        expect(pending.any((action) => action['action'] == 'mark_alert_seen'), isTrue);
      }
    });

    test('When useLive is true and server fails, AppAuthRepository falls back to mock OTP verification', () async {
      AppConfig.instance.setUseLive(true);

      final failingHttp = MockClient((request) async {
        return http.Response('{"detail": "Server error"}', 500);
      });
      final failingApiClient = ApiClient(httpClient: failingHttp);
      final liveRepo = LiveAuthRepository(apiClient: failingApiClient);
      final mockRepo = MockAuthRepository.instance;

      final authRepo = AppAuthRepository(
        liveRepo: liveRepo,
        mockRepo: mockRepo,
      );

      final session = await authRepo.verifyOtp('+919876543210', '1234');
      expect(session, isNotNull);
      expect(session?.token.isNotEmpty, isTrue);
      expect(ConnectivityStatus.instance.isUsingFallback, isTrue);
    });
  });
}

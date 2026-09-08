import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrosense_ai/core/l10n/locale_controller.dart';
import 'package:agrosense_ai/core/storage/app_prefs.dart';
import 'package:agrosense_ai/core/voice/voice_service.dart';
import 'package:agrosense_ai/features/alerts/alert_detail_screen.dart';
import 'package:agrosense_ai/features/alerts/alerts_screen.dart';
import 'package:agrosense_ai/features/alerts/data/mock_alerts_repository.dart';
import 'package:agrosense_ai/features/alerts/models/farm_alert.dart';
import 'package:agrosense_ai/features/fields/data/local_fields_repository.dart';
import 'package:agrosense_ai/features/fields/data/mock_field_status_repository.dart';
import 'package:agrosense_ai/features/fields/models/farm_field.dart';
import 'package:agrosense_ai/features/fields/models/field_status.dart';
import 'package:agrosense_ai/features/home/data/mock_home_repository.dart';
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
    await MockAlertsRepository.instance.clear();
  });

  tearDown(() async {
    await AppPrefs.instance.clear();
    await LocaleController.instance.clear();
    await LocalFieldsRepository.instance.clear();
    await MockAlertsRepository.instance.clear();
    await VoiceService.instance.stop();
  });

  group('FarmAlert & MockAlertsRepository Unit Tests', () {
    test('FarmAlert serialization and copyWith', () {
      const alert = FarmAlert(
        id: 'f1_water',
        fieldId: 'f1',
        kind: AlertKind.water,
        severity: AlertSeverity.actNow,
        createdLabel: 'Today',
        seen: false,
      );

      final map = alert.toMap();
      expect(map['id'], equals('f1_water'));
      expect(map['field_id'], equals('f1'));
      expect(map['kind'], equals('water'));
      expect(map['severity'], equals('actNow'));
      expect(map['seen'], isFalse);

      final restored = FarmAlert.fromJson(alert.toJson());
      expect(restored.id, equals('f1_water'));
      expect(restored.fieldId, equals('f1'));
      expect(restored.kind, equals(AlertKind.water));
      expect(restored.severity, equals(AlertSeverity.actNow));
      expect(restored.seen, isFalse);

      final updated = restored.copyWith(seen: true);
      expect(updated.seen, isTrue);
    });

    test('Empty fields result in empty alerts list', () async {
      final alerts = await MockAlertsRepository.instance.getAlerts();
      expect(alerts, isEmpty);
    });

    test('Field with healthy status results in zero alerts', () async {
      const fieldId = 'healthy_field_test';
      const field = FarmField(
        id: fieldId,
        name: 'Healthy Wheat Field',
        crop: 'Wheat',
        latitude: 18.5,
        longitude: 73.8,
        photoAsset: 'assets/images/hero_wheat_closeup.jpg',
      );
      await LocalFieldsRepository.instance.saveField(field);

      // Save a completely healthy status
      await MockFieldStatusRepository.instance.saveFieldStatus(
        const FieldStatus(
          fieldId: fieldId,
          health: HealthLevel.good,
          water: WaterLevel.good,
          pest: PestLevel.good,
          overlayHint: OverlayHint.none,
          summarySentence: 'Looking great.',
        ),
      );

      final alerts = await MockAlertsRepository.instance.getAlerts();
      expect(alerts, isEmpty);
    });

    test('Field status mapping produces appropriate alert kinds and sorts actNow first',
        () async {
      const fieldWaterId = 'f_water_low';
      const fieldPestId = 'f_pest_critical';

      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: fieldWaterId,
          name: 'Water Field',
          crop: 'Rice',
          latitude: 18.0,
          longitude: 73.0,
          photoAsset: 'assets/images/hero_wheat_closeup.jpg',
        ),
      );
      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: fieldPestId,
          name: 'Pest Field',
          crop: 'Cotton',
          latitude: 18.1,
          longitude: 73.1,
          photoAsset: 'assets/images/hero_wheat_closeup.jpg',
        ),
      );

      // Water is low (watch)
      await MockFieldStatusRepository.instance.saveFieldStatus(
        const FieldStatus(
          fieldId: fieldWaterId,
          health: HealthLevel.watch,
          water: WaterLevel.low,
          pest: PestLevel.good,
          overlayHint: OverlayHint.right,
          summarySentence: 'Water is low.',
        ),
      );

      // Pest is critical (actNow)
      await MockFieldStatusRepository.instance.saveFieldStatus(
        const FieldStatus(
          fieldId: fieldPestId,
          health: HealthLevel.actNow,
          water: WaterLevel.good,
          pest: PestLevel.actNow,
          overlayHint: OverlayHint.left,
          summarySentence: 'Pest outbreak.',
        ),
      );

      final alerts = await MockAlertsRepository.instance.getAlerts();
      expect(alerts.length, equals(2));

      // Act now must come before Watch
      expect(alerts[0].severity, equals(AlertSeverity.actNow));
      expect(alerts[0].kind, equals(AlertKind.pest));
      expect(alerts[0].fieldId, equals(fieldPestId));

      expect(alerts[1].severity, equals(AlertSeverity.watch));
      expect(alerts[1].kind, equals(AlertKind.water));
      expect(alerts[1].fieldId, equals(fieldWaterId));

      // Check Home snapshot reflects alert count
      final homeSnapshot =
          await MockHomeRepository.instance.getHomeSnapshot();
      expect(homeSnapshot.alertCount, equals(2));
    });

    test('Marking alert seen persists in repository', () async {
      const fieldId = 'f_water_test';
      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: fieldId,
          name: 'Water Field',
          crop: 'Wheat',
          latitude: 18.0,
          longitude: 73.0,
          photoAsset: 'assets/images/hero_wheat_closeup.jpg',
        ),
      );
      await MockFieldStatusRepository.instance.saveFieldStatus(
        const FieldStatus(
          fieldId: fieldId,
          health: HealthLevel.watch,
          water: WaterLevel.low,
          pest: PestLevel.good,
          overlayHint: OverlayHint.none,
          summarySentence: 'Water is low.',
        ),
      );

      final alertsBefore = await MockAlertsRepository.instance.getAlerts();
      expect(alertsBefore.first.seen, isFalse);

      await MockAlertsRepository.instance.markAlertSeen(alertsBefore.first.id);

      final alertsAfter = await MockAlertsRepository.instance.getAlerts();
      expect(alertsAfter.first.seen, isTrue);
    });
  });

  group('Alerts UI Widget Tests', () {
    testWidgets('AlertsScreen displays calm green empty state when no alerts exist',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AlertsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('No alert today'), findsOneWidget);
      expect(find.text('Your fields look fine.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('AlertsScreen lists alert cards and opens AlertDetailScreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      const fieldId = 'demo_field_alerts';
      await LocalFieldsRepository.instance.saveField(
        const FarmField(
          id: fieldId,
          name: 'North Wheat Field',
          crop: 'Wheat',
          latitude: 18.5,
          longitude: 73.8,
          photoAsset: 'assets/images/hero_wheat_closeup.jpg',
        ),
      );

      await MockFieldStatusRepository.instance.saveFieldStatus(
        const FieldStatus(
          fieldId: fieldId,
          health: HealthLevel.watch,
          water: WaterLevel.low,
          pest: PestLevel.good,
          overlayHint: OverlayHint.left,
          summarySentence: 'Water is low.',
        ),
      );

      final router = GoRouter(
        initialLocation: '/alerts',
        routes: [
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/alerts/:id',
            builder: (context, state) => AlertDetailScreen(
              alertId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('North Wheat Field'), findsOneWidget);
      expect(find.text('Water is low.'), findsOneWidget);
      expect(find.text('Give water if the soil is dry.'), findsOneWidget);

      // Tap alert card to open detail
      await tester.tap(find.text('North Wheat Field'));
      await tester.pumpAndSettle();

      // Detail Screen is open
      expect(find.text('What to do today'), findsOneWidget);
      expect(
        find.text('If it gets worse in 2 days, ask your local shop or officer.'),
        findsOneWidget,
      );
      expect(find.text('Done'), findsOneWidget);

      // Tap Done button
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Back on list screen
      expect(find.text('Alerts'), findsOneWidget);
    });
  });
}

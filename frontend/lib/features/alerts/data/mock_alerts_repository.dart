import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fields/data/local_fields_repository.dart';
import '../../fields/data/mock_field_status_repository.dart';
import '../../fields/models/field_status.dart';
import '../models/farm_alert.dart';
import 'alerts_repository.dart';

/// Single developer-only switch to force a water alert for demonstration.
/// Kept strictly internal — never exposed in the farmer UI.
const bool kDevForceDemoWaterAlert = false;

/// Mock implementation of [AlertsRepository].
/// Synchronizes alerts directly with [MockFieldStatusRepository] and [LocalFieldsRepository],
/// ensuring Home, Fields, and Alerts all agree.
class MockAlertsRepository extends ChangeNotifier implements AlertsRepository {
  MockAlertsRepository._();

  static final MockAlertsRepository instance = MockAlertsRepository._();

  static const String _keySeenAlerts = 'seen_alert_ids';

  @override
  Future<List<FarmAlert>> getAlerts() async {
    final fields = await LocalFieldsRepository.instance.getFields();

    // If farmer has no fields, alerts is empty and calm (unless dev override is active)
    if (fields.isEmpty && !kDevForceDemoWaterAlert) {
      return const [];
    }

    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList(_keySeenAlerts) ?? const []).toSet();

    final List<FarmAlert> alerts = [];

    // Check dev override
    if (kDevForceDemoWaterAlert) {
      final fieldId = fields.isNotEmpty ? fields.first.id : 'demo_field';
      alerts.add(
        FarmAlert(
          id: '${fieldId}_water_demo',
          fieldId: fieldId,
          kind: AlertKind.water,
          severity: AlertSeverity.watch,
          seen: seenIds.contains('${fieldId}_water_demo'),
        ),
      );
    }

    for (final field in fields) {
      final status =
          await MockFieldStatusRepository.instance.getFieldStatus(field.id);

      // 1. Check Water status
      if (status.water == WaterLevel.actNow) {
        final alertId = '${field.id}_water';
        alerts.add(
          FarmAlert(
            id: alertId,
            fieldId: field.id,
            kind: AlertKind.water,
            severity: AlertSeverity.actNow,
            seen: seenIds.contains(alertId),
          ),
        );
      } else if (status.water == WaterLevel.low) {
        final alertId = '${field.id}_water';
        alerts.add(
          FarmAlert(
            id: alertId,
            fieldId: field.id,
            kind: AlertKind.water,
            severity: AlertSeverity.watch,
            seen: seenIds.contains(alertId),
          ),
        );
      }

      // 2. Check Pest status
      if (status.pest == PestLevel.actNow) {
        final alertId = '${field.id}_pest';
        alerts.add(
          FarmAlert(
            id: alertId,
            fieldId: field.id,
            kind: AlertKind.pest,
            severity: AlertSeverity.actNow,
            seen: seenIds.contains(alertId),
          ),
        );
      } else if (status.pest == PestLevel.watch) {
        final alertId = '${field.id}_pest';
        alerts.add(
          FarmAlert(
            id: alertId,
            fieldId: field.id,
            kind: AlertKind.pest,
            severity: AlertSeverity.watch,
            seen: seenIds.contains(alertId),
          ),
        );
      }

      // 3. Check Health status (if not already surfaced by water/pest)
      if (status.health == HealthLevel.actNow &&
          status.water == WaterLevel.good &&
          status.pest == PestLevel.good) {
        final alertId = '${field.id}_health';
        alerts.add(
          FarmAlert(
            id: alertId,
            fieldId: field.id,
            kind: AlertKind.health,
            severity: AlertSeverity.actNow,
            seen: seenIds.contains(alertId),
          ),
        );
      } else if (status.health == HealthLevel.watch &&
          status.water == WaterLevel.good &&
          status.pest == PestLevel.good) {
        final alertId = '${field.id}_health';
        alerts.add(
          FarmAlert(
            id: alertId,
            fieldId: field.id,
            kind: AlertKind.health,
            severity: AlertSeverity.watch,
            seen: seenIds.contains(alertId),
          ),
        );
      }
    }

    // Sort alerts: worst first (Act now before Watch)
    alerts.sort((a, b) {
      if (a.severity == AlertSeverity.actNow &&
          b.severity != AlertSeverity.actNow) {
        return -1;
      }
      if (b.severity == AlertSeverity.actNow &&
          a.severity != AlertSeverity.actNow) {
        return 1;
      }
      return 0;
    });

    return alerts;
  }

  @override
  Future<FarmAlert?> getAlertById(String id) async {
    final all = await getAlerts();
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<void> markAlertSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList(_keySeenAlerts) ?? const []).toList();
    if (!seenIds.contains(id)) {
      seenIds.add(id);
      await prefs.setStringList(_keySeenAlerts, seenIds);
      notifyListeners();
    }
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySeenAlerts);
    notifyListeners();
  }
}

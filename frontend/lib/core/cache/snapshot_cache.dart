import '../../features/alerts/data/alerts_mapper.dart';
import '../../features/alerts/models/farm_alert.dart';
import '../../features/auth/data/auth_mapper.dart';
import '../../features/auth/models/farmer_profile.dart';
import '../../features/fields/data/fields_mapper.dart';
import '../../features/fields/models/farm_field.dart';
import '../../features/fields/models/field_status.dart';
import '../../features/home/data/home_mapper.dart';
import '../../features/home/models/home_snapshot.dart';
import 'cache_box.dart';

/// Strongly-typed cache layer persisting domain snapshots on device.
/// Enables seamless offline continuity for Home, Fields, Field Status, Alerts, and Profile.
class SnapshotCache {
  SnapshotCache({CacheBox? box}) : _box = box ?? CacheBox.instance;

  static final SnapshotCache instance = SnapshotCache();

  final CacheBox _box;

  static const String keyHome = 'home';
  static const String keyFields = 'fields';
  static const String prefixFieldStatus = 'field_status_';
  static const String keyAlerts = 'alerts';
  static const String keyProfile = 'profile';
  static const String keyLastSyncedAt = 'last_synced_at';

  // ── Home Snapshot ──────────────────────────────────────────────────────────

  Future<void> saveHome(HomeSnapshot snapshot) async {
    await _box.write(keyHome, HomeMapper.toJson(snapshot));
    await _recordSyncTimestamp();
  }

  Future<HomeSnapshot?> getHome() async {
    final raw = await _box.read(keyHome);
    if (raw is Map) {
      try {
        return HomeMapper.fromJson(Map<String, dynamic>.from(raw));
      } catch (_) {
        await _box.delete(keyHome);
      }
    }
    return null;
  }

  // ── Fields ─────────────────────────────────────────────────────────────────

  Future<void> saveFields(List<FarmField> fields) async {
    final list = fields.map(FieldsMapper.toJson).toList();
    await _box.write(keyFields, list);
    await _recordSyncTimestamp();
  }

  Future<List<FarmField>?> getFields() async {
    final raw = await _box.read(keyFields);
    if (raw is List) {
      try {
        return raw
            .whereType<Map>()
            .map((item) =>
                FieldsMapper.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (_) {
        await _box.delete(keyFields);
      }
    }
    return null;
  }

  // ── Field Status ───────────────────────────────────────────────────────────

  Future<void> saveFieldStatus(String fieldId, FieldStatus status) async {
    await _box.write('$prefixFieldStatus$fieldId', status.toMap());
    await _recordSyncTimestamp();
  }

  Future<FieldStatus?> getFieldStatus(String fieldId) async {
    final raw = await _box.read('$prefixFieldStatus$fieldId');
    if (raw is Map) {
      try {
        return FieldStatus.fromMap(Map<String, dynamic>.from(raw));
      } catch (_) {
        await _box.delete('$prefixFieldStatus$fieldId');
      }
    }
    return null;
  }

  // ── Alerts ─────────────────────────────────────────────────────────────────

  Future<void> saveAlerts(List<FarmAlert> alerts) async {
    final list = alerts.map(AlertsMapper.toJson).toList();
    await _box.write(keyAlerts, list);
    await _recordSyncTimestamp();
  }

  Future<List<FarmAlert>?> getAlerts() async {
    final raw = await _box.read(keyAlerts);
    if (raw is List) {
      try {
        return raw
            .whereType<Map>()
            .map((item) =>
                AlertsMapper.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (_) {
        await _box.delete(keyAlerts);
      }
    }
    return null;
  }

  Future<void> markAlertSeen(String alertId) async {
    final current = await getAlerts();
    if (current == null) return;

    final updated = current.map((a) {
      if (a.id == alertId) {
        return FarmAlert(
          id: a.id,
          fieldId: a.fieldId,
          kind: a.kind,
          severity: a.severity,
          createdLabel: a.createdLabel,
          seen: true,
        );
      }
      return a;
    }).toList();

    await saveAlerts(updated);
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> saveProfile(FarmerProfile profile) async {
    await _box.write(keyProfile, AuthMapper.profileToJson(profile));
    await _recordSyncTimestamp();
  }

  Future<FarmerProfile?> getProfile() async {
    final raw = await _box.read(keyProfile);
    if (raw is Map) {
      try {
        return AuthMapper.profileFromJson(Map<String, dynamic>.from(raw));
      } catch (_) {
        await _box.delete(keyProfile);
      }
    }
    return null;
  }

  // ── Sync Timestamp & Cleanup ───────────────────────────────────────────────

  Future<String?> getLastSyncedAt() async {
    final raw = await _box.read(keyLastSyncedAt);
    return raw is String ? raw : null;
  }

  Future<void> _recordSyncTimestamp() async {
    await _box.write(keyLastSyncedAt, DateTime.now().toIso8601String());
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

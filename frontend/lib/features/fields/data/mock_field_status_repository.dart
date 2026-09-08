import 'package:shared_preferences/shared_preferences.dart';

import '../models/field_status.dart';
import 'field_status_repository.dart';

/// Developer-only switches to force specific conditions during development.
/// Kept strictly internal — never exposed in the farmer UI.
const bool kDevForceWaterLow = false;
const bool kDevForcePestWatch = false;
const bool kDevForceActNow = false;

/// Mock implementation of [FieldStatusRepository] with deterministic scoring
/// and local device persistence.
class MockFieldStatusRepository implements FieldStatusRepository {
  MockFieldStatusRepository._();

  static final MockFieldStatusRepository instance =
      MockFieldStatusRepository._();

  static const String _prefPrefix = 'field_status_';

  @override
  Future<FieldStatus> getFieldStatus(String fieldId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefPrefix$fieldId';

    // 1. Check if developer override is active
    if (kDevForceActNow) {
      return FieldStatus(
        fieldId: fieldId,
        health: HealthLevel.actNow,
        water: WaterLevel.actNow,
        pest: PestLevel.watch,
        overlayHint: OverlayHint.left,
      );
    }
    if (kDevForceWaterLow) {
      return FieldStatus(
        fieldId: fieldId,
        health: HealthLevel.watch,
        water: WaterLevel.low,
        pest: PestLevel.good,
        overlayHint: OverlayHint.right,
      );
    }
    if (kDevForcePestWatch) {
      return FieldStatus(
        fieldId: fieldId,
        health: HealthLevel.watch,
        water: WaterLevel.good,
        pest: PestLevel.watch,
        overlayHint: OverlayHint.far,
      );
    }

    // 2. Return previously persisted status if present
    final savedJson = prefs.getString(key);
    if (savedJson != null && savedJson.trim().isNotEmpty) {
      try {
        return FieldStatus.fromJson(savedJson);
      } catch (_) {
        // Fall through to deterministic generation
      }
    }

    // 3. Generate deterministic status based on fieldId
    final generated = _generateDeterministicStatus(fieldId);
    await prefs.setString(key, generated.toJson());
    return generated;
  }

  @override
  Future<void> saveFieldStatus(FieldStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefPrefix${status.fieldId}';
    await prefs.setString(key, status.toJson());
  }

  /// Generates deterministic, calm telemetry for a field.
  /// Modulo ensures the first demo fields remain completely calm ("all good").
  FieldStatus _generateDeterministicStatus(String fieldId) {
    final hash = fieldId.hashCode.abs();
    final variant = hash % 3;

    switch (variant) {
      case 0:
        // All good — calm demo
        return FieldStatus(
          fieldId: fieldId,
          health: HealthLevel.good,
          water: WaterLevel.good,
          pest: PestLevel.good,
          overlayHint: OverlayHint.none,
        );
      case 1:
        // Mild water stress on the right corner
        return FieldStatus(
          fieldId: fieldId,
          health: HealthLevel.watch,
          water: WaterLevel.low,
          pest: PestLevel.good,
          overlayHint: OverlayHint.right,
        );
      case 2:
      default:
        // Pest risk notice on the left corner
        return FieldStatus(
          fieldId: fieldId,
          health: HealthLevel.watch,
          water: WaterLevel.good,
          pest: PestLevel.watch,
          overlayHint: OverlayHint.left,
        );
    }
  }
}

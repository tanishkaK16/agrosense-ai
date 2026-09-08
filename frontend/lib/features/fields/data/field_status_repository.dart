import '../models/field_status.dart';

/// Contract for fetching and persisting mock/remote status telemetry for fields.
abstract class FieldStatusRepository {
  /// Loads the status for a specific [fieldId], generating a deterministic status if needed.
  Future<FieldStatus> getFieldStatus(String fieldId);

  /// Saves or updates the status for [status.fieldId].
  Future<void> saveFieldStatus(FieldStatus status);
}

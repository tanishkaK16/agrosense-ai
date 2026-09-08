import '../models/farm_alert.dart';

/// Contract for managing and retrieving farm alerts.
abstract class AlertsRepository {
  /// Fetches all active alerts, ordered by severity (Act now first).
  Future<List<FarmAlert>> getAlerts();

  /// Fetches a specific alert by its [id].
  Future<FarmAlert?> getAlertById(String id);

  /// Marks an alert as seen by the farmer.
  Future<void> markAlertSeen(String id);

  /// Clears persisted alerts state (useful in tests).
  Future<void> clear();
}

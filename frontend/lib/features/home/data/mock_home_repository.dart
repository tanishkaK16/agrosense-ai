import '../models/home_snapshot.dart';
import 'home_repository.dart';

/// Single switch to test different health conditions in development.
/// Options: FieldHealth.healthy, FieldHealth.watch, FieldHealth.actNow
const FieldHealth kDevHealthOverride = FieldHealth.healthy;

/// Single switch to test alert notifications in development.
const int kDevAlertCount = 0;

/// Mock implementation of [HomeRepository].
class MockHomeRepository implements HomeRepository {
  MockHomeRepository._();

  static final MockHomeRepository instance = MockHomeRepository._();

  @override
  Future<HomeSnapshot> getHomeSnapshot({
    String? defaultCrop,
    String? fieldName,
    FieldHealth? fieldHealth,
  }) async {
    final effectiveHealth = fieldHealth ?? kDevHealthOverride;
    return HomeSnapshot(
      temperatureC: 32,
      rainMm: 0,
      windKmh: 12,
      fieldName: fieldName ?? 'Main field',
      crop: defaultCrop != null && defaultCrop.trim().isNotEmpty
          ? defaultCrop
          : 'wheat',
      health: effectiveHealth,
      summarySentence: _getSummaryForHealth(effectiveHealth),
      alertCount: kDevAlertCount,
    );
  }

  static String _getSummaryForHealth(FieldHealth health) {
    switch (health) {
      case FieldHealth.healthy:
        return 'healthSummaryHealthy';
      case FieldHealth.watch:
        return 'healthSummaryWatch';
      case FieldHealth.actNow:
        return 'healthSummaryActNow';
    }
  }
}

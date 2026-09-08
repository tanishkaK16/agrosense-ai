import '../../../core/network/api_client.dart';
import '../models/farm_alert.dart';
import 'alerts_mapper.dart';
import 'alerts_repository.dart';

/// Live HTTP implementation of [AlertsRepository] talking to Django.
class LiveAlertsRepository implements AlertsRepository {
  LiveAlertsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<FarmAlert>> getAlerts() async {
    final res = await _apiClient.get('/alerts');
    if (res is List) {
      return res
          .whereType<Map<String, dynamic>>()
          .map(AlertsMapper.fromJson)
          .toList();
    }
    return const [];
  }

  @override
  Future<FarmAlert?> getAlertById(String id) async {
    final res = await _apiClient.get('/alerts/$id');
    if (res is Map<String, dynamic>) {
      return AlertsMapper.fromJson(res);
    }
    return null;
  }

  @override
  Future<void> markAlertSeen(String id) async {
    await _apiClient.post('/alerts/$id/seen');
  }

  @override
  Future<void> clear() async {
    // No-op for remote server in client implementation
  }
}

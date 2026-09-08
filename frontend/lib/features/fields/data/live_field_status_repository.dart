import '../../../core/network/api_client.dart';
import '../models/field_status.dart';
import 'field_status_mapper.dart';
import 'field_status_repository.dart';

/// Live HTTP implementation of [FieldStatusRepository] talking to Django.
class LiveFieldStatusRepository implements FieldStatusRepository {
  LiveFieldStatusRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<FieldStatus> getFieldStatus(String fieldId) async {
    final res = await _apiClient.get('/fields/$fieldId/status');
    if (res is Map<String, dynamic>) {
      return FieldStatusMapper.fromJson(res, fieldId: fieldId);
    }
    throw StateError('Invalid response format for field status');
  }

  @override
  Future<void> saveFieldStatus(FieldStatus status) async {
    await _apiClient.post(
      '/fields/${status.fieldId}/status',
      body: FieldStatusMapper.toJson(status),
    );
  }
}

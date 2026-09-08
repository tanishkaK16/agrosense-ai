import '../../../core/network/api_client.dart';
import '../models/farm_field.dart';
import 'fields_mapper.dart';
import 'fields_repository.dart';

/// Live HTTP implementation of [FieldsRepository] talking to Django.
class LiveFieldsRepository implements FieldsRepository {
  LiveFieldsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<FarmField>> getFields() async {
    final res = await _apiClient.get('/fields');
    if (res is List) {
      return res
          .whereType<Map<String, dynamic>>()
          .map(FieldsMapper.fromJson)
          .toList();
    }
    return const [];
  }

  @override
  Future<void> saveField(FarmField field) async {
    await _apiClient.post(
      '/fields',
      body: FieldsMapper.toCreatePayload(field),
    );
  }

  @override
  Future<void> deleteField(String id) async {
    await _apiClient.delete('/fields/$id');
  }
}

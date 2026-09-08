import '../../../core/network/api_client.dart';
import '../models/home_snapshot.dart';
import 'home_mapper.dart';
import 'home_repository.dart';

/// Live HTTP implementation of [HomeRepository] talking to Django.
class LiveHomeRepository implements HomeRepository {
  LiveHomeRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<HomeSnapshot> getHomeSnapshot({
    String? defaultCrop,
    String? fieldName,
    FieldHealth? fieldHealth,
  }) async {
    final res = await _apiClient.get('/home');
    if (res is Map<String, dynamic>) {
      return HomeMapper.fromJson(
        res,
        fallbackCrop: defaultCrop,
        fallbackFieldName: fieldName,
      );
    }
    throw StateError('Invalid response format for home snapshot');
  }
}

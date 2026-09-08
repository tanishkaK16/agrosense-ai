import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../models/home_snapshot.dart';
import 'home_repository.dart';
import 'live_home_repository.dart';
import 'mock_home_repository.dart';

/// Facade implementation of [HomeRepository].
/// Seamlessly routes between [LiveHomeRepository] and [MockHomeRepository].
class AppHomeRepository implements HomeRepository {
  AppHomeRepository({
    LiveHomeRepository? liveRepo,
    MockHomeRepository? mockRepo,
  })  : _liveRepo = liveRepo ?? LiveHomeRepository(),
        _mockRepo = mockRepo ?? MockHomeRepository.instance;

  static final AppHomeRepository instance = AppHomeRepository();

  final LiveHomeRepository _liveRepo;
  final MockHomeRepository _mockRepo;

  @override
  Future<HomeSnapshot> getHomeSnapshot({
    String? defaultCrop,
    String? fieldName,
    FieldHealth? fieldHealth,
  }) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getHomeSnapshot(
        defaultCrop: defaultCrop,
        fieldName: fieldName,
        fieldHealth: fieldHealth,
      );
    }

    try {
      final snapshot = await _liveRepo.getHomeSnapshot(
        defaultCrop: defaultCrop,
        fieldName: fieldName,
        fieldHealth: fieldHealth,
      );
      ConnectivityStatus.instance.reportLiveSuccess();
      return snapshot;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getHomeSnapshot(
        defaultCrop: defaultCrop,
        fieldName: fieldName,
        fieldHealth: fieldHealth,
      );
    }
  }
}

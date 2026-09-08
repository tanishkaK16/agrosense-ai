import '../../../core/cache/snapshot_cache.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../models/home_snapshot.dart';
import 'home_repository.dart';
import 'live_home_repository.dart';
import 'mock_home_repository.dart';

/// Facade implementation of [HomeRepository].
/// Seamlessly routes between [LiveHomeRepository], [SnapshotCache], and [MockHomeRepository].
class AppHomeRepository implements HomeRepository {
  AppHomeRepository({
    LiveHomeRepository? liveRepo,
    MockHomeRepository? mockRepo,
    SnapshotCache? cache,
  })  : _liveRepo = liveRepo ?? LiveHomeRepository(),
        _mockRepo = mockRepo ?? MockHomeRepository.instance,
        _cache = cache ?? SnapshotCache.instance;

  static final AppHomeRepository instance = AppHomeRepository();

  final LiveHomeRepository _liveRepo;
  final MockHomeRepository _mockRepo;
  final SnapshotCache _cache;

  @override
  Future<HomeSnapshot> getHomeSnapshot({
    String? defaultCrop,
    String? fieldName,
    FieldHealth? fieldHealth,
  }) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final cached = await _cache.getHome();
      if (cached != null) {
        return cached;
      }
      final mock = await _mockRepo.getHomeSnapshot(
        defaultCrop: defaultCrop,
        fieldName: fieldName,
        fieldHealth: fieldHealth,
      );
      await _cache.saveHome(mock);
      return mock;
    }

    try {
      final snapshot = await _liveRepo.getHomeSnapshot(
        defaultCrop: defaultCrop,
        fieldName: fieldName,
        fieldHealth: fieldHealth,
      );
      ConnectivityStatus.instance.reportLiveSuccess();
      await _cache.saveHome(snapshot);
      return snapshot;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final cached = await _cache.getHome();
      if (cached != null) {
        ConnectivityStatus.instance.reportCachedDataUsed(true);
        return cached;
      }

      final mock = await _mockRepo.getHomeSnapshot(
        defaultCrop: defaultCrop,
        fieldName: fieldName,
        fieldHealth: fieldHealth,
      );
      await _cache.saveHome(mock);
      return mock;
    }
  }
}

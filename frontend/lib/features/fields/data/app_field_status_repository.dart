import '../../../core/cache/snapshot_cache.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../models/field_status.dart';
import 'field_status_repository.dart';
import 'live_field_status_repository.dart';
import 'mock_field_status_repository.dart';

/// Facade implementation of [FieldStatusRepository].
/// Seamlessly routes between [LiveFieldStatusRepository], [SnapshotCache], and [MockFieldStatusRepository].
class AppFieldStatusRepository implements FieldStatusRepository {
  AppFieldStatusRepository({
    LiveFieldStatusRepository? liveRepo,
    MockFieldStatusRepository? mockRepo,
    SnapshotCache? cache,
  })  : _liveRepo = liveRepo ?? LiveFieldStatusRepository(),
        _mockRepo = mockRepo ?? MockFieldStatusRepository.instance,
        _cache = cache ?? SnapshotCache.instance;

  static final AppFieldStatusRepository instance = AppFieldStatusRepository();

  final LiveFieldStatusRepository _liveRepo;
  final MockFieldStatusRepository _mockRepo;
  final SnapshotCache _cache;

  @override
  Future<FieldStatus> getFieldStatus(String fieldId) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final cached = await _cache.getFieldStatus(fieldId);
      if (cached != null) {
        return cached;
      }
      final mock = await _mockRepo.getFieldStatus(fieldId);
      await _cache.saveFieldStatus(fieldId, mock);
      return mock;
    }

    try {
      final status = await _liveRepo.getFieldStatus(fieldId);
      ConnectivityStatus.instance.reportLiveSuccess();
      await _cache.saveFieldStatus(fieldId, status);
      return status;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final cached = await _cache.getFieldStatus(fieldId);
      if (cached != null) {
        return cached;
      }
      final mock = await _mockRepo.getFieldStatus(fieldId);
      await _cache.saveFieldStatus(fieldId, mock);
      return mock;
    }
  }

  @override
  Future<void> saveFieldStatus(FieldStatus status) async {
    await _cache.saveFieldStatus(status.fieldId, status);
    await _mockRepo.saveFieldStatus(status);

    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return;
    }

    try {
      await _liveRepo.saveFieldStatus(status);
      ConnectivityStatus.instance.reportLiveSuccess();
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
    }
  }
}

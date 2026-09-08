import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../models/field_status.dart';
import 'field_status_repository.dart';
import 'live_field_status_repository.dart';
import 'mock_field_status_repository.dart';

/// Facade implementation of [FieldStatusRepository].
/// Seamlessly routes between [LiveFieldStatusRepository] and [MockFieldStatusRepository].
class AppFieldStatusRepository implements FieldStatusRepository {
  AppFieldStatusRepository({
    LiveFieldStatusRepository? liveRepo,
    MockFieldStatusRepository? mockRepo,
  })  : _liveRepo = liveRepo ?? LiveFieldStatusRepository(),
        _mockRepo = mockRepo ?? MockFieldStatusRepository.instance;

  static final AppFieldStatusRepository instance = AppFieldStatusRepository();

  final LiveFieldStatusRepository _liveRepo;
  final MockFieldStatusRepository _mockRepo;

  @override
  Future<FieldStatus> getFieldStatus(String fieldId) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getFieldStatus(fieldId);
    }

    try {
      final status = await _liveRepo.getFieldStatus(fieldId);
      ConnectivityStatus.instance.reportLiveSuccess();
      return status;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getFieldStatus(fieldId);
    }
  }

  @override
  Future<void> saveFieldStatus(FieldStatus status) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _mockRepo.saveFieldStatus(status);
      return;
    }

    try {
      await _liveRepo.saveFieldStatus(status);
      ConnectivityStatus.instance.reportLiveSuccess();
      await _mockRepo.saveFieldStatus(status);
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _mockRepo.saveFieldStatus(status);
    }
  }
}

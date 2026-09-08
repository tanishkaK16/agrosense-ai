import '../../../core/cache/snapshot_cache.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/network/pending_sync_queue.dart';
import '../models/farmer_profile.dart';
import '../models/farmer_session.dart';
import 'auth_mapper.dart';
import 'auth_repository.dart';
import 'live_auth_repository.dart';
import 'mock_auth_repository.dart';

export 'mock_auth_repository.dart' show kShowDemoOtp;

/// Facade implementation of [AuthRepository].
/// Seamlessly routes between [LiveAuthRepository], [SnapshotCache], and [MockAuthRepository]
/// according to [AppConfig.instance.useLive] and network reachability.
class AppAuthRepository implements AuthRepository {
  AppAuthRepository({
    LiveAuthRepository? liveRepo,
    MockAuthRepository? mockRepo,
    SnapshotCache? cache,
  })  : _liveRepo = liveRepo ?? LiveAuthRepository(),
        _mockRepo = mockRepo ?? MockAuthRepository.instance,
        _cache = cache ?? SnapshotCache.instance;

  static final AppAuthRepository instance = AppAuthRepository();

  final LiveAuthRepository _liveRepo;
  final MockAuthRepository _mockRepo;
  final SnapshotCache _cache;

  @override
  Future<bool> requestOtp(String phone) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.requestOtp(phone);
    }

    try {
      final res = await _liveRepo.requestOtp(phone);
      ConnectivityStatus.instance.reportLiveSuccess();
      return res;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.requestOtp(phone);
    }
  }

  @override
  Future<FarmerSession?> verifyOtp(String phone, String code) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.verifyOtp(phone, code);
    }

    try {
      final session = await _liveRepo.verifyOtp(phone, code);
      if (session != null) {
        ConnectivityStatus.instance.reportLiveSuccess();
        return session;
      }
      return null;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.verifyOtp(phone, code);
    }
  }

  @override
  Future<void> saveProfile(FarmerProfile profile) async {
    await _cache.saveProfile(profile);
    await _mockRepo.saveProfile(profile);

    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return;
    }

    try {
      await _liveRepo.saveProfile(profile);
      ConnectivityStatus.instance.reportLiveSuccess();
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await PendingSyncQueue.instance.enqueue(
        'save_profile',
        AuthMapper.profileToJson(profile),
      );
    }
  }

  @override
  FarmerSession? currentSession() => _mockRepo.currentSession();

  @override
  FarmerProfile? currentProfile() => _mockRepo.currentProfile();

  @override
  bool get isLoggedIn => _mockRepo.isLoggedIn;
}

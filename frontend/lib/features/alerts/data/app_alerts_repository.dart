import 'package:flutter/foundation.dart';

import '../../../core/cache/snapshot_cache.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/network/pending_sync_queue.dart';
import '../models/farm_alert.dart';
import 'alerts_repository.dart';
import 'live_alerts_repository.dart';
import 'mock_alerts_repository.dart';

/// Facade implementation of [AlertsRepository].
/// Seamlessly routes between [LiveAlertsRepository], [SnapshotCache], and [MockAlertsRepository].
class AppAlertsRepository extends ChangeNotifier implements AlertsRepository {
  AppAlertsRepository({
    LiveAlertsRepository? liveRepo,
    MockAlertsRepository? mockRepo,
    SnapshotCache? cache,
  })  : _liveRepo = liveRepo ?? LiveAlertsRepository(),
        _mockRepo = mockRepo ?? MockAlertsRepository.instance,
        _cache = cache ?? SnapshotCache.instance {
    _mockRepo.addListener(notifyListeners);
  }

  static final AppAlertsRepository instance = AppAlertsRepository();

  final LiveAlertsRepository _liveRepo;
  final MockAlertsRepository _mockRepo;
  final SnapshotCache _cache;

  @override
  Future<List<FarmAlert>> getAlerts() async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final cached = await _cache.getAlerts();
      if (cached != null) {
        return cached;
      }
      final mock = await _mockRepo.getAlerts();
      await _cache.saveAlerts(mock);
      return mock;
    }

    try {
      final list = await _liveRepo.getAlerts();
      ConnectivityStatus.instance.reportLiveSuccess();
      await _cache.saveAlerts(list);
      return list;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final cached = await _cache.getAlerts();
      if (cached != null) {
        return cached;
      }
      final mock = await _mockRepo.getAlerts();
      await _cache.saveAlerts(mock);
      return mock;
    }
  }

  @override
  Future<FarmAlert?> getAlertById(String id) async {
    final alerts = await getAlerts();
    for (final a in alerts) {
      if (a.id == id) return a;
    }
    return _mockRepo.getAlertById(id);
  }

  @override
  Future<void> markAlertSeen(String id) async {
    await _cache.markAlertSeen(id);
    await _mockRepo.markAlertSeen(id);

    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      notifyListeners();
      return;
    }

    try {
      await _liveRepo.markAlertSeen(id);
      ConnectivityStatus.instance.reportLiveSuccess();
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await PendingSyncQueue.instance.enqueue(
        'mark_alert_seen',
        {'id': id},
      );
    }
    notifyListeners();
  }

  @override
  Future<void> clear() async {
    await _mockRepo.clear();
    await _cache.saveAlerts([]);
    notifyListeners();
  }
}

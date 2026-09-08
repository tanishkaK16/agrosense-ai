import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/network/pending_sync_queue.dart';
import '../models/farm_alert.dart';
import 'alerts_repository.dart';
import 'live_alerts_repository.dart';
import 'mock_alerts_repository.dart';

/// Facade implementation of [AlertsRepository].
/// Seamlessly routes between [LiveAlertsRepository] and [MockAlertsRepository].
class AppAlertsRepository extends ChangeNotifier implements AlertsRepository {
  AppAlertsRepository({
    LiveAlertsRepository? liveRepo,
    MockAlertsRepository? mockRepo,
  })  : _liveRepo = liveRepo ?? LiveAlertsRepository(),
        _mockRepo = mockRepo ?? MockAlertsRepository.instance {
    _mockRepo.addListener(notifyListeners);
  }

  static final AppAlertsRepository instance = AppAlertsRepository();

  final LiveAlertsRepository _liveRepo;
  final MockAlertsRepository _mockRepo;

  @override
  Future<List<FarmAlert>> getAlerts() async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getAlerts();
    }

    try {
      final list = await _liveRepo.getAlerts();
      ConnectivityStatus.instance.reportLiveSuccess();
      return list;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getAlerts();
    }
  }

  @override
  Future<FarmAlert?> getAlertById(String id) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getAlertById(id);
    }

    try {
      final alert = await _liveRepo.getAlertById(id);
      if (alert != null) {
        ConnectivityStatus.instance.reportLiveSuccess();
        return alert;
      }
      return _mockRepo.getAlertById(id);
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _mockRepo.getAlertById(id);
    }
  }

  @override
  Future<void> markAlertSeen(String id) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _mockRepo.markAlertSeen(id);
      notifyListeners();
      return;
    }

    try {
      await _liveRepo.markAlertSeen(id);
      ConnectivityStatus.instance.reportLiveSuccess();
      await _mockRepo.markAlertSeen(id);
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _mockRepo.markAlertSeen(id);
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
    notifyListeners();
  }
}

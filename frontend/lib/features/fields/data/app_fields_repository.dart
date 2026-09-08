import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/network/pending_sync_queue.dart';
import '../models/farm_field.dart';
import 'fields_mapper.dart';
import 'fields_repository.dart';
import 'live_fields_repository.dart';
import 'local_fields_repository.dart';

/// Facade implementation of [FieldsRepository].
/// Seamlessly routes between [LiveFieldsRepository] and [LocalFieldsRepository]
/// according to [AppConfig.instance.useLive] and network reachability.
class AppFieldsRepository extends ChangeNotifier implements FieldsRepository {
  AppFieldsRepository({
    LiveFieldsRepository? liveRepo,
    LocalFieldsRepository? localRepo,
  })  : _liveRepo = liveRepo ?? LiveFieldsRepository(),
        _localRepo = localRepo ?? LocalFieldsRepository.instance {
    _localRepo.addListener(notifyListeners);
  }

  static final AppFieldsRepository instance = AppFieldsRepository();

  final LiveFieldsRepository _liveRepo;
  final LocalFieldsRepository _localRepo;

  @override
  Future<List<FarmField>> getFields() async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _localRepo.getFields();
    }

    try {
      final list = await _liveRepo.getFields();
      ConnectivityStatus.instance.reportLiveSuccess();
      return list;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return _localRepo.getFields();
    }
  }

  @override
  Future<void> saveField(FarmField field) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _localRepo.saveField(field);
      return;
    }

    try {
      await _liveRepo.saveField(field);
      ConnectivityStatus.instance.reportLiveSuccess();
      // Also cache locally for offline continuity
      await _localRepo.saveField(field);
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _localRepo.saveField(field);
      await PendingSyncQueue.instance.enqueue(
        'save_field',
        FieldsMapper.toCreatePayload(field),
      );
    }
  }

  @override
  Future<void> deleteField(String id) async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _localRepo.deleteField(id);
      return;
    }

    try {
      await _liveRepo.deleteField(id);
      ConnectivityStatus.instance.reportLiveSuccess();
      await _localRepo.deleteField(id);
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await _localRepo.deleteField(id);
    }
  }
}

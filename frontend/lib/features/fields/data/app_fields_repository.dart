import 'package:flutter/foundation.dart';

import '../../../core/cache/snapshot_cache.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/network/pending_sync_queue.dart';
import '../models/farm_field.dart';
import 'fields_mapper.dart';
import 'fields_repository.dart';
import 'live_fields_repository.dart';
import 'local_fields_repository.dart';

/// Facade implementation of [FieldsRepository].
/// Seamlessly routes between [LiveFieldsRepository], [SnapshotCache], and [LocalFieldsRepository].
class AppFieldsRepository extends ChangeNotifier implements FieldsRepository {
  AppFieldsRepository({
    LiveFieldsRepository? liveRepo,
    LocalFieldsRepository? localRepo,
    SnapshotCache? cache,
  })  : _liveRepo = liveRepo ?? LiveFieldsRepository(),
        _localRepo = localRepo ?? LocalFieldsRepository.instance,
        _cache = cache ?? SnapshotCache.instance {
    _localRepo.addListener(notifyListeners);
  }

  static final AppFieldsRepository instance = AppFieldsRepository();

  final LiveFieldsRepository _liveRepo;
  final LocalFieldsRepository _localRepo;
  final SnapshotCache _cache;

  @override
  Future<List<FarmField>> getFields() async {
    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final local = await _localRepo.getFields();
      if (local.isNotEmpty) {
        await _cache.saveFields(local);
        return local;
      }
      final cached = await _cache.getFields();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      return local;
    }

    try {
      final list = await _liveRepo.getFields();
      ConnectivityStatus.instance.reportLiveSuccess();
      await _cache.saveFields(list);
      // Cache locally for offline continuity, preserving local fields
      for (final f in list) {
        await _localRepo.saveField(f);
      }
      return list;
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      final local = await _localRepo.getFields();
      if (local.isNotEmpty) {
        await _cache.saveFields(local);
        return local;
      }
      final cached = await _cache.getFields();
      if (cached != null) {
        return cached;
      }
      return local;
    }
  }

  @override
  Future<void> saveField(FarmField field) async {
    await _localRepo.saveField(field);
    final all = await _localRepo.getFields();
    await _cache.saveFields(all);

    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return;
    }

    try {
      await _liveRepo.saveField(field);
      ConnectivityStatus.instance.reportLiveSuccess();
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
      await PendingSyncQueue.instance.enqueue(
        'save_field',
        FieldsMapper.toCreatePayload(field),
      );
    }
  }

  @override
  Future<void> deleteField(String id) async {
    await _localRepo.deleteField(id);
    final all = await _localRepo.getFields();
    await _cache.saveFields(all);

    if (!AppConfig.instance.useLive) {
      ConnectivityStatus.instance.reportFallbackUsed();
      return;
    }

    try {
      await _liveRepo.deleteField(id);
      ConnectivityStatus.instance.reportLiveSuccess();
    } catch (_) {
      ConnectivityStatus.instance.reportFallbackUsed();
    }
  }
}

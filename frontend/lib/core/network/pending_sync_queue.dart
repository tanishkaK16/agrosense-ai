import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Best-effort local pending queue for offline writes.
class PendingSyncQueue {
  PendingSyncQueue._();

  static final PendingSyncQueue instance = PendingSyncQueue._();

  static const String _keyPendingActions = 'pending_offline_actions';

  Future<void> enqueue(String actionType, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPendingActions) ?? [];
    final item = jsonEncode({
      'action': actionType,
      'payload': payload,
      'queued_at': DateTime.now().toIso8601String(),
    });
    list.add(item);
    await prefs.setStringList(_keyPendingActions, list);
  }

  Future<List<Map<String, dynamic>>> getPending() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPendingActions) ?? [];
    return list
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingActions);
  }
}

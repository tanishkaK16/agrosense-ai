import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight JSON key-value cache box backed by SharedPreferences.
///
/// Guaranteed never to crash on corrupt or malformed cache entries:
/// any read decoding error quietly purges the offending key and returns null.
class CacheBox {
  CacheBox({String prefix = 'snap_cache_'}) : _prefix = prefix;

  static final CacheBox instance = CacheBox();

  final String _prefix;

  String _prefixed(String key) => '$_prefix$key';

  /// Write a serializable value into the cache under [key].
  Future<void> write(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(value);
    await prefs.setString(_prefixed(key), jsonStr);
  }

  /// Read and decode a JSON value under [key].
  ///
  /// Returns null if key is missing or data is malformed (and deletes corrupt key).
  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefixed(key));
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      return jsonDecode(raw);
    } catch (_) {
      // Corrupt cache — safely purge and return null
      await prefs.remove(_prefixed(key));
      return null;
    }
  }

  /// Delete a single cached [key].
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefixed(key));
  }

  /// Clear all keys belonging to this cache box.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

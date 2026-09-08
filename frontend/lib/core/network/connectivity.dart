import 'package:flutter/foundation.dart';

/// Tracks connection state and whether data was served from fallback mock storage.
class ConnectivityStatus extends ChangeNotifier {
  ConnectivityStatus._();

  static final ConnectivityStatus instance = ConnectivityStatus._();

  bool _isUsingFallback = true;
  bool _isLiveConnected = false;
  bool _isUsingCachedData = false;

  /// Whether the last request or current state is operating on local/mock fallback data.
  bool get isUsingFallback => _isUsingFallback;

  /// Whether a successful connection to the live backend has been established.
  bool get isLiveConnected => _isLiveConnected;

  /// Whether data is currently being served from offline cached snapshots.
  bool get isUsingCachedData => _isUsingCachedData;

  void reportFallbackUsed() {
    if (!_isUsingFallback || _isLiveConnected) {
      _isUsingFallback = true;
      _isLiveConnected = false;
      notifyListeners();
    }
  }

  void reportCachedDataUsed([bool value = true]) {
    if (_isUsingCachedData != value) {
      _isUsingCachedData = value;
      notifyListeners();
    }
  }

  void reportLiveSuccess() {
    _isUsingCachedData = false;
    if (_isUsingFallback || !_isLiveConnected) {
      _isUsingFallback = false;
      _isLiveConnected = true;
      notifyListeners();
    }
  }

  void reset() {
    _isUsingFallback = true;
    _isLiveConnected = false;
    _isUsingCachedData = false;
    notifyListeners();
  }
}

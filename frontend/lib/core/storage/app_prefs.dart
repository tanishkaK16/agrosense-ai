import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized storage for user preferences, navigation flags, and session data.
///
/// Manages:
/// - Selected locale (persisted with key `selected_locale`)
/// - Onboarding completion flag (persisted with key `onboarding_complete`)
/// - Authenticated session (persisted with key `auth_session`)
/// - Farmer profile (persisted with key `farmer_profile`)
class AppPrefs extends ChangeNotifier {
  AppPrefs._();

  static final AppPrefs instance = AppPrefs._();

  static const String keyLocale = 'selected_locale';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySession = 'auth_session';
  static const String keyProfile = 'farmer_profile';

  late SharedPreferences _prefs;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  String? get localeCode =>
      _initialized ? _prefs.getString(keyLocale) : null;

  bool get isOnboardingDone =>
      _initialized ? (_prefs.getBool(keyOnboardingComplete) ?? false) : false;

  String? get sessionJson =>
      _initialized ? _prefs.getString(keySession) : null;

  String? get profileJson =>
      _initialized ? _prefs.getString(keyProfile) : null;

  bool get hasSession =>
      _initialized ? (_prefs.getString(keySession)?.trim().isNotEmpty ?? false) : false;

  bool get hasProfile =>
      _initialized ? (_prefs.getString(keyProfile)?.trim().isNotEmpty ?? false) : false;

  /// Initialize and load saved values from disk.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    notifyListeners();
  }

  /// Save selected locale code (e.g. 'en', 'hi', 'mr').
  Future<void> setLocaleCode(String code) async {
    await _prefs.setString(keyLocale, code);
    notifyListeners();
  }

  /// Mark onboarding as completed.
  Future<void> setOnboardingDone([bool done = true]) async {
    await _prefs.setBool(keyOnboardingComplete, done);
    notifyListeners();
  }

  /// Save serialized session JSON.
  Future<void> setSessionJson(String? json) async {
    if (json == null) {
      await _prefs.remove(keySession);
    } else {
      await _prefs.setString(keySession, json);
    }
    notifyListeners();
  }

  /// Save serialized farmer profile JSON.
  Future<void> setProfileJson(String? json) async {
    if (json == null) {
      await _prefs.remove(keyProfile);
    } else {
      await _prefs.setString(keyProfile, json);
    }
    notifyListeners();
  }

  /// Clear session and profile (useful for testing).
  Future<void> clearSession() async {
    await _prefs.remove(keySession);
    await _prefs.remove(keyProfile);
    notifyListeners();
  }

  /// Clear all stored preferences (for complete app reset).
  Future<void> clear() async {
    await _prefs.remove(keyLocale);
    await _prefs.remove(keyOnboardingComplete);
    await _prefs.remove(keySession);
    await _prefs.remove(keyProfile);
    notifyListeners();
  }
}

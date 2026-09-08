import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized storage for user preferences and navigation flags.
///
/// Manages:
/// - Selected locale (persisted with key `selected_locale`)
/// - Onboarding completion flag (persisted with key `onboarding_complete`)
class AppPrefs extends ChangeNotifier {
  AppPrefs._();

  static final AppPrefs instance = AppPrefs._();

  static const String keyLocale = 'selected_locale';
  static const String keyOnboardingComplete = 'onboarding_complete';

  late SharedPreferences _prefs;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  String? get localeCode => _prefs.getString(keyLocale);

  bool get isOnboardingDone => _prefs.getBool(keyOnboardingComplete) ?? false;

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

  /// Clear all stored preferences (for testing or reset).
  Future<void> clear() async {
    await _prefs.remove(keyLocale);
    await _prefs.remove(keyOnboardingComplete);
    notifyListeners();
  }
}

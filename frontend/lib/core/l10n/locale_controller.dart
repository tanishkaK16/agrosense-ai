import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocaleKey = 'selected_locale';

/// Controls the app locale, persisted to [SharedPreferences].
///
/// Usage:
///   final controller = LocaleController();
///   await controller.init();
///   controller.addListener(() { ... });
///   controller.setLocale(const Locale('hi'));
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController _instance = LocaleController._();

  /// Singleton accessor — call [init] before use.
  static LocaleController get instance => _instance;

  Locale? _locale;
  bool _initialized = false;

  /// The currently active locale, or null if none has been chosen yet
  /// (first-launch state — triggers language screen redirect).
  Locale? get locale => _locale;

  /// True once [init] has completed.
  bool get initialized => _initialized;

  /// True when the user has already chosen a language.
  bool get hasLocale => _locale != null;

  /// Load persisted locale from device storage.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null && saved.isNotEmpty) {
      _locale = Locale(saved);
    }
    _initialized = true;
    notifyListeners();
  }

  /// Persist and apply a new locale.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
    notifyListeners();
  }

  /// Clear saved locale (used during testing / reset flows).
  Future<void> clear() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLocaleKey);
    notifyListeners();
  }
}

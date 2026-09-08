import 'package:flutter/material.dart';

import '../storage/app_prefs.dart';

/// Supported text size scale options for farmer accessibility.
enum AppTextScale {
  small(0.9, 'small'),
  standard(1.0, 'default'),
  large(1.25, 'large');

  const AppTextScale(this.factor, this.code);

  final double factor;
  final String code;

  static AppTextScale fromCode(String? code) {
    switch (code) {
      case 'small':
        return AppTextScale.small;
      case 'large':
        return AppTextScale.large;
      case 'default':
      default:
        return AppTextScale.standard;
    }
  }

  static AppTextScale fromFactor(double? factor) {
    if (factor == null) return AppTextScale.standard;
    if ((factor - 0.9).abs() < 0.05) return AppTextScale.small;
    if ((factor - 1.25).abs() < 0.05) return AppTextScale.large;
    return AppTextScale.standard;
  }
}

/// Controls the user-selected text scale, persisted via [AppPrefs].
/// Applies a clamped [TextScaler] taking into account both system font scaling
/// and farmer preference (Small 0.9x, Default 1.0x, Large 1.25x), clamped to max 1.4.
class TextScaleController extends ChangeNotifier {
  TextScaleController._();

  static final TextScaleController instance = TextScaleController._();

  AppTextScale _scale = AppTextScale.standard;
  bool _initialized = false;

  AppTextScale get scale => _scale;
  AppTextScale get currentScale => _scale;
  double get scaleFactor => _scale.factor;
  double get factor => _scale.factor;
  bool get initialized => _initialized;

  /// Returns the clamped scale factor for a given system text scale factor.
  double effectiveScale(double systemFactor) {
    return (systemFactor * _scale.factor).clamp(0.85, 1.4);
  }

  /// Load persisted text scale from storage.
  Future<void> init() async {
    if (!AppPrefs.instance.isInitialized) {
      await AppPrefs.instance.init();
    }
    final saved = AppPrefs.instance.textScale;
    _scale = AppTextScale.fromCode(saved);
    _initialized = true;
    notifyListeners();
  }

  /// Change and persist the farmer's text size preference.
  Future<void> setScale(AppTextScale newScale) async {
    _scale = newScale;
    await AppPrefs.instance.setTextScale(newScale.code);
    notifyListeners();
  }

  /// Produces a clamped [TextScaler] honoring system text scaling but
  /// clamping the combined factor so layouts never explode past ~1.4.
  TextScaler textScaler(BuildContext context) {
    final systemFactor = MediaQuery.textScalerOf(context).scale(1.0);
    final combined = (systemFactor * _scale.factor).clamp(0.85, 1.4);
    return TextScaler.linear(combined);
  }

  /// Reset to standard scale (used in tests / full resets).
  Future<void> clear() async {
    _scale = AppTextScale.standard;
    notifyListeners();
  }
}

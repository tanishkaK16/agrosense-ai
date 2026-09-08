import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/locale_controller.dart';

/// Text-to-speech service tailored for farmer accessibility.
///
/// Features:
/// - Supports en-IN, hi-IN, mr-IN
/// - Graceful fallback: mr-IN -> hi-IN -> en-IN
/// - Measured speech rate (slower than default for clarity)
/// - Toggle behavior: if speaking, stops; if idle, speaks
/// - ChangeNotifier for reactive UI (volume icon updates state)
class VoiceService extends ChangeNotifier {
  VoiceService._() {
    _initTts();
  }

  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _initialized = false;
  String? _lastSpokenText;

  bool get isSpeaking => _isSpeaking;
  String? get lastSpokenText => _lastSpokenText;

  void _initTts() {
    if (_initialized) return;

    _tts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _lastSpokenText = null;
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      _lastSpokenText = null;
      notifyListeners();
    });

    _tts.setErrorHandler((dynamic msg) {
      _isSpeaking = false;
      _lastSpokenText = null;
      notifyListeners();
    });

    // Slightly slower rate than default (0.5) for natural, clear listening
    try {
      _tts.setSpeechRate(0.44);
      _tts.setVolume(1.0);
      _tts.setPitch(1.0);
    } catch (_) {
      // Ignored in unit test environments without platform channels
    }

    _initialized = true;
  }

  /// Stop any active speech.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignored if device TTS fails
    } finally {
      _isSpeaking = false;
      _lastSpokenText = null;
      notifyListeners();
    }
  }

  /// Toggle speech:
  /// - If currently speaking, stop immediately.
  /// - If idle, speak [text] using [languageCode] (or current app locale).
  Future<void> toggle({required String text, String? languageCode}) async {
    if (_isSpeaking) {
      await stop();
    } else {
      await speak(text, languageCode: languageCode);
    }
  }

  /// Speak [text] aloud.
  ///
  /// Uses [languageCode] if supplied, otherwise uses active app locale.
  /// Applies fallback chain: mr-IN -> hi-IN -> en-IN.
  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;

    // Stop current speech before starting new sentence
    if (_isSpeaking) {
      await _tts.stop();
    }

    final code = languageCode ??
        LocaleController.instance.locale?.languageCode ??
        'en';

    final targetLang = await _resolveLanguage(code);

    try {
      await _tts.setLanguage(targetLang);
      // Ensure speech rate remains steady
      await _tts.setSpeechRate(0.44);
      _lastSpokenText = text;
      _isSpeaking = true;
      notifyListeners();
      await _tts.speak(text);
    } catch (_) {
      _isSpeaking = false;
      _lastSpokenText = null;
      notifyListeners();
    }
  }

  /// Resolve language tag with fallback:
  /// - 'mr' -> mr-IN -> hi-IN -> en-IN
  /// - 'hi' -> hi-IN -> en-IN
  /// - 'en' -> en-IN -> en-US
  Future<String> _resolveLanguage(String langCode) async {
    if (langCode == 'mr') {
      if (await _isLanguageSupported('mr-IN')) return 'mr-IN';
      if (await _isLanguageSupported('hi-IN')) return 'hi-IN';
      return 'en-IN';
    } else if (langCode == 'hi') {
      if (await _isLanguageSupported('hi-IN')) return 'hi-IN';
      return 'en-IN';
    } else {
      if (await _isLanguageSupported('en-IN')) return 'en-IN';
      return 'en-US';
    }
  }

  Future<bool> _isLanguageSupported(String tag) async {
    try {
      final res = await _tts.isLanguageAvailable(tag);
      if (res is bool) return res;
      if (res is num) return res >= 0;
      return false;
    } catch (_) {
      return false;
    }
  }
}

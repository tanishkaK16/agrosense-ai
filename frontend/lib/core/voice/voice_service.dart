import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../l10n/locale_controller.dart';

/// Unified voice service for text-to-speech (TTS) output and speech-to-text (STT) input.
///
/// Features:
/// - Supports en-IN, hi-IN, mr-IN with measured rates for farmer clarity
/// - STT locale follows saved app locale (en-IN, hi-IN, mr-IN)
///   Fallback rule: if mr-IN STT is missing on the OS, falls back to hi-IN then en-IN
/// - Mutual exclusion: stopping TTS when listening starts, stopping STT when TTS starts
/// - Safe error handling without crashing on emulators lacking Google speech packs
class VoiceService extends ChangeNotifier {
  VoiceService._() {
    _initTts();
  }

  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _ttsInitialized = false;
  bool _sttInitialized = false;
  bool _sttAvailable = false;
  String? _lastSpokenText;
  String _currentRecognizedWords = '';

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isSttAvailable => _sttAvailable;
  String? get lastSpokenText => _lastSpokenText;
  String get currentRecognizedWords => _currentRecognizedWords;

  // ── TTS Methods ─────────────────────────────────────────────────────────────

  void _initTts() {
    if (_ttsInitialized) return;

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

    try {
      _tts.setSpeechRate(0.44);
      _tts.setVolume(1.0);
      _tts.setPitch(1.0);
    } catch (_) {
      // Platform channel ignored in unit tests
    }

    _ttsInitialized = true;
  }

  /// Stop any active speech.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignored
    } finally {
      _isSpeaking = false;
      _lastSpokenText = null;
      notifyListeners();
    }
  }

  /// Toggle speech: if speaking, stop; if idle, speak.
  Future<void> toggle({required String text, String? languageCode}) async {
    if (_isSpeaking) {
      await stop();
    } else {
      await speak(text, languageCode: languageCode);
    }
  }

  /// Speak [text] aloud in current or specified locale.
  /// Stops listening if currently active.
  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;

    // Mutual exclusion: stop listening when speech starts
    if (_isListening) {
      await stopListening();
    }

    if (_isSpeaking) {
      await _tts.stop();
    }

    final code = languageCode ??
        LocaleController.instance.locale?.languageCode ??
        'en';

    final targetLang = await _resolveTtsLanguage(code);

    try {
      await _tts.setLanguage(targetLang);
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

  Future<String> _resolveTtsLanguage(String langCode) async {
    if (langCode == 'mr') {
      if (await _isTtsLanguageSupported('mr-IN')) return 'mr-IN';
      if (await _isTtsLanguageSupported('hi-IN')) return 'hi-IN';
      return 'en-IN';
    } else if (langCode == 'hi') {
      if (await _isTtsLanguageSupported('hi-IN')) return 'hi-IN';
      return 'en-IN';
    } else {
      if (await _isTtsLanguageSupported('en-IN')) return 'en-IN';
      return 'en-US';
    }
  }

  Future<bool> _isTtsLanguageSupported(String tag) async {
    try {
      final res = await _tts.isLanguageAvailable(tag);
      if (res is bool) return res;
      if (res is num) return res >= 0;
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── STT (Voice In) Methods ──────────────────────────────────────────────────

  /// Initialize Speech-to-Text safely. Returns true if microphone and recognizer are available.
  Future<bool> initSpeech() async {
    if (_sttInitialized && _sttAvailable) return true;

    try {
      _sttAvailable = await _stt.initialize(
        onError: (SpeechRecognitionError error) {
          _isListening = false;
          notifyListeners();
        },
        onStatus: (String status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      _sttInitialized = true;
    } catch (_) {
      _sttAvailable = false;
      _sttInitialized = true;
    }

    return _sttAvailable;
  }

  /// Start recording voice input for up to ~4 seconds.
  /// Stops TTS before listening begins.
  Future<bool> startListening({
    required void Function(String words, bool isFinal) onResult,
    void Function(String error)? onError,
  }) async {
    // Mutual exclusion: stop TTS when listening starts
    if (_isSpeaking) {
      await stop();
    }

    final available = await initSpeech();
    if (!available) {
      onError?.call('unavailable');
      return false;
    }

    _currentRecognizedWords = '';
    _isListening = true;
    notifyListeners();

    final targetLocaleId = await _resolveSttLocale();

    try {
      await _stt.listen(
        onResult: (SpeechRecognitionResult result) {
          _currentRecognizedWords = result.recognizedWords;
          notifyListeners();
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          localeId: targetLocaleId,
          listenFor: const Duration(seconds: 4),
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          cancelOnError: true,
        ),
      );
      return true;
    } catch (e) {
      _isListening = false;
      notifyListeners();
      onError?.call(e.toString());
      return false;
    }
  }

  /// Stop active listening session.
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _stt.stop();
    } catch (_) {
      // Ignored
    } finally {
      _isListening = false;
      notifyListeners();
    }
  }

  /// Cancel listening session without returning final result.
  Future<void> cancelListening() async {
    try {
      await _stt.cancel();
    } catch (_) {
      // Ignored
    } finally {
      _isListening = false;
      _currentRecognizedWords = '';
      notifyListeners();
    }
  }

  /// Resolve Speech-to-text locale ID:
  /// Follows saved locale: mr -> mr_IN.
  /// Fallback comment: If mr_IN STT is missing on device OS, fall back to hi_IN then en_IN.
  Future<String> _resolveSttLocale() async {
    final langCode =
        LocaleController.instance.locale?.languageCode ?? 'en';

    try {
      final availableLocales = await _stt.locales();
      final localeIds = availableLocales.map((l) => l.localeId).toList();

      if (langCode == 'mr') {
        // Look for Marathi locale (mr_IN or mr-IN)
        final mrMatch = localeIds.firstWhere(
          (id) => id.toLowerCase().startsWith('mr'),
          orElse: () => '',
        );
        if (mrMatch.isNotEmpty) return mrMatch;

        // Fallback: hi_IN if mr_IN is missing on the device
        final hiMatch = localeIds.firstWhere(
          (id) => id.toLowerCase().startsWith('hi'),
          orElse: () => '',
        );
        if (hiMatch.isNotEmpty) return hiMatch;

        // Secondary fallback: en_IN
        final enMatch = localeIds.firstWhere(
          (id) => id.toLowerCase().startsWith('en'),
          orElse: () => 'en_IN',
        );
        return enMatch;
      } else if (langCode == 'hi') {
        final hiMatch = localeIds.firstWhere(
          (id) => id.toLowerCase().startsWith('hi'),
          orElse: () => '',
        );
        if (hiMatch.isNotEmpty) return hiMatch;
        return 'en_IN';
      } else {
        final enMatch = localeIds.firstWhere(
          (id) => id.toLowerCase().startsWith('en_in') || id.toLowerCase().startsWith('en-in'),
          orElse: () => 'en_IN',
        );
        return enMatch;
      }
    } catch (_) {
      if (langCode == 'mr') return 'mr_IN';
      if (langCode == 'hi') return 'hi_IN';
      return 'en_IN';
    }
  }
}

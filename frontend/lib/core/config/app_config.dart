/// Runtime application configuration for backend connection modes.
class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const bool _envUseLive = bool.fromEnvironment(
    'API_USE_LIVE',
    defaultValue: false,
  );

  String _baseUrl = _envBaseUrl;
  bool _useLive = _envUseLive;

  /// Active base URL of the Django backend.
  String get baseUrl => _baseUrl;

  /// Whether repositories should attempt live HTTP requests to the backend.
  /// Defaults to false so the application remains fully functional offline/mocked today.
  bool get useLive => _useLive;

  /// Configure base URL at runtime.
  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Toggle live backend mode at runtime.
  void setUseLive(bool value) {
    _useLive = value;
  }

  /// Reset to defaults.
  void reset() {
    _baseUrl = _envBaseUrl;
    _useLive = _envUseLive;
  }
}

/// Distinct categories of network and API client errors.
enum ApiErrorType {
  unauthorized, // 401
  notFound,     // 404
  server,       // 5xx
  offline,      // SocketException / DNS lookup failure
  timeout,      // Request duration exceeded ~8s
  unknown,
}

/// Typed exception representing API failures.
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;
  bool get isNotFound => type == ApiErrorType.notFound;
  bool get isServer => type == ApiErrorType.server;
  bool get isOffline => type == ApiErrorType.offline;
  bool get isTimeout => type == ApiErrorType.timeout;

  @override
  String toString() => 'ApiException($type, status: $statusCode, message: "$message")';
}

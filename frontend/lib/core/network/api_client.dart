import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../features/auth/models/farmer_session.dart';
import '../config/app_config.dart';
import '../storage/app_prefs.dart';
import 'api_exception.dart';

/// HTTP API Client for communicating with the Django backend.
///
/// Features:
/// - ~8 second timeout
/// - JSON headers and encoding/decoding
/// - Bearer token injection from authenticated session
/// - Typed exception mapping (unauthorized, notFound, server, offline, timeout)
/// - Automatic session clearing on 401 Unauthorized
/// - Configurable client for unit test mocking
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.onUnauthorized,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// Optional callback invoked when a 401 Unauthorized response is received.
  final void Function()? onUnauthorized;

  static const Duration defaultTimeout = Duration(seconds: 8);

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final base = AppConfig.instance.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$base/api/v1$normalizedPath';

    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  String? _getToken() {
    final jsonStr = AppPrefs.instance.sessionJson;
    if (jsonStr != null && jsonStr.trim().isNotEmpty) {
      try {
        final session = FarmerSession.fromJson(jsonStr);
        return session.token;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Perform HTTP GET request.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    return _send(() => _httpClient.get(uri, headers: _buildHeaders(headers)));
  }

  /// Perform HTTP POST request.
  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _send(() => _httpClient.post(
          uri,
          headers: _buildHeaders(headers),
          body: encodedBody,
        ));
  }

  /// Perform HTTP PUT request.
  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _send(() => _httpClient.put(
          uri,
          headers: _buildHeaders(headers),
          body: encodedBody,
        ));
  }

  /// Perform HTTP DELETE request.
  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    return _send(() => _httpClient.delete(uri, headers: _buildHeaders(headers)));
  }

  Future<dynamic> _send(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn().timeout(defaultTimeout);
      return _processResponse(response);
    } on TimeoutException {
      throw const ApiException(
        type: ApiErrorType.timeout,
        message: 'Request timed out after 8 seconds.',
      );
    } on SocketException catch (e) {
      throw ApiException(
        type: ApiErrorType.offline,
        message: 'Network is unreachable: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        type: ApiErrorType.offline,
        message: 'Connection failed: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        type: ApiErrorType.unknown,
        message: e.toString(),
      );
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = response.body;

    dynamic decodedJson;
    if (bodyString.trim().isNotEmpty) {
      try {
        decodedJson = jsonDecode(bodyString);
      } catch (_) {
        decodedJson = null;
      }
    }

    String errorMessage = 'Request failed with status $statusCode';
    if (decodedJson is Map && decodedJson['detail'] is String) {
      errorMessage = decodedJson['detail'] as String;
    }

    if (statusCode == 401) {
      // Clear session on 401 Unauthorized
      AppPrefs.instance.setSessionJson(null);
      onUnauthorized?.call();
      throw ApiException(
        type: ApiErrorType.unauthorized,
        statusCode: statusCode,
        message: errorMessage,
      );
    }

    if (statusCode == 404) {
      throw ApiException(
        type: ApiErrorType.notFound,
        statusCode: statusCode,
        message: errorMessage,
      );
    }

    if (statusCode >= 500) {
      throw ApiException(
        type: ApiErrorType.server,
        statusCode: statusCode,
        message: errorMessage,
      );
    }

    if (statusCode >= 400) {
      throw ApiException(
        type: ApiErrorType.unknown,
        statusCode: statusCode,
        message: errorMessage,
      );
    }

    return decodedJson;
  }
}

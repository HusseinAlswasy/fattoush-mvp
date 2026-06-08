import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:customer_app/src/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static String? _healthyBaseUrl;

  final http.Client _client;

  Future<List<dynamic>> getList(
    String path, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _executeRequest(
      path,
      queryParameters: queryParameters,
      sendRequest: (uri) => _client.get(uri, headers: _headers(token: token)),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getObject(
    String path, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _executeRequest(
      path,
      queryParameters: queryParameters,
      sendRequest: (uri) => _client.get(uri, headers: _headers(token: token)),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postObject(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _executeRequest(
      path,
      allowFallback: false,
      sendRequest: (uri) => _client.post(
        uri,
        headers: _headers(token: token),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> putObject(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _executeRequest(
      path,
      allowFallback: false,
      sendRequest: (uri) => _client.put(
        uri,
        headers: _headers(token: token),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> delete(
    String path, {
    String? token,
  }) async {
    final response = await _executeRequest(
      path,
      allowFallback: false,
      sendRequest: (uri) => _client.delete(
        uri,
        headers: _headers(token: token),
      ),
    );

    _throwIfInvalid(response, path);
  }

  Uri _buildUri(
    String baseUrl,
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _executeRequest(
    String path, {
    bool allowFallback = true,
    Map<String, String>? queryParameters,
    required Future<http.Response> Function(Uri uri) sendRequest,
  }) async {
    final errors = <String>[];
    final baseUrls = allowFallback
        ? _prioritizedBaseUrls()
        : [_healthyBaseUrl ?? AppConfig.productionApiUrl];
    for (final baseUrl in baseUrls) {
      try {
        final uri = _buildUri(
          baseUrl,
          path,
          queryParameters: queryParameters,
        );
        final response =
            await sendRequest(uri).timeout(const Duration(seconds: 12));
        _healthyBaseUrl = baseUrl;
        return response;
      } on SocketException catch (error) {
        final endpoint = '$baseUrl$path';
        errors.add('$endpoint => ${error.message}');
      } on TimeoutException {
        errors.add('$baseUrl$path => timeout after 12 seconds');
      }
    }

    throw ApiConnectionException(
      message: 'No available backend endpoint.',
      triedEndpoints: baseUrls,
      details: errors,
    );
  }

  List<String> _prioritizedBaseUrls() {
    final configuredUrls = AppConfig.apiBaseUrls;
    final healthyBaseUrl = _healthyBaseUrl;
    if (healthyBaseUrl == null || !configuredUrls.contains(healthyBaseUrl)) {
      return configuredUrls;
    }

    return [
      healthyBaseUrl,
      ...configuredUrls.where((url) => url != healthyBaseUrl),
    ];
  }

  void _throwIfInvalid(http.Response response, String path) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String? serverMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String) {
          serverMessage = message;
        } else if (message is List && message.isNotEmpty) {
          serverMessage = message.join(', ');
        }
      }
    } on FormatException {
      serverMessage = null;
    }

    throw ApiException(
      path: path,
      statusCode: response.statusCode,
      serverMessage: serverMessage,
      rawBody: response.body,
    );
  }
}

class ApiException implements Exception {
  ApiException({
    required this.path,
    required this.statusCode,
    this.serverMessage,
    this.rawBody,
  });

  final String path;
  final int statusCode;
  final String? serverMessage;
  final String? rawBody;

  @override
  String toString() =>
      'Request failed for $path with status $statusCode: ${serverMessage ?? rawBody ?? ''}';
}

class ApiConnectionException implements Exception {
  const ApiConnectionException({
    required this.message,
    required this.triedEndpoints,
    required this.details,
  });

  final String message;
  final List<String> triedEndpoints;
  final List<String> details;
}

import 'dart:convert';

import 'package:customer_app/src/core/config/app_config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<dynamic>> getList(
    String path, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters: queryParameters),
      headers: _headers(token: token),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getObject(
    String path, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _buildUri(path, queryParameters: queryParameters),
      headers: _headers(token: token),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postObject(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _buildUri(path),
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> putObject(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.put(
      _buildUri(path),
      headers: _headers(token: token),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );

    _throwIfInvalid(response, path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> delete(
    String path, {
    String? token,
  }) async {
    final response = await _client.delete(
      _buildUri(path),
      headers: _headers(token: token),
    );

    _throwIfInvalid(response, path);
  }

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
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

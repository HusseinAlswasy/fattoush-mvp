import 'dart:convert';

import 'package:customer_app/src/core/config/app_config.dart';
import 'package:customer_app/src/core/network/api_client.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:http/http.dart' as http;

class AdminApiService {
  AdminApiService({ApiClient? client, http.Client? httpClient})
      : _client = client ?? ApiClient(),
        _httpClient = httpClient ?? http.Client();

  final ApiClient _client;
  final http.Client _httpClient;

  Future<List<Product>> getProducts(String token) async {
    final response = await _client.getList('/admin/products', token: token);
    return response
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getOrders(String token) async {
    final response = await _client.getList('/admin/orders', token: token);
    return response.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getDailyReport(String token) {
    return _client.getObject('/admin/reports/daily', token: token);
  }

  Future<Map<String, dynamic>> getMonthlyReport(String token) {
    return _client.getObject('/admin/reports/monthly', token: token);
  }

  Future<String> uploadProductImage({
    required String token,
    required String imagePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}/admin/products/upload-image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        path: '/admin/products/upload-image',
        statusCode: response.statusCode,
        rawBody: response.body,
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['imageUrl'] as String;
  }

  Future<void> createProduct({
    required String token,
    required String name,
    required String category,
    required double price,
    required bool isActive,
    String? description,
    String? imageUrl,
  }) async {
    await _client.postObject(
      '/admin/products',
      token: token,
      body: {
        'name': name,
        'category': category,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'isActive': isActive,
      },
    );
  }

  Future<void> updateProduct({
    required String token,
    required String productId,
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) {
      body['name'] = name;
    }
    if (category != null) {
      body['category'] = category;
    }
    if (price != null) {
      body['price'] = price;
    }
    if (description != null) {
      body['description'] = description;
    }
    if (imageUrl != null) {
      body['imageUrl'] = imageUrl;
    }
    if (isActive != null) {
      body['isActive'] = isActive;
    }

    await _client.putObject(
      '/admin/products/$productId',
      token: token,
      body: body,
    );
  }

  Future<void> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    await _client.postObject(
      '/admin/orders/$orderId/status',
      token: token,
      body: {'status': status},
    );
  }
}

import 'package:customer_app/src/core/network/api_client.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:image_picker/image_picker.dart';

class AdminApiService {
  AdminApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

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

  Future<List<Map<String, dynamic>>> getDrivers(String token) async {
    final response = await _client.getList('/admin/drivers', token: token);
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCustomers(String token) async {
    final response = await _client.getList('/admin/customers', token: token);
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
    required XFile image,
  }) async {
    final response = await _client.uploadFile(
      '/admin/products/upload-image',
      token: token,
      fieldName: 'file',
      bytes: await image.readAsBytes(),
      fileName: image.name.isEmpty ? 'product-image.jpg' : image.name,
    );
    final imageUrl = response['imageUrl'];
    if (imageUrl is String && imageUrl.isNotEmpty) {
      return imageUrl;
    }

    throw ApiException(
      path: '/admin/products/upload-image',
      statusCode: 502,
      serverMessage: 'Image upload did not return a usable URL.',
    );
  }

  Future<void> createProductWithImage({
    required String token,
    required String name,
    required String category,
    required double price,
    required bool isActive,
    required XFile image,
    String? description,
  }) async {
    try {
      await _client.uploadFile(
        '/admin/products/with-image',
        token: token,
        fieldName: 'file',
        bytes: await image.readAsBytes(),
        fileName: image.name.isEmpty ? 'product-image.jpg' : image.name,
        fields: {
          'name': name,
          'category': category,
          'price': price.toString(),
          'description': description ?? '',
          'isActive': isActive.toString(),
        },
      );
    } on ApiException catch (error) {
      if (error.statusCode != 404) {
        rethrow;
      }

      final imageUrl = await uploadProductImage(token: token, image: image);
      await createProduct(
        token: token,
        name: name,
        category: category,
        price: price,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      );
    }
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

  Future<void> deleteProduct({
    required String token,
    required String productId,
  }) async {
    await _client.delete(
      '/admin/products/$productId',
      token: token,
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

  Future<void> assignDriver({
    required String token,
    required String orderId,
    required String driverId,
  }) async {
    await _client.postObject(
      '/admin/orders/$orderId/assign-driver',
      token: token,
      body: {'driverId': driverId},
    );
  }
}

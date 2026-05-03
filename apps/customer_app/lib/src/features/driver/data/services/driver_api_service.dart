import 'package:customer_app/src/core/network/api_client.dart';

class DriverApiService {
  DriverApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getOrders(String token) async {
    final response = await _client.getList('/driver/orders', token: token);
    return response.cast<Map<String, dynamic>>();
  }

  Future<void> acceptOrder({
    required String token,
    required String orderId,
  }) async {
    await _client.postObject('/driver/orders/$orderId/accept', token: token);
  }

  Future<void> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
    double? lat,
    double? lng,
  }) async {
    await _client.postObject(
      '/driver/orders/$orderId/status',
      token: token,
      body: {
        'status': status,
        'lat': lat,
        'lng': lng,
      },
    );
  }
}

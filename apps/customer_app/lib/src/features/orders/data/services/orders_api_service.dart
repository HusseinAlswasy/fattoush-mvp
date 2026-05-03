import 'package:customer_app/src/core/network/api_client.dart';
import 'package:customer_app/src/features/cart/data/models/cart_item.dart';
import 'package:customer_app/src/features/checkout/data/models/checkout_draft.dart';
import 'package:customer_app/src/features/orders/data/models/customer_order.dart';

class OrdersApiService {
  OrdersApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<CustomerOrder> createOrder({
    required String token,
    required List<CartItem> items,
    required CheckoutDraft checkout,
    required String paymentMethod,
  }) async {
    final response = await _client.postObject(
      '/orders',
      token: token,
      body: {
        'items': items
            .map(
              (item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              },
            )
            .toList(growable: false),
        'addressText': checkout.addressText,
        'paymentMethod': paymentMethod,
        if (checkout.lat != null) 'lat': checkout.lat,
        if (checkout.lng != null) 'lng': checkout.lng,
      },
    );

    return CustomerOrder.fromJson(response);
  }

  Future<List<CustomerOrder>> getCustomerOrders(String token) async {
    final response = await _client.getList('/customer/orders', token: token);
    return response
        .whereType<Map<String, dynamic>>()
        .map(CustomerOrder.fromJson)
        .toList(growable: false);
  }
}

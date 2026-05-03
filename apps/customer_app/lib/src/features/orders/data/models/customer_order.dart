class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.total,
    required this.deliveryFee,
    required this.addressText,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double total;
  final double deliveryFee;
  final String addressText;
  final DateTime? createdAt;
  final List<CustomerOrderItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];

    return CustomerOrder(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      paymentStatus: json['paymentStatus'] as String? ?? 'UNPAID',
      total: double.tryParse(json['total'].toString()) ?? 0,
      deliveryFee: double.tryParse(json['deliveryFee'].toString()) ?? 0,
      addressText: json['addressText'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(CustomerOrderItem.fromJson)
          .toList(growable: false),
    );
  }
}

class CustomerOrderItem {
  const CustomerOrderItem({
    required this.id,
    required this.quantity,
    required this.lineTotal,
    required this.productName,
    this.productImageUrl,
  });

  final String id;
  final int quantity;
  final double lineTotal;
  final String productName;
  final String? productImageUrl;

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? const {};

    return CustomerOrderItem(
      id: json['id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      lineTotal: double.tryParse(json['lineTotal'].toString()) ?? 0,
      productName: product['name'] as String? ?? 'Product',
      productImageUrl: product['imageUrl'] as String?,
    );
  }
}

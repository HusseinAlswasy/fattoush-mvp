import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductNotificationsService {
  ProductNotificationsService({HomeApiService? homeApiService})
      : _homeApiService = homeApiService ?? HomeApiService();

  static const String _lastSeenKey = 'product_notifications_last_seen_at';

  final HomeApiService _homeApiService;

  Future<ProductNotificationSummary> fetchSummary() async {
    final products = (await _homeApiService.fetchHomeData()).products;
    final sortedProducts = [...products]..sort((a, b) {
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final lastSeenAt = await _lastSeenAt();
    final notifications = sortedProducts
        .where((product) {
          final createdAt = product.createdAt;
          if (createdAt == null) return false;
          return createdAt.isAfter(lastSeenAt);
        })
        .map(ProductNotification.new)
        .toList(growable: false);

    return ProductNotificationSummary(
      products: sortedProducts,
      notifications: notifications,
      unreadCount: notifications.length,
      lastSeenAt: lastSeenAt,
    );
  }

  Future<void> markAllSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        _lastSeenKey, DateTime.now().toUtc().toIso8601String());
  }

  Future<DateTime> _lastSeenAt() async {
    final preferences = await SharedPreferences.getInstance();
    final savedValue = preferences.getString(_lastSeenKey);
    if (savedValue == null) {
      final now = DateTime.now().toUtc();
      await preferences.setString(_lastSeenKey, now.toIso8601String());
      return now;
    }

    return DateTime.tryParse(savedValue)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}

class ProductNotificationSummary {
  const ProductNotificationSummary({
    required this.products,
    required this.notifications,
    required this.unreadCount,
    required this.lastSeenAt,
  });

  final List<Product> products;
  final List<ProductNotification> notifications;
  final int unreadCount;
  final DateTime lastSeenAt;
}

class ProductNotification {
  const ProductNotification(this.product);

  final Product product;

  String get title => 'New product added';

  String get message => '${product.name} is now available in Fattoush.';
}

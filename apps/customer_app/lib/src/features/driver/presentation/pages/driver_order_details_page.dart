import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/driver/data/services/driver_api_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverOrderDetailsPage extends StatelessWidget {
  const DriverOrderDetailsPage({
    super.key,
    required this.order,
  });

  static const String routeName = '/driver-order-details';

  final Map<String, dynamic> order;

  Future<void> _acceptOrder(BuildContext context) async {
    final session = AppScope.sessionOf(context);
    final driverApiService = DriverApiService();
    try {
      await driverApiService.acceptOrder(
        token: session.accessToken!,
        orderId: order['id'] as String,
      );
      if (!context.mounted) {
        return;
      }
      context.showAppNotice(
        title: 'Order received',
        message: 'The order is now with the driver.',
        type: AppNoticeType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Accept failed');
    }
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    final session = AppScope.sessionOf(context);
    final driverApiService = DriverApiService();
    try {
      await driverApiService.updateOrderStatus(
        token: session.accessToken!,
        orderId: order['id'] as String,
        status: status,
      );
      if (!context.mounted) {
        return;
      }
      context.showAppNotice(
        title: 'Status updated',
        message: 'Order status changed to ${status.replaceAll('_', ' ')}.',
        type: AppNoticeType.success,
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Status update failed');
    }
  }

  Future<void> _openMap(BuildContext context) async {
    final lat = order['lat'];
    final lng = order['lng'];
    if (lat == null || lng == null) {
      context.showAppNotice(
        title: 'No location',
        message: 'This order does not have a valid map location.',
        type: AppNoticeType.warning,
      );
      return;
    }

    final mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      final opened = await launchUrl(
        mapUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        context.showAppNotice(
          title: 'Map failed',
          message: 'Could not open the map app right now.',
          type: AppNoticeType.warning,
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      context.showAppNotice(
        title: 'Map failed',
        message: AppErrorPresenter.present(
          error,
          fallbackTitle: 'Map failed',
        ).message,
        type: AppNoticeType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = order['user'] as Map<String, dynamic>?;
    final items = order['items'] as List<dynamic>? ?? const [];
    final status = (order['status'] as String? ?? 'PENDING').toUpperCase();
    final displayStatus = status == 'CONFIRMED'
        ? 'RECEIVED'
        : status.replaceAll('_', ' ');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        surfaceTintColor: const Color(0xFFF4F6FB),
        title: const Text(
          'Driver Order Details',
          style: TextStyle(
            color: Color(0xFF4A4E61),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order['id']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A4E61),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Customer: ${user?['name'] ?? user?['email'] ?? 'Unknown'}'),
                  Text('Phone: ${user?['phone'] ?? 'Not provided'}'),
                  Text('Payment: ${order['paymentMethod'] ?? 'N/A'}'),
                  Text('Status: $displayStatus'),
                  Text('Total: AED ${order['total']}'),
                  const SizedBox(height: 10),
                  if ((order['addressText'] as String?)?.isNotEmpty == true)
                    Text('Address: ${order['addressText']}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A4E61),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...items.map((item) {
                    final product = item['product'] as Map<String, dynamic>?;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(product?['name']?.toString() ?? 'Product'),
                          ),
                          Text('x${item['quantity']}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openMap(context),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Go to location'),
              ),
            ),
            if (status == 'ASSIGNED' || status == 'PENDING') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _acceptOrder(context),
                  child: const Text('استلام الطلب'),
                ),
              ),
            ],
            if (status == 'CONFIRMED') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _updateStatus(context, 'ON_THE_WAY'),
                  child: const Text('تأكيد الاستلام والبدء في التوصيل'),
                ),
              ),
            ],
            if (status == 'ON_THE_WAY' || status == 'PICKED_UP') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _updateStatus(context, 'DELIVERED'),
                  child: const Text('تم التوصيل'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

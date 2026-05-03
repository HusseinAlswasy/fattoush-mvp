import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:customer_app/src/features/driver/data/services/driver_api_service.dart';
import 'package:customer_app/src/features/driver/presentation/pages/driver_order_details_page.dart';
import 'package:flutter/material.dart';

class DriverOrdersPage extends StatefulWidget {
  const DriverOrdersPage({super.key});

  static const String routeName = '/driver-orders';

  @override
  State<DriverOrdersPage> createState() => _DriverOrdersPageState();
}

class _DriverOrdersPageState extends State<DriverOrdersPage> {
  final DriverApiService _driverApiService = DriverApiService();
  late Future<List<Map<String, dynamic>>> _future;
  bool _didBootstrap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) {
      return;
    }
    _didBootstrap = true;
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final session = AppScope.sessionOf(context);
    return _driverApiService.getOrders(session.accessToken!);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        surfaceTintColor: const Color(0xFFF4F6FB),
        title: const Text(
          'Driver Orders',
          style: TextStyle(
            color: Color(0xFF4A4E61),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              session.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AuthPage.routeName,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppErrorPresenter.present(
                          snapshot.error ?? Exception('Unknown error'),
                          fallbackTitle: 'Driver orders failed',
                        ).message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final orders = snapshot.data ?? const <Map<String, dynamic>>[];
            final activeOrders = orders.where((order) {
              final status = (order['status'] as String? ?? '').toUpperCase();
              return status != 'DELIVERED' && status != 'CANCELLED';
            }).length;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEE7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            color: Color(0xFFFF8B6A),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'طلبات السائق',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4A4E61),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'عندك $activeOrders طلب نشط من أصل ${orders.length}',
                                style: const TextStyle(
                                  color: Color(0xFF98A0B4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text(
                        'لا يوجد طلبات للسائق الآن',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A4E61),
                        ),
                      ),
                    )
                  else
                    ...orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DriverOrderCard(
                          order: order,
                          onTap: () async {
                            final changed = await Navigator.of(context).pushNamed(
                              DriverOrderDetailsPage.routeName,
                              arguments: order,
                            );
                            if (changed == true) {
                              await _refresh();
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DriverOrderCard extends StatelessWidget {
  const _DriverOrderCard({
    required this.order,
    required this.onTap,
  });

  final Map<String, dynamic> order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final user = order['user'] as Map<String, dynamic>?;
    final items = order['items'] as List<dynamic>? ?? const [];
    final status = (order['status'] as String? ?? 'PENDING').replaceAll('_', ' ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order['id']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A4E61),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Customer: ${user?['name'] ?? user?['email'] ?? 'Unknown'}'),
                  Text('Items: ${items.length}'),
                  Text('Status: $status'),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/admin/data/services/admin_api_service.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  static const String routeName = '/admin-orders';

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final AdminApiService _adminApiService = AdminApiService();
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
    return _adminApiService.getOrders(session.accessToken!);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final session = AppScope.sessionOf(context);
    try {
      await _adminApiService.updateOrderStatus(
        token: session.accessToken!,
        orderId: orderId,
        status: status,
      );
      if (!mounted) {
        return;
      }
      await _refresh();
      if (!mounted) {
        return;
      }
      context.showAppNotice(
        title: 'Order updated',
        message: 'Order status changed to $status.',
        type: AppNoticeType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Order update failed');
    }
  }

  Future<void> _assignDriver({
    required String orderId,
    required String currentStatus,
  }) async {
    final session = AppScope.sessionOf(context);

    try {
      final drivers = await _adminApiService.getDrivers(session.accessToken!);
      if (!mounted) {
        return;
      }

      if (drivers.isEmpty) {
        context.showAppNotice(
          title: 'No drivers',
          message: 'Add a driver account first, then try assigning again.',
          type: AppNoticeType.warning,
        );
        return;
      }

      final selectedDriver = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _AssignDriverSheet(drivers: drivers),
      );

      if (selectedDriver == null || !mounted) {
        return;
      }

      await _adminApiService.assignDriver(
        token: session.accessToken!,
        orderId: orderId,
        driverId: selectedDriver['id'] as String,
      );

      if (currentStatus != 'ASSIGNED') {
        await _adminApiService.updateOrderStatus(
          token: session.accessToken!,
          orderId: orderId,
          status: 'ASSIGNED',
        );
      }

      if (!mounted) {
        return;
      }

      await _refresh();
      if (!mounted) {
        return;
      }

      final label = selectedDriver['name'] ?? selectedDriver['email'] ?? 'driver';
      context.showAppNotice(
        title: 'Driver assigned',
        message: '$label has been assigned to this order.',
        type: AppNoticeType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Driver assignment failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        surfaceTintColor: const Color(0xFFF4F6FB),
        title: const Text(
          'Admin Orders',
          style: TextStyle(
            color: Color(0xFF4A4E61),
            fontWeight: FontWeight.w800,
          ),
        ),
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
                          fallbackTitle: 'Orders failed',
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
            if (orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 140),
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 68,
                      color: Color(0xFFB5BDD0),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No orders yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A4E61),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderAdminCard(
                    order: order,
                    onChangeStatus: (status) => _updateOrderStatus(
                      orderId: order['id'] as String,
                      status: status,
                    ),
                    onAssignDriver: () => _assignDriver(
                      orderId: order['id'] as String,
                      currentStatus: order['status'] as String? ?? 'PENDING',
                    ),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemCount: orders.length,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderAdminCard extends StatelessWidget {
  const _OrderAdminCard({
    required this.order,
    required this.onChangeStatus,
    required this.onAssignDriver,
  });

  final Map<String, dynamic> order;
  final Future<void> Function(String status) onChangeStatus;
  final Future<void> Function() onAssignDriver;

  static const List<String> _statuses = [
    'PENDING',
    'CONFIRMED',
    'ASSIGNED',
    'PICKED_UP',
    'ON_THE_WAY',
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  Widget build(BuildContext context) {
    final user = order['user'] as Map<String, dynamic>?;
    final assignedDriver = order['assignedDriver'] as Map<String, dynamic>?;
    final items = order['items'] as List<dynamic>? ?? const [];
    final status = order['status'] as String? ?? 'PENDING';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order['id']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4E61),
                  ),
                ),
              ),
              _Tag(
                label: status.replaceAll('_', ' '),
                color: _statusColor(status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Customer: ${user?['name'] ?? user?['email'] ?? 'Unknown'}'),
          Text(
            'Driver: ${assignedDriver?['name'] ?? assignedDriver?['email'] ?? 'Not assigned'}',
          ),
          Text('Items: ${items.length}'),
          Text('Total: AED ${order['total']}'),
          if ((order['addressText'] as String?)?.isNotEmpty == true)
            Text(
              'Address: ${order['addressText']}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statuses.map((candidate) {
                final selected = candidate == status;
                final isAssignButton = candidate == 'ASSIGNED';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: isAssignButton
                        ? onAssignDriver
                        : selected
                            ? null
                            : () => onChangeStatus(candidate),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _statusColor(candidate),
                      side: BorderSide(
                        color: _statusColor(candidate).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      isAssignButton ? 'ASSIGN DRIVER' : candidate.replaceAll('_', ' '),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DELIVERED':
        return const Color(0xFF3BAA64);
      case 'ON_THE_WAY':
      case 'PICKED_UP':
        return const Color(0xFFFF8B6A);
      case 'CONFIRMED':
      case 'ASSIGNED':
        return const Color(0xFF6B7BFF);
      case 'CANCELLED':
        return const Color(0xFFD94C4C);
      default:
        return const Color(0xFF9CA3B7);
    }
  }
}

class _AssignDriverSheet extends StatelessWidget {
  const _AssignDriverSheet({
    required this.drivers,
  });

  final List<Map<String, dynamic>> drivers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a driver',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A4E61),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: drivers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  final title =
                      driver['name'] as String? ??
                      driver['email'] as String? ??
                      driver['phone'] as String? ??
                      'Driver';
                  final subtitle =
                      driver['phone'] as String? ??
                      driver['email'] as String? ??
                      'Available driver';

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).pop(driver),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E9F3)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFFFEEE8),
                            foregroundColor: Color(0xFFFF8B6A),
                            child: Icon(Icons.delivery_dining_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4A4E61),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Color(0xFF8C94A8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFB1B8C9),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

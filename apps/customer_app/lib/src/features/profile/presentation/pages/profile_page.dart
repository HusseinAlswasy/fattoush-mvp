import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:customer_app/src/features/orders/data/models/customer_order.dart';
import 'package:customer_app/src/features/orders/data/services/orders_api_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final OrdersApiService _ordersApiService = OrdersApiService();
  Future<List<CustomerOrder>>? _ordersFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureOrdersLoaded();
  }

  void _ensureOrdersLoaded() {
    final session = AppScope.sessionOf(context);
    if (!session.isAuthenticated || !session.isCustomer || session.accessToken == null) {
      _ordersFuture = null;
      return;
    }

    _ordersFuture ??= _ordersApiService.getCustomerOrders(session.accessToken!);
  }

  Future<void> _refreshOrders() async {
    final session = AppScope.sessionOf(context);
    if (!session.isAuthenticated || !session.isCustomer || session.accessToken == null) {
      return;
    }

    setState(() {
      _ordersFuture = _ordersApiService.getCustomerOrders(session.accessToken!);
    });

    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);
    final isSmallPhone = context.isSmallPhone;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppBottomNavTab.profile,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            if (!session.isAuthenticated || session.isGuest) {
              return _GuestProfileState(isSmallPhone: isSmallPhone);
            }

            if (session.isAdmin) {
              return _AdminProfileState(
                isSmallPhone: isSmallPhone,
                name: session.user?.name ?? 'Admin',
                identifier: session.user?.email ?? session.user?.phone ?? '',
                onOpenDashboard: () {
                  Navigator.of(context).pushNamed(AdminDashboardPage.routeName);
                },
                onLogout: () {
                  session.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AuthPage.routeName,
                    (route) => false,
                  );
                },
              );
            }

            _ensureOrdersLoaded();

            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                children: [
                  _ProfileHeader(
                    title: 'Profile',
                    subtitle: session.user?.name ?? 'Customer',
                    trailing: IconButton(
                      onPressed: () {
                        session.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AuthPage.routeName,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                    isSmallPhone: isSmallPhone,
                  ),
                  const SizedBox(height: 18),
                  _ProfileIdentityCard(
                    title: session.user?.name ?? 'Customer account',
                    subtitle: session.user?.email ?? session.user?.phone ?? '',
                    note: 'Orders placed from checkout are saved in your account.',
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A4E61),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<CustomerOrder>>(
                    future: _ordersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return _OrdersErrorCard(
                          onRetry: _refreshOrders,
                          error: snapshot.error!,
                        );
                      }

                      final orders = snapshot.data ?? const <CustomerOrder>[];
                      if (orders.isEmpty) {
                        return const _NoOrdersCard();
                      }

                      return Column(
                        children: orders
                            .map(
                              (order) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CustomerOrderCard(order: order),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isSmallPhone,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isSmallPhone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallPhone ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A4E61),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF98A0B4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.title,
    required this.subtitle,
    required this.note,
  });

  final String title;
  final String subtitle;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFFFEEE7),
            child: Icon(
              Icons.person_rounded,
              size: 38,
              color: Color(0xFFFF8B6A),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A4E61),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7E859A),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            note,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF98A0B4),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestProfileState extends StatelessWidget {
  const _GuestProfileState({required this.isSmallPhone});

  final bool isSmallPhone;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      children: [
        _ProfileHeader(
          title: 'Profile',
          subtitle: 'Guest mode',
          trailing: const SizedBox.shrink(),
          isSmallPhone: isSmallPhone,
        ),
        const SizedBox(height: 18),
        const _ProfileIdentityCard(
          title: 'Guest User',
          subtitle: '',
          note:
              'Browse freely as a guest. Login or create an account when you are ready to place and track orders.',
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AuthPage.routeName);
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF8B6A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'LOGIN OR CREATE ACCOUNT',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _AdminProfileState extends StatelessWidget {
  const _AdminProfileState({
    required this.isSmallPhone,
    required this.name,
    required this.identifier,
    required this.onOpenDashboard,
    required this.onLogout,
  });

  final bool isSmallPhone;
  final String name;
  final String identifier;
  final VoidCallback onOpenDashboard;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      children: [
        _ProfileHeader(
          title: 'Profile',
          subtitle: 'Administrator',
          trailing: IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          isSmallPhone: isSmallPhone,
        ),
        const SizedBox(height: 18),
        _ProfileIdentityCard(
          title: name,
          subtitle: identifier,
          note: 'This account can manage products, orders, and reports.',
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onOpenDashboard,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF5C6697),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'OPEN ADMIN DASHBOARD',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _OrdersErrorCard extends StatelessWidget {
  const _OrdersErrorCard({
    required this.onRetry,
    required this.error,
  });

  final Future<void> Function() onRetry;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final presentation = AppErrorPresenter.present(
      error,
      fallbackTitle: 'Orders unavailable',
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Could not load orders right now.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4E61),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            presentation.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF98A0B4),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NoOrdersCard extends StatelessWidget {
  const _NoOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 36,
            color: Color(0xFFFF8B6A),
          ),
          SizedBox(height: 12),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A4E61),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your completed checkout orders will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF98A0B4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerOrderCard extends StatelessWidget {
  const _CustomerOrderCard({required this.order});

  final CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${_shortOrderId(order.id)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4E61),
                  ),
                ),
              ),
              _StatusChip(label: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.addressText,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: Color(0xFF8D95AA),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(label: '${order.itemCount} items'),
              _MetaPill(label: order.paymentMethod),
              _MetaPill(label: order.paymentStatus),
              _MetaPill(label: 'AED ${order.total.toStringAsFixed(2)}'),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...order.items.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF596078),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(color: Color(0xFF98A0B4)),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  String _shortOrderId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return value.substring(0, 8).toUpperCase();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'DELIVERED' => const Color(0xFF3BAA64),
      'ON_THE_WAY' => const Color(0xFFFF8B6A),
      'ASSIGNED' => const Color(0xFF6B7BFF),
      _ => const Color(0xFF8D95AA),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6A7187),
        ),
      ),
    );
  }
}

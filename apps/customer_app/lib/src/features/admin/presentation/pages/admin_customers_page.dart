import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/localization/app_text.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_back_home_button.dart';
import 'package:customer_app/src/features/admin/data/services/admin_api_service.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:customer_app/src/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:flutter/material.dart';

class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  static const routeName = '/admin-customers';

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  final AdminApiService _adminApiService = AdminApiService();
  late Future<List<Map<String, dynamic>>> _future;
  bool _didBootstrap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) return;
    _didBootstrap = true;
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final session = AppScope.sessionOf(context);
    return _adminApiService.getCustomers(session.accessToken!);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      bottomNavigationBar: const AdminBottomNav(
        currentTab: AdminBottomNavTab.customers,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: const Color(0xFFF6F7FB),
        leading: const AppBackHomeButton(
          homeRouteName: AdminDashboardPage.routeName,
        ),
        title: Text(
          context.tr('Customers', 'العملاء'),
          style: const TextStyle(
            color: Color(0xFF111827),
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
                          fallbackTitle: context.tr(
                              'Customers failed', 'فشل تحميل العملاء'),
                        ).message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _refresh,
                        child: Text(context.tr('Retry', 'إعادة المحاولة')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final customers = snapshot.data ?? const <Map<String, dynamic>>[];

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F8A39), Color(0xFF2EA54A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.group_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('Customer base', 'قاعدة العملاء'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${customers.length}',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (customers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.group_off_outlined,
                            size: 42,
                            color: Color(0xFFB8BFCC),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr(
                              'No customers yet',
                              'لا يوجد عملاء حتى الآن',
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A4E61),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...customers.map(
                      (customer) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CustomerCard(customer: customer),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Map<String, dynamic> customer;

  @override
  Widget build(BuildContext context) {
    final count =
        (customer['_count'] as Map<String, dynamic>?)?['customerOrders'] ?? 0;
    final name = customer['name'] as String? ??
        customer['email'] as String? ??
        customer['phone'] as String? ??
        context.tr('Customer', 'عميل');
    final subtitle = customer['email'] as String? ??
        customer['phone'] as String? ??
        context.tr('No contact info', 'لا توجد بيانات تواصل');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF1FAF3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF1F8A39),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F8A39),
                ),
              ),
              Text(
                context.tr('Orders', 'طلبات'),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

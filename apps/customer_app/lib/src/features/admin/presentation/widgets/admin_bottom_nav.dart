import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_customers_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_products_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:flutter/material.dart';

enum AdminBottomNavTab {
  home,
  orders,
  products,
  customers,
  settings,
}

class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({
    super.key,
    required this.currentTab,
  });

  final AdminBottomNavTab currentTab;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppScope.preferencesOf(context).isArabic;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AdminNavItem(
              icon: Icons.home_rounded,
              label: isArabic ? 'الرئيسية' : 'Home',
              selected: currentTab == AdminBottomNavTab.home,
              onTap: () => _navigateTo(context, AdminBottomNavTab.home),
            ),
            _AdminNavItem(
              icon: Icons.receipt_long_rounded,
              label: isArabic ? 'الطلبات' : 'Orders',
              selected: currentTab == AdminBottomNavTab.orders,
              onTap: () => _navigateTo(context, AdminBottomNavTab.orders),
            ),
            _AdminNavItem(
              icon: Icons.inventory_2_rounded,
              label: isArabic ? 'المنتجات' : 'Products',
              selected: currentTab == AdminBottomNavTab.products,
              onTap: () => _navigateTo(context, AdminBottomNavTab.products),
            ),
            _AdminNavItem(
              icon: Icons.group_outlined,
              label: isArabic ? 'العملاء' : 'Customers',
              selected: currentTab == AdminBottomNavTab.customers,
              onTap: () => _navigateTo(context, AdminBottomNavTab.customers),
            ),
            _AdminNavItem(
              icon: Icons.settings_rounded,
              label: isArabic ? 'الإعدادات' : 'Settings',
              selected: currentTab == AdminBottomNavTab.settings,
              onTap: () => _navigateTo(context, AdminBottomNavTab.settings),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, AdminBottomNavTab tab) {
    if (tab == currentTab) return;

    final route = switch (tab) {
      AdminBottomNavTab.home => AdminDashboardPage.routeName,
      AdminBottomNavTab.orders => AdminOrdersPage.routeName,
      AdminBottomNavTab.products => AdminProductsPage.routeName,
      AdminBottomNavTab.customers => AdminCustomersPage.routeName,
      AdminBottomNavTab.settings => AdminSettingsPage.routeName,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1E7B34) : const Color(0xFF7A8496);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

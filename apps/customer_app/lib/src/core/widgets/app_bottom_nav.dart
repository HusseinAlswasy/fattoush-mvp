import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/categories_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/home_page.dart';
import 'package:customer_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

enum AppBottomNavTab {
  home,
  restaurants,
  orders,
  profile,
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentTab,
  });

  final AppBottomNavTab currentTab;

  @override
  Widget build(BuildContext context) {
    final compact = context.isSmallPhone;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, compact ? 10 : 14),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              compact: compact,
              selected: currentTab == AppBottomNavTab.home,
              onTap: () => _navigateTo(context, AppBottomNavTab.home),
            ),
            _NavItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Restaurants',
              compact: compact,
              selected: currentTab == AppBottomNavTab.restaurants,
              onTap: () => _navigateTo(context, AppBottomNavTab.restaurants),
            ),
            _NavItem(
              icon: Icons.shopping_bag_rounded,
              label: 'Order',
              compact: compact,
              selected: currentTab == AppBottomNavTab.orders,
              onTap: () => _navigateTo(context, AppBottomNavTab.orders),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              compact: compact,
              selected: currentTab == AppBottomNavTab.profile,
              onTap: () => _navigateTo(context, AppBottomNavTab.profile),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, AppBottomNavTab tab) {
    if (tab == currentTab) {
      return;
    }

    final routeName = switch (tab) {
      AppBottomNavTab.home => HomePage.routeName,
      AppBottomNavTab.restaurants => CategoriesPage.routeName,
      AppBottomNavTab.orders => CartPage.routeName,
      AppBottomNavTab.profile => ProfilePage.routeName,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFF8B6A) : const Color(0xFFB8BECC);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: compact ? 20 : 22),
              SizedBox(height: compact ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 9.5 : 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/categories_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/home_page.dart';
import 'package:customer_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

enum AppBottomNavTab {
  home,
  restaurants,
  cart,
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
        margin: EdgeInsets.fromLTRB(20, 0, 20, compact ? 10 : 14),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
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
              icon: Icons.restaurant_rounded,
              label: 'Restaurants',
              compact: compact,
              selected: currentTab == AppBottomNavTab.restaurants,
              onTap: () => _navigateTo(context, AppBottomNavTab.restaurants),
            ),
            _NavItem(
              icon: Icons.shopping_cart_rounded,
              label: 'Cart',
              compact: compact,
              prominent: true,
              selected: currentTab == AppBottomNavTab.cart,
              onTap: () => _navigateTo(context, AppBottomNavTab.cart),
            ),
            _NavItem(
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
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
      AppBottomNavTab.cart => CartPage.routeName,
      AppBottomNavTab.orders => ProfilePage.routeName,
      AppBottomNavTab.profile => ProfilePage.routeName,
    };

    Navigator.of(context).pushReplacementNamed(routeName);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.compact,
    required this.selected,
    required this.onTap,
    this.prominent = false,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFF5A52) : const Color(0xFF7C8294);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: prominent ? (compact ? 50 : 58) : 34,
                height: prominent ? (compact ? 50 : 58) : 34,
                decoration: BoxDecoration(
                  color:
                      prominent ? const Color(0xFFFF5A52) : Colors.transparent,
                  borderRadius: BorderRadius.circular(prominent ? 18 : 12),
                ),
                child: Icon(
                  icon,
                  color: prominent ? Colors.white : color,
                  size: prominent ? (compact ? 25 : 29) : (compact ? 22 : 24),
                ),
              ),
              SizedBox(height: compact ? 2 : 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 9.5 : 12,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: prominent
                        ? (selected
                            ? const Color(0xFF9D362F)
                            : const Color(0xFF7C8294))
                        : color,
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

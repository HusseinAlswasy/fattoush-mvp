import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:customer_app/src/features/cart/data/models/cart_item.dart';
import 'package:customer_app/src/features/checkout/presentation/pages/delivery_address_page.dart';
import 'package:customer_app/src/features/driver/presentation/pages/driver_details_page.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static const String routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);
    final isSmallPhone = context.isSmallPhone;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppBottomNavTab.orders,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            if (cart.items.isEmpty) {
              return const _EmptyCartState();
            }

            return ListView(
              padding: EdgeInsets.fromLTRB(14, 10, 14, isSmallPhone ? 18 : 24),
              children: [
                const _TopHeader(),
                SizedBox(height: isSmallPhone ? 14 : 18),
                Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: isSmallPhone ? 23 : 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4E61),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _RestaurantHeader(
                        onTap: () => Navigator.of(context).pushNamed(
                          DriverDetailsPage.routeName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        cart.items.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: index == cart.items.length - 1 ? 0 : 10,
                          ),
                          child: _CartItemCard(item: cart.items[index]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(label: 'Order total', value: cart.subtotal),
                      const SizedBox(height: 6),
                      _SummaryRow(label: 'Delivery', value: cart.deliveryFee),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Color(0xFFE6E9F0)),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: cart.total,
                        emphasize: true,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            final session = AppScope.sessionOf(context);
                            if (!session.isAuthenticated || session.isGuest) {
                              context.showAppNotice(
                                title: 'Login required',
                                message:
                                    'Please login or create a customer account before checkout.',
                                type: AppNoticeType.info,
                              );
                              Navigator.of(context).pushNamed(AuthPage.routeName);
                              return;
                            }
                            Navigator.of(context).pushNamed(
                              DeliveryAddressPage.routeName,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8265),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'PROCEED TO CHECKOUT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _RestaurantCollapsedCard(
                  onTap: () => Navigator.of(context).pushNamed(
                    DriverDetailsPage.routeName,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Foodster',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5C6697),
            ),
          ),
        ),
        Icon(
          Icons.location_on_rounded,
          color: Color(0xFFFF8666),
          size: 20,
        ),
        SizedBox(width: 4),
        Text(
          'Cairo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF585D72),
          ),
        ),
        SizedBox(width: 10),
        Icon(Icons.search_rounded, color: Color(0xFF8890A8)),
      ],
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEFF4F8),
            child: Icon(
              Icons.storefront_rounded,
              size: 18,
              color: Color(0xFFFF8265),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mario Cheff',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF505466),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '\$46 / 2 items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF7E66),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF8C92A6)),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);
    final isSmallPhone = context.isSmallPhone;

    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 9 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: isSmallPhone ? 58 : 66,
                  height: isSmallPhone ? 58 : 66,
                  color: const Color(0xFFF1E6D8),
                  child: item.product.imageUrl == null || item.product.imageUrl!.isEmpty
                      ? const Icon(Icons.image_not_supported_outlined)
                      : Image.network(
                          item.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image_outlined),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallPhone ? 14 : 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4C5164),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.product.description?.isNotEmpty == true
                          ? item.product.description!
                          : 'fresh meal with selected ingredients',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallPhone ? 10.5 : 11,
                        height: 1.3,
                        color: const Color(0xFFAFB4C2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallPhone ? 8 : 10),
          Row(
            children: [
              Text(
                '\$${item.lineTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isSmallPhone ? 14 : 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF7F66),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ 220 g',
                style: TextStyle(
                  fontSize: isSmallPhone ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9CA3B7),
                ),
              ),
              const Spacer(),
              _QtyButton(
                icon: Icons.remove,
                compact: isSmallPhone,
                onPressed: () => cart.decrement(item.product),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 10 : 12),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontSize: isSmallPhone ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF596078),
                  ),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                compact: isSmallPhone,
                onPressed: () => cart.add(item.product),
              ),
              SizedBox(width: isSmallPhone ? 4 : 8),
              InkWell(
                onTap: () => cart.remove(item.product),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: isSmallPhone ? 18 : 20,
                    color: const Color(0xFFB8BDCB),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.compact,
    required this.onPressed,
  });

  final IconData icon;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: compact ? 28 : 32,
        height: compact ? 28 : 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: compact ? 16 : 18,
          color: const Color(0xFF858CA3),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: emphasize ? 17 : 14,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
      color: const Color(0xFF676E83),
    );
    final valueStyle = TextStyle(
      fontSize: emphasize ? 20 : 15,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
      color: emphasize ? const Color(0xFFFF7F66) : const Color(0xFF7D8396),
    );

    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        Text('\$${value.toStringAsFixed(0)}', style: valueStyle),
      ],
    );
  }
}

class _RestaurantCollapsedCard extends StatelessWidget {
  const _RestaurantCollapsedCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFFFF1E4),
              child: Icon(
                Icons.fastfood_rounded,
                size: 18,
                color: Color(0xFFFF8265),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "McDonald's",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4E5367),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '\$75 / 2 items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF7E66),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8C92A6)),
          ],
        ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F3FB),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 116,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.22,
                    child: Container(
                      width: 68,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFB364),
                            Color(0xFFFF8B4C),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 54,
                    child: Container(
                      width: 34,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your order is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5C6277),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose one restaurant and add dishes to your order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF9EA5B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

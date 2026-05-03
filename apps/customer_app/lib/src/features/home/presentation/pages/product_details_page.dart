import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  static const String routeName = '/product-details';

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity += 1;
    });
  }

  void _decrement() {
    if (_quantity == 1) {
      return;
    }

    setState(() {
      _quantity -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);
    final product = widget.product;
    final totalPrice = product.price * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 360,
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: const Color(0xFFF6EDE7),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: product.imageUrl == null || product.imageUrl!.isEmpty
                                ? const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 60,
                                      color: Color(0xFF8A7151),
                                    ),
                                  )
                                : Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 60,
                                        color: Color(0xFF8A7151),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 26,
                          left: 24,
                          child: _CircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: index == 0
                                      ? const Color(0xFFFF8B6A)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE5E8F0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -22),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF44485A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description?.isNotEmpty == true
                                  ? product.description!
                                  : 'Fresh sauce, premium ingredients, and a perfect meal for your day.',
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.45,
                                color: Color(0xFF9AA0B4),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Color(0xFFFF8B6A),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add ingredients',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5B6075),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  'AED ${totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64C27C),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AED ${(product.price * (_quantity + 1)).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC3C7D5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '/ 550 g',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF7A8094),
                                  ),
                                ),
                                const Spacer(),
                                _CircleButton(
                                  icon: Icons.remove,
                                  filled: true,
                                  onPressed: _decrement,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF5B6075),
                                    ),
                                  ),
                                ),
                                _CircleButton(
                                  icon: Icons.add,
                                  filled: true,
                                  onPressed: _increment,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      cart.addMany(product, _quantity);
                      context.showAppNotice(
                        title: 'Order updated',
                        message:
                            '$_quantity x ${product.name} added to your cart.',
                        type: AppNoticeType.success,
                        actionLabel: 'View order',
                        onAction: () {
                          Navigator.of(context).pushNamed(CartPage.routeName);
                        },
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8265),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'ADD TO ORDER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFF1F3F8) : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6A7085),
          size: 20,
        ),
      ),
    );
  }
}

import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

class OrderCompletedPage extends StatelessWidget {
  const OrderCompletedPage({
    super.key,
    this.orderId,
  });

  static const String routeName = '/order-completed';

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = context.isSmallPhone;
    final compactHeight = context.isCompactHeight;
    final artWidth = context.responsive(small: 180, medium: 230, large: 260);
    final artHeight = context.responsive(small: 168, medium: 210, large: 228);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 60,
            ),
            child: Column(
              children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFFA0A7BA),
                    ),
                  ),
                ),
              ),
              SizedBox(height: compactHeight ? 20 : 42),
              Container(
                width: artWidth,
                height: artHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FB),
                  borderRadius: BorderRadius.circular(isSmallPhone ? 30 : 40),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 44,
                      child: Container(
                        width: 152,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 34,
                      bottom: 54,
                      child: Transform.rotate(
                        angle: -0.22,
                        child: const Icon(
                          Icons.location_on_rounded,
                          size: 28,
                          color: Color(0xFFFF8B6A),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 38,
                      bottom: 58,
                      child: Transform.rotate(
                        angle: 0.22,
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          size: 34,
                          color: Color(0xFFFF8B6A),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 44,
                      child: Column(
                        children: [
                          Container(
                            width: 22,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB7A4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Container(
                            width: 64,
                            height: 38,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8B6A),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallPhone ? 20 : 26),
              Text(
                'Order is completed!',
                style: TextStyle(
                  fontSize: isSmallPhone ? 24 : 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5A6076),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                orderId == null
                    ? 'Keep track of the status in the profile with My Orders'
                    : 'Your order number is ${_shortOrderId(orderId!)}. Track it from My Orders.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFFA0A7BA),
                ),
              ),
              SizedBox(height: compactHeight ? 28 : 46),
              SizedBox(
                width: isSmallPhone ? double.infinity : 176,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      ProfilePage.routeName,
                      (route) => false,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8B6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'CHECK ORDER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            ),
          ),
        ),
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

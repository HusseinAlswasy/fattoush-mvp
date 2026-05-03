import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:customer_app/src/features/checkout/data/models/checkout_draft.dart';
import 'package:customer_app/src/features/checkout/presentation/pages/order_completed_page.dart';
import 'package:customer_app/src/features/orders/data/services/orders_api_service.dart';
import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({
    super.key,
    required this.checkout,
  });

  static const String routeName = '/payment-method';

  final CheckoutDraft checkout;

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final OrdersApiService _ordersApiService = OrdersApiService();
  _PaymentOption _selectedOption = _PaymentOption.cash;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            _PaymentTopBar(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.credit_card_outlined,
                          color: Color(0xFFFF8B6A),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Payment method',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A4E61),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.checkout.addressText,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF98A0B4),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('PAY BY CARD'),
                    const SizedBox(height: 10),
                    _CardOptionTile(
                      selected: _selectedOption == _PaymentOption.card1,
                      brandLabel: 'Mastercard',
                      lastDigits: '8834',
                      expiry: 'Expires 12/2025',
                      brandColor: const Color(0xFFFFB56A),
                      onTap: () => setState(() {
                        _selectedOption = _PaymentOption.card1;
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Add new card',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF8B6A),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            context.showAppNotice(
                              title: 'Payment gateway next',
                              message:
                                  'Saved cards are UI-ready now. The real gateway tokenization is the next backend step.',
                              type: AppNoticeType.info,
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFFFF8B6A),
                          ),
                        ),
                      ],
                    ),
                    _CardOptionTile(
                      selected: _selectedOption == _PaymentOption.card2,
                      brandLabel: 'VISA',
                      lastDigits: '0064',
                      expiry: 'Expires 10/2027',
                      brandColor: const Color(0xFF2C69FF),
                      onTap: () => setState(() {
                        _selectedOption = _PaymentOption.card2;
                      }),
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('PAY BY CASH'),
                    const SizedBox(height: 10),
                    _CashOptionTile(
                      selected: _selectedOption == _PaymentOption.cash,
                      onTap: () => setState(() {
                        _selectedOption = _PaymentOption.cash;
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submitOrder,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF7A998),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    final session = AppScope.sessionOf(context);
    final cart = AppScope.cartOf(context);

    if (!session.isAuthenticated || session.accessToken == null) {
      context.showAppNotice(
        title: 'Login required',
        message: 'Please login as a customer before placing an order.',
        type: AppNoticeType.warning,
      );
      Navigator.of(context).pushNamed(AuthPage.routeName);
      return;
    }

    if (cart.items.isEmpty) {
      context.showAppNotice(
        title: 'Cart is empty',
        message: 'Add at least one product before placing an order.',
        type: AppNoticeType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final order = await _ordersApiService.createOrder(
        token: session.accessToken!,
        items: cart.items,
        checkout: widget.checkout,
        paymentMethod: _selectedOption == _PaymentOption.cash ? 'COD' : 'CARD',
      );

      cart.clear();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        OrderCompletedPage.routeName,
        (route) => false,
        arguments: order.id,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Order failed');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

enum _PaymentOption {
  card1,
  card2,
  cash,
}

class _PaymentTopBar extends StatelessWidget {
  const _PaymentTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF9BA2B6),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Payment method',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6A7187),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFFA4ABBE),
      ),
    );
  }
}

class _CardOptionTile extends StatelessWidget {
  const _CardOptionTile({
    required this.selected,
    required this.brandLabel,
    required this.lastDigits,
    required this.expiry,
    required this.brandColor,
    required this.onTap,
  });

  final bool selected;
  final String brandLabel;
  final String lastDigits;
  final String expiry;
  final Color brandColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 28,
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                brandLabel,
                style: TextStyle(
                  color: brandColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '**** **** **** $lastDigits',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5E657B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    expiry,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB2B8C9),
                    ),
                  ),
                ],
              ),
            ),
            _SelectionDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _CashOptionTile extends StatelessWidget {
  const _CashOptionTile({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7EA),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.payments_rounded,
                color: Color(0xFF49A96C),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash on delivery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5E657B),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pay when the order reaches your door',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB2B8C9),
                    ),
                  ),
                ],
              ),
            ),
            _SelectionDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFFF8B6A) : const Color(0xFFE4E8F0),
          width: 2,
        ),
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(
                radius: 5,
                backgroundColor: Color(0xFFFF8B6A),
              ),
            )
          : null,
    );
  }
}

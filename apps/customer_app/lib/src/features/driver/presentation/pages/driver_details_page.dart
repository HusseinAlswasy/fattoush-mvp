import 'package:flutter/material.dart';

class DriverDetailsPage extends StatelessWidget {
  const DriverDetailsPage({super.key});

  static const String routeName = '/driver-details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 168,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDDE7F1), Color(0xFFF5F8FC)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delivery_dining_rounded,
                        size: 72,
                        color: Color(0xFF9AA8BE),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: _TopCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Positioned(
                    right: 14,
                    top: 14,
                    child: _TopCircleButton(icon: Icons.notifications_none_rounded),
                  ),
                  const Positioned(
                    left: 18,
                    bottom: 18,
                    child: Text(
                      'Mario Cheff',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF566177),
                      ),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'About',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4D5266),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFFB0B6C5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mario Cheff is a friendly delivery captain who serves Italian and Mediterranean orders with care. Fast pickup, smooth communication, and reliable delivery all week.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF7B8397),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _InfoRow(
                        icon: Icons.local_offer_outlined,
                        iconColor: Color(0xFF65C987),
                        title: 'Free delivery from \$100 in order',
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        icon: Icons.delivery_dining_outlined,
                        iconColor: Color(0xFF8B98B0),
                        title: 'Delivery 09:00 AM - 11:00 PM, 7 days / week',
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        icon: Icons.phone_outlined,
                        iconColor: Color(0xFF8B98B0),
                        title: '011 200 11 00',
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        icon: Icons.calendar_month_outlined,
                        iconColor: Color(0xFF8B98B0),
                        title: '11:00 - 22:00, 7 days / week',
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        icon: Icons.facebook_rounded,
                        iconColor: Color(0xFF3777F0),
                        title: '@mario_cheff',
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        icon: Icons.camera_alt_outlined,
                        iconColor: Color(0xFFFF7E66),
                        title: '@mario_cheff_italy',
                      ),
                    ],
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

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF8B92A8),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF6E778C),
            ),
          ),
        ),
      ],
    );
  }
}

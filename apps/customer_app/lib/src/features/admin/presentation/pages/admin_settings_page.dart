import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/state/app_scope.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  static const routeName = '/admin/settings';

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);
    final user = session.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          context.tr('Admin Settings', 'إعدادات الأدمن'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(
        currentTab: AdminBottomNavTab.settings,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C9B46), Color(0xFF207C38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C9B46).withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fattoush Admin',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? user?.phone ?? 'admin@fattoush.app',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Settings', 'الإعدادات'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF2C9B46)),
                    title: Text(
                      context.tr('App settings are managed from admin tools.', 'إعدادات النظام متاحة عبر أدوات الأدمن في الشاشات الأخرى.'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: Color(0xFF2C9B46)),
                    title: Text(
                      context.tr('Only authorized admin users can access.', 'الوصول مسموح فقط لحسابات الأدمن المصرح بها.'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('For account details, update your profile and security from the dedicated flows.', 'لتعديل بيانات الحساب والأمان، استخدم التدفقات المخصصة لذلك.'),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

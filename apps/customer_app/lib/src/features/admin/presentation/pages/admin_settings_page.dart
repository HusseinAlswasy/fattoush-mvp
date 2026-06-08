import 'package:flutter/material.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/state/app_preferences_controller.dart';
import '../../../../core/state/app_scope.dart';
import '../../../../core/widgets/app_back_home_button.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import 'admin_dashboard_page.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  static const routeName = '/admin/settings';

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);
    final preferences = AppScope.preferencesOf(context);
    final user = session.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: const AppBackHomeButton(
          homeRouteName: AdminDashboardPage.routeName,
        ),
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
                          user?.name ?? 'Fattoush Admin',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.email ?? user?.phone ?? 'admin@fattoush.app',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            _SettingsPanel(
              title: context.tr('Appearance', 'المظهر'),
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.dark_mode_outlined,
                    color: Color(0xFF2C9B46),
                  ),
                  title: Text(context.tr('Dark mode', 'الوضع الداكن')),
                  subtitle: Text(
                    context.tr(
                      'Switch between light and dark themes.',
                      'بدل بين الوضع الفاتح والداكن.',
                    ),
                  ),
                  value: preferences.isDarkMode,
                  onChanged: (enabled) {
                    preferences.setThemeMode(
                      enabled ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFF2C9B46),
                  ),
                  title: Text(context.tr('Language', 'اللغة')),
                  subtitle: Text(
                    preferences.isArabic ? 'العربية' : 'English',
                  ),
                  trailing: SegmentedButton<AppLanguage>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: AppLanguage.english,
                        label: Text('EN'),
                      ),
                      ButtonSegment(
                        value: AppLanguage.arabic,
                        label: Text('AR'),
                      ),
                    ],
                    selected: {preferences.language},
                    onSelectionChanged: (selection) {
                      preferences.setLanguage(selection.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SettingsPanel(
              title: context.tr('Account', 'الحساب'),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF2C9B46),
                  ),
                  title: Text(user?.name ?? 'Fattoush Admin'),
                  subtitle: Text(user?.email ?? 'admin@fattoush.app'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE04747),
                  ),
                  title: Text(context.tr('Logout', 'تسجيل الخروج')),
                  onTap: () {
                    session.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AuthPage.routeName,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

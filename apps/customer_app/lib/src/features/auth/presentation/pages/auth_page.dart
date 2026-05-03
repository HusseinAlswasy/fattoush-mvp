import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:customer_app/src/features/driver/presentation/pages/driver_orders_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  static const String routeName = '/auth';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerIdentifierController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerIdentifierController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEE7),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.local_grocery_store_rounded,
                      size: 42,
                      color: Color(0xFFFF8B6A),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Fattoush Market',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF464B5F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login as customer, create a new account, or continue as a guest.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Color(0xFF98A0B4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xFFFF8B6A),
                          unselectedLabelColor: const Color(0xFF9CA3B7),
                          indicatorColor: const Color(0xFFFF8B6A),
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'Login'),
                            Tab(text: 'Create Account'),
                          ],
                        ),
                        SizedBox(
                          height: 370,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _AuthForm(
                                title: 'Welcome back',
                                subtitle: 'Use phone or email with password.',
                                primaryLabel: 'LOGIN',
                                isLoading: session.isLoading,
                                onSubmit: _handleLogin,
                                children: [
                                  _InputField(
                                    controller: _loginIdentifierController,
                                    label: 'Phone or Email',
                                    hintText: 'customer@fattoush.app',
                                  ),
                                  _InputField(
                                    controller: _loginPasswordController,
                                    label: 'Password',
                                    hintText: '123456',
                                    obscureText: true,
                                  ),
                                ],
                              ),
                              _AuthForm(
                                title: 'Create customer account',
                                subtitle: 'New users will be created as customers.',
                                primaryLabel: 'CREATE ACCOUNT',
                                isLoading: session.isLoading,
                                onSubmit: _handleRegister,
                                children: [
                                  _InputField(
                                    controller: _registerNameController,
                                    label: 'Name',
                                    hintText: 'Your name',
                                  ),
                                  _InputField(
                                    controller: _registerIdentifierController,
                                    label: 'Phone or Email',
                                    hintText: '0500000000 or email',
                                  ),
                                  _InputField(
                                    controller: _registerPasswordController,
                                    label: 'Password',
                                    hintText: 'Minimum 6 characters',
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        session.continueAsGuest();
                        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
                      },
                      icon: const Icon(Icons.person_outline_rounded),
                      label: const Text('Continue as Guest'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5C6697),
                        side: const BorderSide(color: Color(0xFFDCE2EF)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        context.showAppNotice(
                          title: 'Forgot password',
                          message:
                              'Password reset is not connected yet. Please contact the admin for now.',
                          type: AppNoticeType.info,
                          duration: const Duration(seconds: 4),
                        );
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final session = AppScope.sessionOf(context);
    try {
      await session.login(
        identifier: _loginIdentifierController.text.trim(),
        password: _loginPasswordController.text,
      );
      if (!mounted) {
        return;
      }
      _goNext();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Login failed');
    }
  }

  Future<void> _handleRegister() async {
    final session = AppScope.sessionOf(context);
    try {
      await session.register(
        name: _registerNameController.text.trim(),
        identifier: _registerIdentifierController.text.trim(),
        password: _registerPasswordController.text,
      );
      if (!mounted) {
        return;
      }
      _goNext();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      context.showHandledError(error, fallbackTitle: 'Create account failed');
    }
  }

  void _goNext() {
    final session = AppScope.sessionOf(context);
    final routeName = session.isAdmin
        ? AdminDashboardPage.routeName
        : session.isDriver
            ? DriverOrdersPage.routeName
            : HomePage.routeName;
    Navigator.of(context).pushReplacementNamed(routeName);
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.children,
    required this.onSubmit,
    required this.isLoading,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final List<Widget> children;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A4E61),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF98A0B4),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8B6A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      primaryLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA4ABBE),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: const Color(0xFFF7F8FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

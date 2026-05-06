import 'package:customer_app/src/core/errors/app_error_presenter.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:customer_app/src/features/auth/presentation/controllers/app_session_controller.dart';
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
  final _registerConfirmController = TextEditingController();

  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;
  bool _showRegisterConfirm = false;

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
    _registerConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = AppScope.sessionOf(context);
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.height < 760;
    final headerHeight = isSmall ? 132.0 : 162.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF5),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF8FBF2),
                    Color(0xFFF1F8E5),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: isSmall ? 18 : 26),
                child: Column(
                  children: [
                    SizedBox(
                      height: headerHeight,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: isSmall ? 10 : 16,
                          left: 24,
                          right: 24,
                        ),
                        child: _TopLogo(
                          height: isSmall ? 110 : 132,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -4),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.98),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                            bottom: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB8D29D).withValues(alpha: 0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 54,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7EF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                dividerColor: Colors.transparent,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorPadding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                                indicator: BoxDecoration(
                                  color: const Color(0xFF2E7D1F),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: const Color(0xFF75836A),
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                                tabs: const [
                                  Tab(text: 'دخول'),
                                  Tab(text: 'إنشاء حساب'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: isSmall ? 500 : 560,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildLogin(session),
                                  _buildRegister(session),
                                ],
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
          },
        ),
      ),
    );
  }

  Widget _buildLogin(AppSessionController session) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D1F),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أهلاً بك، سجّل دخولك علشان نكمل طلبك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7968),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const _AccentLine(),
          const SizedBox(height: 16),
          _BrandInput(
            controller: _loginIdentifierController,
            hintText: 'رقم الهاتف أو البريد الإلكتروني',
            prefixIcon: Icons.phone_rounded,
          ),
          const SizedBox(height: 14),
          _BrandInput(
            controller: _loginPasswordController,
            hintText: 'كلمة المرور',
            prefixIcon: Icons.lock_rounded,
            obscureText: !_showLoginPassword,
            suffixIcon: _showLoginPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixTap: () {
              setState(() {
                _showLoginPassword = !_showLoginPassword;
              });
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
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
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  color: Color(0xFFEF8D3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _PrimaryActionButton(
            label: 'دخول',
            isLoading: session.isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              session.continueAsGuest();
              Navigator.of(context).pushReplacementNamed(HomePage.routeName);
            },
            child: const Text(
              'الدخول كضيف',
              style: TextStyle(
                color: Color(0xFF2E7D1F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister(AppSessionController session) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            'إنشاء حساب',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF2E7D1F),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أنشئ حسابك وابدأ التسوق بسهولة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7968),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const _AccentLine(),
          const SizedBox(height: 16),
          _BrandInput(
            controller: _registerNameController,
            hintText: 'الاسم الكامل',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _BrandInput(
            controller: _registerIdentifierController,
            hintText: 'رقم الهاتف أو البريد الإلكتروني',
            prefixIcon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 14),
          _BrandInput(
            controller: _registerPasswordController,
            hintText: 'كلمة المرور',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !_showRegisterPassword,
            suffixIcon: _showRegisterPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixTap: () {
              setState(() {
                _showRegisterPassword = !_showRegisterPassword;
              });
            },
          ),
          const SizedBox(height: 14),
          _BrandInput(
            controller: _registerConfirmController,
            hintText: 'تأكيد كلمة المرور',
            prefixIcon: Icons.lock_reset_rounded,
            obscureText: !_showRegisterConfirm,
            suffixIcon: _showRegisterConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixTap: () {
              setState(() {
                _showRegisterConfirm = !_showRegisterConfirm;
              });
            },
          ),
          const SizedBox(height: 18),
          _PrimaryActionButton(
            label: 'إنشاء حساب',
            isLoading: session.isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 8),
        ],
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
    if (_registerPasswordController.text != _registerConfirmController.text) {
      context.showAppNotice(
        title: 'Password mismatch',
        message: 'Please make sure both password fields are the same.',
        type: AppNoticeType.warning,
      );
      return;
    }

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

class _BrandInput extends StatelessWidget {
  const _BrandInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
        hintTextDirection: TextDirection.rtl,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F8EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(prefixIcon, color: const Color(0xFF2E7D1F)),
        ),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixTap,
                icon: Icon(
                  suffixIcon,
                  color: const Color(0xFF8AA079),
                ),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE3E9D9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2E7D1F), width: 1.4),
        ),
      ),
    );
  }
}

class _TopLogo extends StatelessWidget {
  const _TopLogo({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
          child: Image.asset(
            'assets/images/fattoush_wordmark.png',
            fit: BoxFit.contain,
          ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D1F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
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
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _AccentLine extends StatelessWidget {
  const _AccentLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFEF8D3A),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

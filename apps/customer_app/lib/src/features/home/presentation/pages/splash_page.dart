import 'dart:async';

import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String routeName = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AuthPage.routeName);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white),
        child: SizedBox.expand(
          child: Image(
            image: AssetImage('assets/images/splash_fattoush.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

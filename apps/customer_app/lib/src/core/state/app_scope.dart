import 'package:customer_app/src/features/auth/presentation/controllers/app_session_controller.dart';
import 'package:customer_app/src/features/cart/presentation/controllers/cart_controller.dart';
import 'package:flutter/widgets.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.cartController,
    required this.sessionController,
    required super.child,
  });

  final CartController cartController;
  final AppSessionController sessionController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  static CartController cartOf(BuildContext context) => of(context).cartController;

  static AppSessionController sessionOf(BuildContext context) =>
      of(context).sessionController;

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return cartController != oldWidget.cartController ||
        sessionController != oldWidget.sessionController;
  }
}

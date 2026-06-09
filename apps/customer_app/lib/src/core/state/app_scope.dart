import 'package:customer_app/src/core/state/app_preferences_controller.dart';
import 'package:customer_app/src/features/auth/presentation/controllers/app_session_controller.dart';
import 'package:customer_app/src/features/cart/presentation/controllers/cart_controller.dart';
import 'package:customer_app/src/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:flutter/widgets.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.cartController,
    required this.favoritesController,
    required this.preferencesController,
    required this.sessionController,
    required super.child,
  });

  final CartController cartController;
  final FavoritesController favoritesController;
  final AppPreferencesController preferencesController;
  final AppSessionController sessionController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  static CartController cartOf(BuildContext context) =>
      of(context).cartController;

  static FavoritesController favoritesOf(BuildContext context) =>
      of(context).favoritesController;

  static AppPreferencesController preferencesOf(BuildContext context) =>
      of(context).preferencesController;

  static AppSessionController sessionOf(BuildContext context) =>
      of(context).sessionController;

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return cartController != oldWidget.cartController ||
        favoritesController != oldWidget.favoritesController ||
        preferencesController != oldWidget.preferencesController ||
        sessionController != oldWidget.sessionController;
  }
}

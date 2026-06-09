import 'package:customer_app/src/core/state/app_preferences_controller.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/theme/app_theme.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_customers_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_products_page.dart';
import 'package:customer_app/src/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:customer_app/src/features/auth/presentation/controllers/app_session_controller.dart';
import 'package:customer_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:customer_app/src/features/cart/presentation/controllers/cart_controller.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/checkout/presentation/pages/delivery_address_page.dart';
import 'package:customer_app/src/features/checkout/data/models/checkout_draft.dart';
import 'package:customer_app/src/features/checkout/presentation/pages/order_completed_page.dart';
import 'package:customer_app/src/features/checkout/presentation/pages/payment_method_page.dart';
import 'package:customer_app/src/features/driver/presentation/pages/driver_details_page.dart';
import 'package:customer_app/src/features/driver/presentation/pages/driver_order_details_page.dart';
import 'package:customer_app/src/features/driver/presentation/pages/driver_orders_page.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/presentation/pages/category_products_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/categories_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/home_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/search_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/splash_page.dart';
import 'package:customer_app/src/features/notifications/presentation/pages/notifications_page.dart';
import 'package:customer_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  static final CartController _cartController = CartController();
  static final AppPreferencesController _preferencesController =
      AppPreferencesController();
  static final AppSessionController _sessionController = AppSessionController();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      cartController: _cartController,
      preferencesController: _preferencesController,
      sessionController: _sessionController,
      child: ListenableBuilder(
        listenable: _preferencesController,
        builder: (context, _) {
          final isArabic = _preferencesController.isArabic;
          return MaterialApp(
            title: 'Fattoush Customer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _preferencesController.themeMode,
            locale: Locale(isArabic ? 'ar' : 'en'),
            builder: (context, child) {
              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            initialRoute: SplashPage.routeName,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case SplashPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const SplashPage(),
                    settings: settings,
                  );
                case HomePage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const HomePage(),
                    settings: settings,
                  );
                case AuthPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const AuthPage(),
                    settings: settings,
                  );
                case AdminDashboardPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const AdminDashboardPage(),
                    settings: settings,
                  );
                case AdminOrdersPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const AdminOrdersPage(),
                    settings: settings,
                  );
                case AdminProductsPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const AdminProductsPage(),
                    settings: settings,
                  );
                case AdminCustomersPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const AdminCustomersPage(),
                    settings: settings,
                  );
                case AdminSettingsPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const AdminSettingsPage(),
                    settings: settings,
                  );
                case ProductDetailsPage.routeName:
                  final product = settings.arguments! as Product;
                  return MaterialPageRoute<void>(
                    builder: (_) => ProductDetailsPage(product: product),
                    settings: settings,
                  );
                case CategoriesPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const CategoriesPage(),
                    settings: settings,
                  );
                case SearchPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const SearchPage(),
                    settings: settings,
                  );
                case NotificationsPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const NotificationsPage(),
                    settings: settings,
                  );
                case CategoryProductsPage.routeName:
                  final categoryName = settings.arguments! as String;
                  return MaterialPageRoute<void>(
                    builder: (_) =>
                        CategoryProductsPage(categoryName: categoryName),
                    settings: settings,
                  );
                case DriverDetailsPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const DriverDetailsPage(),
                    settings: settings,
                  );
                case DriverOrdersPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const DriverOrdersPage(),
                    settings: settings,
                  );
                case DriverOrderDetailsPage.routeName:
                  final order = settings.arguments! as Map<String, dynamic>;
                  return MaterialPageRoute<void>(
                    builder: (_) => DriverOrderDetailsPage(order: order),
                    settings: settings,
                  );
                case CartPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const CartPage(),
                    settings: settings,
                  );
                case DeliveryAddressPage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const DeliveryAddressPage(),
                    settings: settings,
                  );
                case PaymentMethodPage.routeName:
                  final checkoutDraft = settings.arguments! as CheckoutDraft;
                  return MaterialPageRoute<void>(
                    builder: (_) => PaymentMethodPage(checkout: checkoutDraft),
                    settings: settings,
                  );
                case OrderCompletedPage.routeName:
                  final orderId = settings.arguments as String?;
                  return MaterialPageRoute<void>(
                    builder: (_) => OrderCompletedPage(orderId: orderId),
                    settings: settings,
                  );
                case ProfilePage.routeName:
                  return MaterialPageRoute<void>(
                    builder: (_) => const ProfilePage(),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute<void>(
                    builder: (_) => const SplashPage(),
                    settings: settings,
                  );
              }
            },
          );
        },
      ),
    );
  }
}

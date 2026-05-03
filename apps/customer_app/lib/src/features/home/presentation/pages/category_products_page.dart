import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:customer_app/src/features/home/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

class CategoryProductsPage extends StatefulWidget {
  const CategoryProductsPage({
    super.key,
    required this.categoryName,
  });

  static const String routeName = '/category-products';

  final String categoryName;

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final HomeApiService _homeApiService = HomeApiService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Product>> _load() async {
    final homeData = await _homeApiService.fetchHomeData();
    return homeData.products
        .where((product) => (product.category ?? '').trim() == widget.categoryName)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        surfaceTintColor: const Color(0xFFF4F6FB),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Color(0xFF3A3D4D),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(CartPage.routeName),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load category products'));
            }

            final products = snapshot.data ?? const <Product>[];
            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'لا يوجد منتجات في هذا التصنيف',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4E61),
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ProductDetailsPage.routeName,
                      arguments: product,
                    );
                  },
                  onAddToCart: () {
                    cart.add(product);
                    context.showAppNotice(
                      title: 'Added to cart',
                      message: '${product.name} added successfully.',
                      type: AppNoticeType.success,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

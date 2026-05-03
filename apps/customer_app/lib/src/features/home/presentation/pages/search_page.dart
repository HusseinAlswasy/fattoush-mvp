import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:customer_app/src/features/home/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const String routeName = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HomeApiService _homeApiService = HomeApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Product>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _load() async {
    final homeData = await _homeApiService.fetchHomeData();
    return homeData.products;
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        surfaceTintColor: const Color(0xFFF4F6FB),
        title: const Text(
          'Search Products',
          style: TextStyle(
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
              return const Center(child: Text('Failed to load products'));
            }

            final products = snapshot.data ?? const <Product>[];
            final filteredProducts = _query.isEmpty
                ? products
                : products.where((product) {
                    final haystack = [
                      product.name,
                      product.description ?? '',
                      product.category ?? '',
                    ].join(' ').toLowerCase();
                    return haystack.contains(_query.toLowerCase());
                  }).toList(growable: false);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for any product',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_query.isNotEmpty && filteredProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Text(
                      'المنتج غير موجود',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A4E61),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
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
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

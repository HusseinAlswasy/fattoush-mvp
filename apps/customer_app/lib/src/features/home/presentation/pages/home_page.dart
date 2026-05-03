import 'package:customer_app/src/core/layout/app_responsive.dart';
import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/data/models/home_data.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:customer_app/src/features/home/presentation/pages/categories_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:customer_app/src/features/home/presentation/widgets/error_state_widget.dart';
import 'package:customer_app/src/features/home/presentation/widgets/product_card.dart';
import 'package:customer_app/src/features/home/presentation/widgets/promo_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeApiService _homeApiService = HomeApiService();
  late Future<HomeData> _homeFuture;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _homeFuture = _homeApiService.fetchHomeData();
  }

  Future<void> _refresh() async {
    setState(() {
      _homeFuture = _homeApiService.fetchHomeData();
    });
    await _homeFuture;
  }

  void _openProductDetails(BuildContext context, Product product) {
    Navigator.of(context).pushNamed(
      ProductDetailsPage.routeName,
      arguments: product,
    );
  }

  void _openCart(BuildContext context) {
    Navigator.of(context).pushNamed(CartPage.routeName);
  }

  void _openCategories(BuildContext context) {
    Navigator.of(context).pushNamed(CategoriesPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);
    final isSmallPhone = context.isSmallPhone;
    final categoryColumns = isSmallPhone ? 3 : 4;
    final productCardWidth = isSmallPhone ? 160.0 : 180.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppBottomNavTab.home,
      ),
      body: SafeArea(
        child: FutureBuilder<HomeData>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ErrorStateWidget(
                message: 'تعذر تحميل البيانات من السيرفر.\n${snapshot.error}',
                onRetry: _refresh,
              );
            }

            final data = snapshot.data!;
            final categories = _buildCategories(data.products);
            final visibleProducts = _selectedCategory == null
                ? data.products
                : data.products
                    .where((product) => product.category == _selectedCategory)
                    .toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  _HomeHeader(onCartTap: () => _openCart(context)),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  SizedBox(
                    height: isSmallPhone ? 146 : 158,
                    child: data.ads.isEmpty
                        ? const PromoCard.fallback()
                        : PageView.builder(
                            itemCount: data.ads.length,
                            controller: PageController(viewportFraction: 0.96),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: PromoCard(ad: data.ads[index]),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      data.ads.isEmpty ? 4 : data.ads.length.clamp(1, 4),
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFFFF8B6A)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE6E8EF)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  const _SearchBox(),
                  SizedBox(height: isSmallPhone ? 14 : 18),
                  GridView.builder(
                    itemCount: categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: categoryColumns,
                      mainAxisSpacing: isSmallPhone ? 12 : 14,
                      crossAxisSpacing: isSmallPhone ? 12 : 14,
                      childAspectRatio: isSmallPhone ? 0.86 : 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return _CategoryCard(
                        item: item,
                        selected: item.label == _selectedCategory,
                        onTap: () {
                          setState(() {
                            if (item.label == 'الكل') {
                              _selectedCategory = null;
                            } else {
                              _selectedCategory = item.label;
                            }
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: isSmallPhone ? 18 : 22),
                  Row(
                    children: [
                      Text(
                        _selectedCategory == null
                            ? 'Popular'
                            : '$_selectedCategory',
                        style: TextStyle(
                          fontSize: isSmallPhone ? 24 : 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3A3D4D),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _openCategories(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('All'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (visibleProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 26),
                      child: Text(
                        'No products found in this category yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF98A0B4)),
                      ),
                    )
                  else
                    SizedBox(
                      height: isSmallPhone ? 248 : 262,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: visibleProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final product = visibleProducts[index];
                          return SizedBox(
                            width: productCardWidth,
                            child: ProductCard(
                              product: product,
                              onTap: () => _openProductDetails(context, product),
                              onAddToCart: () {
                                cart.add(product);
                                context.showAppNotice(
                                  title: 'Added to cart',
                                  message:
                                      '${product.name} is ready in your order.',
                                  type: AppNoticeType.success,
                                  actionLabel: 'Open cart',
                                  onAction: () {
                                    Navigator.of(context).pushNamed(
                                      CartPage.routeName,
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
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

  List<_CategoryItem> _buildCategories(List<Product> products) {
    final categoryNames = products
        .map((product) => product.category?.trim())
        .whereType<String>()
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return [
      const _CategoryItem(label: 'الكل', icon: '🛒'),
      ...categoryNames.map(
        (category) => _CategoryItem(
          label: category,
          icon: _categoryEmoji(category),
        ),
      ),
    ];
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'بيتزا':
        return '🍕';
      case 'كشري':
        return '🍲';
      case 'فراخ':
        return '🍗';
      case 'حلويات':
        return '🧁';
      case 'المخبوزات':
        return '🥖';
      case 'البقالة':
        return '🛍️';
      default:
        return '🍽️';
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onCartTap});

  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = context.isSmallPhone;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Foodster',
            style: TextStyle(
              fontSize: isSmallPhone ? 24 : 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5C6697),
            ),
          ),
        ),
        const Icon(
          Icons.location_on_rounded,
          color: Color(0xFFFF8666),
          size: 20,
        ),
        const SizedBox(width: 4),
        const Text(
          'القاهرة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF585D72),
          ),
        ),
        SizedBox(width: isSmallPhone ? 6 : 10),
        GestureDetector(
          onTap: onCartTap,
          child: Container(
            width: isSmallPhone ? 34 : 38,
            height: isSmallPhone ? 34 : 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF8890A8),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = context.isSmallPhone;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallPhone ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن وجبة أو مطعم',
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.search_rounded, color: Color(0xFFB2B7C8)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _CategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSmallPhone = context.isSmallPhone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF8B6A) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  item.icon,
                  style: TextStyle(fontSize: isSmallPhone ? 24 : 28),
                ),
              ),
            ),
          ),
          SizedBox(height: isSmallPhone ? 6 : 8),
          Text(
            item.label,
            style: TextStyle(
              fontSize: isSmallPhone ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFFFF8B6A)
                  : const Color(0xFF8A90A3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final String icon;
}

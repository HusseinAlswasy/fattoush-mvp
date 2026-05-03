import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/data/models/ad_banner.dart';
import 'package:customer_app/src/features/home/data/models/home_data.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:customer_app/src/features/home/presentation/pages/categories_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/search_page.dart';
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
  final TextEditingController _inlineSearchController = TextEditingController();
  late Future<HomeData> _homeFuture;
  String? _selectedCategory;
  String _inlineQuery = '';

  @override
  void initState() {
    super.initState();
    _homeFuture = _homeApiService.fetchHomeData();
    _inlineSearchController.addListener(() {
      setState(() {
        _inlineQuery = _inlineSearchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _inlineSearchController.dispose();
    super.dispose();
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

  List<_CategoryItem> _buildCategories(List<Product> products) {
    final categoryNames = products
        .map((product) => product.category?.trim())
        .whereType<String>()
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return categoryNames
        .map(
          (category) => _CategoryItem(
            label: category,
            icon: _categoryEmoji(category),
          ),
        )
        .toList(growable: false);
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesCategory = _selectedCategory == null
          ? true
          : (product.category ?? '').trim() == _selectedCategory;
      final matchesQuery = _inlineQuery.isEmpty
          ? true
          : [
              product.name,
              product.description ?? '',
              product.category ?? '',
            ].join(' ').toLowerCase().contains(_inlineQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  List<AdBannerModel> _buildShowcase(HomeData data) {
    final productShowcase = data.products
        .where((product) => (product.imageUrl ?? '').isNotEmpty)
        .toList(growable: false)
        .reversed
        .take(5)
        .map(
          (product) => AdBannerModel(
            id: 'product-${product.id}',
            title: product.name,
            imageUrl: product.imageUrl ?? '',
          ),
        )
        .toList(growable: false);

    if (productShowcase.isNotEmpty) {
      return productShowcase;
    }

    return data.ads;
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'البقالة':
        return '🛒';
      case 'المخبوزات':
        return '🥖';
      case 'الألبان':
        return '🥛';
      case 'الخضار':
        return '🥬';
      case 'الفواكه':
        return '🍎';
      case 'اللحوم':
        return '🥩';
      case 'الفراخ':
        return '🍗';
      case 'المجمدات':
        return '🧊';
      case 'المشروبات':
        return '🥤';
      case 'الحلويات':
        return '🧁';
      case 'المنظفات':
        return '🧴';
      case 'العناية الشخصية':
        return '🧼';
      default:
        return '🛍️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);

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
                message: 'تعذر تحميل البيانات من السيرفر.',
                onRetry: _refresh,
              );
            }

            final data = snapshot.data!;
            final categories = _buildCategories(data.products);
            final visibleProducts = _filterProducts(data.products);
            final showcase = _buildShowcase(data);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  _HomeHeader(
                    onSearchTap: () => Navigator.of(context).pushNamed(
                      SearchPage.routeName,
                    ),
                    onCartTap: () => Navigator.of(context).pushNamed(
                      CartPage.routeName,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 170,
                    child: showcase.isEmpty
                        ? const PromoCard.fallback()
                        : PageView.builder(
                            itemCount: showcase.length,
                            controller: PageController(viewportFraction: 0.95),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: PromoCard(ad: showcase[index]),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _inlineSearchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث في الصفحة عن أي منتج',
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'الكل',
                          icon: '🛒',
                          selected: _selectedCategory == null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                        ...categories.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: _CategoryChip(
                              label: item.label,
                              icon: item.icon,
                              selected: item.label == _selectedCategory,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = item.label;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Text(
                        _selectedCategory ?? 'All Products',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3A3D4D),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                          CategoriesPage.routeName,
                        ),
                        child: const Text('All Categories'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (visibleProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
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
                      itemCount: visibleProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final product = visibleProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => _openProductDetails(context, product),
                          onAddToCart: () {
                            cart.add(product);
                            context.showAppNotice(
                              title: 'Added to cart',
                              message: '${product.name} added successfully.',
                              type: AppNoticeType.success,
                              actionLabel: 'Open cart',
                              onAction: () {
                                Navigator.of(context).pushNamed(
                                  CartPage.routeName,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onSearchTap,
    required this.onCartTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Fattoush',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5C6697),
            ),
          ),
        ),
        _HeaderIconButton(
          icon: Icons.search_rounded,
          onTap: onSearchTap,
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(
          icon: Icons.shopping_bag_outlined,
          onTap: onCartTap,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF8890A8)),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF8B6A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF5B6072),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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

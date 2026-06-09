import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/core/widgets/product_image_view.dart';
import 'package:customer_app/src/features/cart/presentation/pages/cart_page.dart';
import 'package:customer_app/src/features/home/data/models/home_data.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:customer_app/src/features/home/presentation/pages/categories_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/search_page.dart';
import 'package:customer_app/src/features/home/presentation/widgets/error_state_widget.dart';
import 'package:customer_app/src/features/notifications/data/product_notifications_service.dart';
import 'package:customer_app/src/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeApiService _homeApiService = HomeApiService();
  final ProductNotificationsService _notificationsService =
      ProductNotificationsService();
  final TextEditingController _inlineSearchController = TextEditingController();
  late Future<HomeData> _homeFuture;
  late Future<int> _unreadNotificationsFuture;
  String? _selectedCategory;
  String _inlineQuery = '';

  @override
  void initState() {
    super.initState();
    _homeFuture = _homeApiService.fetchHomeData();
    _unreadNotificationsFuture = _fetchUnreadNotifications();
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
      _unreadNotificationsFuture = _fetchUnreadNotifications();
    });
    await _homeFuture;
  }

  Future<int> _fetchUnreadNotifications() async {
    return (await _notificationsService.fetchSummary()).unreadCount;
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed(NotificationsPage.routeName);
    if (!mounted) return;
    setState(() {
      _unreadNotificationsFuture = _fetchUnreadNotifications();
    });
  }

  void _openProductDetails(Product product) {
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
        .toList(growable: false)
      ..sort();

    return categoryNames
        .map(
          (category) => _CategoryItem(
            label: category,
            icon: _categoryIcon(category),
          ),
        )
        .toList(growable: false);
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesCategory = _selectedCategory == null
          ? true
          : (product.category ?? '').trim() == _selectedCategory;
      final lowerQuery = _inlineQuery.toLowerCase();
      final matchesQuery = lowerQuery.isEmpty
          ? true
          : [
              product.name,
              product.description ?? '',
              product.category ?? '',
            ].join(' ').toLowerCase().contains(lowerQuery);

      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  IconData _categoryIcon(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('meat') ||
        normalized.contains('لحوم') ||
        normalized.contains('فراخ')) {
      return Icons.set_meal_rounded;
    }
    if (normalized.contains('fruit') || normalized.contains('فاكه')) {
      return Icons.apple_rounded;
    }
    if (normalized.contains('veget') || normalized.contains('خض')) {
      return Icons.eco_rounded;
    }
    if (normalized.contains('dairy') || normalized.contains('لبن')) {
      return Icons.local_drink_rounded;
    }
    if (normalized.contains('drink') || normalized.contains('مشروب')) {
      return Icons.local_bar_rounded;
    }
    if (normalized.contains('bak') || normalized.contains('مخب')) {
      return Icons.bakery_dining_rounded;
    }

    return Icons.shopping_basket_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.cartOf(context);
    final favorites = AppScope.favoritesOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppBottomNavTab.home,
      ),
      body: SafeArea(
        child: FutureBuilder<HomeData>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF5A52),
                ),
              );
            }

            if (snapshot.hasError) {
              return ErrorStateWidget(
                message: 'Could not load data from the server.',
                onRetry: _refresh,
              );
            }

            final data = snapshot.data!;
            final products = data.products;
            final visibleProducts = _filterProducts(products);
            final categories = _buildCategories(products);

            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFFFF5A52),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  _CustomerHeader(
                    cartCount: cart.totalItems,
                    notificationCountFuture: _unreadNotificationsFuture,
                    onNotificationsTap: _openNotifications,
                    onCartTap: () => Navigator.of(context).pushNamed(
                      CartPage.routeName,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SearchBar(
                    controller: _inlineSearchController,
                    onOpenSearch: () => Navigator.of(context).pushNamed(
                      SearchPage.routeName,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _CategoryRail(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    onAllTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    onCategoryTap: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: _selectedCategory ?? 'All Products',
                    count: visibleProducts.length,
                    onViewAll: () => Navigator.of(context).pushNamed(
                      CategoriesPage.routeName,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (visibleProducts.isEmpty)
                    const _ProductNotFound()
                  else
                    ListenableBuilder(
                      listenable: favorites,
                      builder: (context, _) {
                        return _ProductGrid(
                          products: visibleProducts,
                          onOpenProduct: _openProductDetails,
                          isFavorite: favorites.isFavorite,
                          onToggleFavorite: favorites.toggle,
                          onAddToCart: (product) {
                            cart.add(product);
                            context.showAppNotice(
                              title: 'Added to cart',
                              message: '${product.name} added successfully.',
                              type: AppNoticeType.success,
                              actionLabel: 'Open cart',
                              onAction: () => Navigator.of(context).pushNamed(
                                CartPage.routeName,
                              ),
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

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({
    required this.cartCount,
    required this.notificationCountFuture,
    required this.onNotificationsTap,
    required this.onCartTap,
  });

  final int cartCount;
  final Future<int> notificationCountFuture;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fattoush',
                style: TextStyle(
                  color: Color(0xFF17213F),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFFF5A52),
                    size: 19,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Egypt',
                    style: TextStyle(
                      color: Color(0xFF73788A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF73788A),
                  ),
                ],
              ),
            ],
          ),
        ),
        _TopActionButton(
          icon: Icons.notifications_none_rounded,
          badgeFuture: notificationCountFuture,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 14),
        _TopActionButton(
          icon: Icons.shopping_cart_outlined,
          badge: cartCount,
          onTap: onCartTap,
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.badgeFuture,
  });

  final IconData icon;
  final int badge;
  final Future<int>? badgeFuture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final future = badgeFuture;
    if (future != null) {
      return FutureBuilder<int>(
        future: future,
        builder: (context, snapshot) {
          return _TopActionButtonFrame(
            icon: icon,
            badge: snapshot.data ?? 0,
            onTap: onTap,
          );
        },
      );
    }

    return _TopActionButtonFrame(
      icon: icon,
      badge: badge,
      onTap: onTap,
    );
  }
}

class _TopActionButtonFrame extends StatelessWidget {
  const _TopActionButtonFrame({
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(
                icon,
                color: const Color(0xFF19213E),
                size: 28,
              ),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -5,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 22),
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7B65),
                shape: BoxShape.circle,
              ),
              child: Text(
                badge > 9 ? '9+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onOpenSearch,
  });

  final TextEditingController controller;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        controller: controller,
        onTap: onOpenSearch,
        decoration: InputDecoration(
          hintText: 'Search for any product...',
          hintStyle: const TextStyle(
            color: Color(0xFF8B90A2),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF525A75),
            size: 30,
          ),
          suffixIcon: IconButton(
            onPressed: onOpenSearch,
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF525A75),
              size: 28,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categories,
    required this.selectedCategory,
    required this.onAllTap,
    required this.onCategoryTap,
  });

  final List<_CategoryItem> categories;
  final String? selectedCategory;
  final VoidCallback onAllTap;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryTile(
              label: 'All',
              icon: Icons.grid_view_rounded,
              selected: selectedCategory == null,
              onTap: onAllTap,
            );
          }

          final category = categories[index - 1];
          return _CategoryTile(
            label: category.label,
            icon: category.icon,
            selected: selectedCategory == category.label,
            onTap: () => onCategoryTap(category.label),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF5A52) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFFFF5A52),
                size: 31,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF202944),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.count,
    required this.onViewAll,
  });

  final String title;
  final int? count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final label = count == null ? title : '$title ($count)';

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF22242B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onViewAll,
          iconAlignment: IconAlignment.end,
          label: const Text('View All'),
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF5A52),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.onOpenProduct,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  final List<Product> products;
  final ValueChanged<Product> onOpenProduct;
  final bool Function(Product product) isFavorite;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<Product> onAddToCart;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 380;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: isSmall ? 0.50 : 0.54,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductShowcaseCard(
          product: product,
          isFavorite: isFavorite(product),
          onTap: () => onOpenProduct(product),
          onFavoriteTap: () => onToggleFavorite(product),
          onAddToCart: () => onAddToCart(product),
        );
      },
    );
  }
}

class _ProductShowcaseCard extends StatelessWidget {
  const _ProductShowcaseCard({
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAddToCart,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 380;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: isSmall ? 104 : 112,
                    child: _NetworkProductImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: InkWell(
                    onTap: onFavoriteTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? const Color(0xFFFF5A52)
                            : const Color(0xFF202944),
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF22242B),
                        fontSize: isSmall ? 13 : 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.description?.isNotEmpty == true
                          ? product.description!
                          : 'Fresh & Premium',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF777C91),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isSmall ? 6 : 8),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: Color(0xFFFF8A00), size: isSmall ? 13 : 15),
                        Icon(Icons.star_rounded,
                            color: Color(0xFFFF8A00), size: isSmall ? 13 : 15),
                        Icon(Icons.star_rounded,
                            color: Color(0xFFFF8A00), size: isSmall ? 13 : 15),
                        Icon(Icons.star_rounded,
                            color: Color(0xFFFF8A00), size: isSmall ? 13 : 15),
                        Icon(Icons.star_half_rounded,
                            color: Color(0xFFFF8A00), size: isSmall ? 13 : 15),
                      ],
                    ),
                    SizedBox(height: isSmall ? 6 : 8),
                    Text(
                      'EGP ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: const Color(0xFF17213F),
                        fontSize: isSmall ? 14 : 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: isSmall ? 34 : 36,
                      child: FilledButton(
                        onPressed: onAddToCart,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF514A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          textStyle: TextStyle(
                            fontSize: isSmall ? 10.5 : 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: const FittedBox(child: Text('Add to Cart')),
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
  }
}

class _NetworkProductImage extends StatelessWidget {
  const _NetworkProductImage({
    required this.imageUrl,
    required this.fit,
  });

  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ProductImageView(
      imageUrl: imageUrl,
      fit: fit,
    );
  }
}

class _ProductNotFound extends StatelessWidget {
  const _ProductNotFound();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Product not found',
        style: TextStyle(
          color: Color(0xFF202944),
          fontSize: 20,
          fontWeight: FontWeight.w900,
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
  final IconData icon;
}

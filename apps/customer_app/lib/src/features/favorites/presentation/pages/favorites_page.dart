import 'package:customer_app/src/core/state/app_scope.dart';
import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/core/widgets/app_notice.dart';
import 'package:customer_app/src/core/widgets/product_image_view.dart';
import 'package:customer_app/src/features/home/data/models/product.dart';
import 'package:customer_app/src/features/home/presentation/pages/home_page.dart';
import 'package:customer_app/src/features/home/presentation/pages/product_details_page.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const String routeName = '/favorites';

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(HomePage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.favoritesOf(context);
    final cart = AppScope.cartOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        bottomNavigationBar: const AppBottomNav(
          currentTab: AppBottomNavTab.favorites,
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: favorites,
            builder: (context, _) {
              final products = favorites.products;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  _FavoritesHeader(onBack: () => _goHome(context)),
                  const SizedBox(height: 18),
                  _FavoritesSummary(count: products.length),
                  const SizedBox(height: 20),
                  if (products.isEmpty)
                    const _EmptyFavorites()
                  else
                    ...products.map(
                      (product) => _FavoriteProductTile(
                        product: product,
                        onOpen: () => Navigator.of(context).pushNamed(
                          ProductDetailsPage.routeName,
                          arguments: product,
                        ),
                        onRemove: () => favorites.remove(product),
                        onAddToCart: () {
                          cart.add(product);
                          context.showAppNotice(
                            title: 'Added to cart',
                            message: '${product.name} added successfully.',
                            type: AppNoticeType.success,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Favorite',
            style: TextStyle(
              color: Color(0xFF17213F),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoritesSummary extends StatelessWidget {
  const _FavoritesSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5A52), Color(0xFFFF8A65)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              count == 0
                  ? 'No favorite products yet'
                  : '$count favorite products',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteProductTile extends StatelessWidget {
  const _FavoriteProductTile({
    required this.product,
    required this.onOpen,
    required this.onRemove,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: ProductImageView(imageUrl: product.imageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF17213F),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description?.isNotEmpty == true
                            ? product.description!
                            : 'Fresh & Premium',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF7C8294),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EGP ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFFF5A52),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF5A52),
                      ),
                    ),
                    IconButton(
                      onPressed: onAddToCart,
                      icon: const Icon(
                        Icons.add_shopping_cart_rounded,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: Color(0xFFFF5A52),
            size: 58,
          ),
          SizedBox(height: 12),
          Text(
            'Tap the heart on any product to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7C8294),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

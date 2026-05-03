import 'package:customer_app/src/core/widgets/app_bottom_nav.dart';
import 'package:customer_app/src/features/home/data/services/home_api_service.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  static const String routeName = '/categories';

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final HomeApiService _homeApiService = HomeApiService();
  late Future<List<_CategoryListItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_CategoryListItem>> _load() async {
    final homeData = await _homeApiService.fetchHomeData();
    final grouped = <String, int>{};

    for (final product in homeData.products) {
      final category = (product.category ?? 'Other').trim();
      grouped[category] = (grouped[category] ?? 0) + 1;
    }

    final categories = grouped.entries
        .map(
          (entry) => _CategoryListItem(
            title: entry.key,
            subtitle: '${entry.value} products',
            emoji: _emojiFor(entry.key),
            color: _colorFor(entry.key),
          ),
        )
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      bottomNavigationBar: const AppBottomNav(
        currentTab: AppBottomNavTab.restaurants,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          child: Column(
            children: [
              Row(
                children: [
                  _TopIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4C5063),
                    ),
                  ),
                  const Spacer(),
                  const _TopIconButton(icon: Icons.search_rounded),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4C5063),
                      ),
                    ),
                  ),
                  _ViewModeBadge(icon: Icons.grid_view_rounded, active: false),
                  SizedBox(width: 8),
                  _ViewModeBadge(icon: Icons.menu_rounded, active: true),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<_CategoryListItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load categories'));
                    }

                    final items = snapshot.data ?? <_CategoryListItem>[];
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4C5063),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.subtitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFACB1BF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    item.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _emojiFor(String category) {
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

  Color _colorFor(String category) {
    switch (category) {
      case 'بيتزا':
        return const Color(0xFFFFE7D6);
      case 'كشري':
        return const Color(0xFFFFF1D8);
      case 'فراخ':
        return const Color(0xFFFFE9D9);
      case 'حلويات':
        return const Color(0xFFFFE3EF);
      case 'المخبوزات':
        return const Color(0xFFE3F4E7);
      case 'البقالة':
        return const Color(0xFFE3EDFF);
      default:
        return const Color(0xFFFFEDD7);
    }
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF8B92A8)),
      ),
    );
  }
}

class _ViewModeBadge extends StatelessWidget {
  const _ViewModeBadge({
    required this.icon,
    required this.active,
  });

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF8B6A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 18,
        color: active ? Colors.white : const Color(0xFFBDC2CF),
      ),
    );
  }
}

class _CategoryListItem {
  const _CategoryListItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
}
